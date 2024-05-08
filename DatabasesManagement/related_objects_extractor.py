import sqlparse
from sqlparse.sql import IdentifierList, Identifier
from sqlparse.tokens import Keyword, Whitespace, Punctuation, DML

def is_subselect(parsed):
    if not parsed.is_group:
        return False
    for item in parsed.tokens:
        if item.is_group:
            return is_subselect(item)
        elif item.ttype is DML and item.value.upper() == 'SELECT':
            return True
    return False

def extract_table_identifiers(tokens):
    for token in tokens:
        if isinstance(token, IdentifierList):
            for identifier in token.get_identifiers():
                if identifier.get_real_name():
                    yield identifier.get_real_name()
        elif isinstance(token, Identifier):
            if token.get_real_name():
                yield token.get_real_name()

def extract_from_part(parsed):
    i = 0
    while i < len(parsed.tokens):
        token = parsed.tokens[i]
        if(token.is_group):
            for result in extract_from_part(token):
                yield result
        if token.ttype is Keyword and token.value.upper() in ["FROM", "JOIN", "INNER JOIN", "LEFT JOIN", "RIGHT JOIN", "FULL JOIN"]:
            i += 1
            while i < len(parsed.tokens) and (parsed.tokens[i].ttype is Whitespace or parsed.tokens[i].ttype is Punctuation):
                i += 1
            if i < len(parsed.tokens):
                next_token = parsed.tokens[i]
                if is_subselect(next_token):
                    for result in extract_from_part(next_token):
                        yield result
                else:
                    yield next_token
        i += 1


def extract_related_objects(sql):
    formatted = sqlparse.format(sql, strip_whitespace=True)
    stream = extract_from_part(sqlparse.parse(formatted)[0])
    return list(extract_table_identifiers(stream))
