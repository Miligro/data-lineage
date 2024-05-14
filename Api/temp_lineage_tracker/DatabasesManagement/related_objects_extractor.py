import sqlparse
from sqlparse.tokens import DML, Keyword, Whitespace, Punctuation
from sqlparse.sql import IdentifierList, Identifier

class SQLParser:
    def __init__(self, sql):
        formatted = sqlparse.format(sql, strip_whitespace=True)
        self.parse = sqlparse.parse(formatted)[0]

    def _is_subselect(self, parsed):
        if not parsed.is_group:
            return False
        for item in parsed.tokens:
            if item.is_group:
                return self._is_subselect(item)
            elif item.ttype is DML and item.value.upper() == 'SELECT':
                return True
        return False

    def _extract_table_identifiers(self, tokens):
        for token in tokens:
            if isinstance(token, IdentifierList):
                for identifier in token.get_identifiers():
                    if identifier.get_real_name():
                        yield identifier.get_real_name()
            elif isinstance(token, Identifier):
                if token.get_real_name():
                    yield token.get_real_name()

    def _extract_from_part(self, parsed):
        i = 0
        while i < len(parsed.tokens):
            token = parsed.tokens[i]
            if(token.is_group):
                for result in self._extract_from_part(token):
                    yield result
            if token.ttype is Keyword and token.value.upper() in ["FROM", "JOIN", "INNER JOIN", "LEFT JOIN", "RIGHT JOIN", "FULL JOIN", "EXEC", "EXECUTE", "CALL"]:
                i += 1
                while i < len(parsed.tokens) and (parsed.tokens[i].ttype is Whitespace or parsed.tokens[i].ttype is Punctuation):
                    i += 1
                if i < len(parsed.tokens):
                    next_token = parsed.tokens[i]
                    if self._is_subselect(next_token):
                        for result in self._extract_from_part(next_token):
                            yield result
                    else:
                        yield next_token
            i += 1
    
    def extract_related_objects(self):
        stream = self._extract_from_part(self.parse)
        return list(self._extract_table_identifiers(stream))
