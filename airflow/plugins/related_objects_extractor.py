import sqlparse
from sqlparse.tokens import DML, Keyword, Whitespace, Punctuation
from sqlparse.sql import IdentifierList, Identifier, Function, Parenthesis, Comparison


class SQLParser:
    def __init__(self, sql):
        formatted = sqlparse.format(sql, strip_whitespace=True)
        self.parsedQueries = sqlparse.parse(formatted)

    def _is_subselect(self, parsed):
        if not parsed.is_group:
            return False
        for item in parsed.tokens:
            if item.is_group:
                return self._is_subselect(item)
            elif item.ttype is DML and item.value.upper() == 'SELECT':
                return True
        return False

    def _extract_identifiers(self, tokens):
        for token in tokens:
            if isinstance(token, IdentifierList):
                for identifier in token.get_identifiers():
                    if identifier.get_real_name():
                        yield identifier.get_real_name()
            elif isinstance(token, (Identifier, Function)):
                if token.get_real_name():
                    yield token.get_real_name()

    def _extract_from_part_target(self, parsed):
        i = 0
        while i < len(parsed.tokens):
            token = parsed.tokens[i]
            if token.is_group:
                for result in self._extract_from_part_target(token):
                    yield result
            if token.ttype is Keyword and token.value.upper() in ["FROM", "EXEC", "EXECUTE", "CALL", "INTO"]:
                i += 1
                if token.value.upper() == 'INTO' and parsed.tokens[i - 3].value.upper() != 'INSERT':
                    continue
                if token.value.upper() == 'FROM' and parsed.tokens[i - 3].value.upper() != 'DELETE':
                    continue
                while (i < len(parsed.tokens) and
                       (parsed.tokens[i].ttype is Whitespace or parsed.tokens[i].ttype is Punctuation)):
                    i += 1
                if i < len(parsed.tokens):
                    next_token = parsed.tokens[i]
                    if self._is_subselect(next_token):
                        for result in self._extract_from_part_target(next_token):
                            yield result
                    else:
                        yield next_token
            i += 1

    def _extract_from_part_source(self, parsed):
        i = 0
        while i < len(parsed.tokens):
            token = parsed.tokens[i]
            if token.is_group:
                for result in self._extract_from_part_source(token):
                    yield result
            if token.ttype is Keyword and token.value.upper() in ["FROM", "JOIN", "INNER JOIN", "LEFT JOIN",
                                                                  "RIGHT JOIN", "FULL JOIN"]:
                i += 1
                if token.value.upper() == 'INTO' and parsed.tokens[i - 3].value.upper() != 'INSERT':
                    continue
                if token.value.upper() == 'FROM' and parsed.tokens[i - 3].value.upper() == 'DELETE':
                    continue
                while (i < len(parsed.tokens) and
                       (parsed.tokens[i].ttype is Whitespace or parsed.tokens[i].ttype is Punctuation)):
                    i += 1
                if i < len(parsed.tokens):
                    next_token = parsed.tokens[i]
                    if self._is_subselect(next_token):
                        for result in self._extract_from_part_source(next_token):
                            yield result
                    else:
                        yield next_token
            i += 1

    def _extract_procedures_columns(self, parsed):
        table_columns = {}

        i = 0
        while i < len(parsed.tokens):
            token = parsed.tokens[i]
            if token.ttype is DML and token.value.upper() == 'INSERT':
                while i < len(parsed.tokens) and parsed.tokens[i].ttype is not Keyword:
                    i += 1
                if i < len(parsed.tokens) and parsed.tokens[i].value.upper() == 'INTO':
                    i += 1
                    while (i < len(parsed.tokens) and
                           (parsed.tokens[i].ttype is Whitespace or parsed.tokens[i].ttype is Punctuation)):
                        i += 1
                    table_token = parsed.tokens[i]
                    table_name = table_token.get_real_name()
                    table_columns[table_name] = []

                    for token in table_token:
                        if isinstance(token, Parenthesis):
                            parenthesis = str(token).strip("()")
                            columns = parenthesis.split(", ")
                            table_columns[table_name] = [column.strip() for column in columns]
            elif token.ttype is DML and token.value.upper() == 'UPDATE':
                i += 1
                while (i < len(parsed.tokens) and
                       (parsed.tokens[i].ttype is Whitespace or parsed.tokens[i].ttype is Punctuation)):
                    i += 1
                table_token = parsed.tokens[i]
                table_name = table_token.get_real_name()
                table_columns[table_name] = []

                while i < len(parsed.tokens) and parsed.tokens[i].ttype is not Keyword:
                    i += 1
                if i < len(parsed.tokens) and parsed.tokens[i].value.upper() == 'SET':
                    i += 1
                    while (i < len(parsed.tokens) and
                           (parsed.tokens[i].ttype is Whitespace or parsed.tokens[i].ttype is Punctuation)):
                        i += 1

                    if isinstance(parsed.tokens[i], (IdentifierList, Comparison)):
                        token = str(parsed.tokens[i])
                        assignments = token.split(",")

                        if len(assignments) > 1:
                            table_columns[table_name] = [assignment.split("=")[0].strip() for assignment in assignments]
                        else:
                            table_columns[table_name] = [token.split("=")[0].strip()]
            i += 1

        return table_columns

    def extract_related_objects(self):
        results_target = []
        results_source = []
        columns = []
        for query in self.parsedQueries:
            stream_target = self._extract_from_part_target(query)
            stream_source = self._extract_from_part_source(query)
            results_target.extend(list(self._extract_identifiers(stream_target)))
            results_source.extend(list(self._extract_identifiers(stream_source)))
            columns.append(self._extract_procedures_columns(query))
        return list(set(results_target)), list(set(results_source)), columns
