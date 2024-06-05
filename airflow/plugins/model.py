import pickle
import pandas as pd
from collections import defaultdict
from Levenshtein import distance as levenshtein_distance


data_types = ['boolean', 'bytea', 'character', 'date', 'timestamp without time zone', 'numeric', 'double precision',
              'real', 'integer', 'bigint', 'smallint', 'character varying',
              'time without time zone', 'timestamp with time zone']


def analyze_table_names(metadata):
    table_names = metadata['table_name'].unique()
    names_lengths = [len(name) for name in table_names]

    return pd.Series(names_lengths, index=table_names)


def analyze_column_names(metadata):
    similarities = defaultdict(dict)
    tables = metadata['table_name'].unique()
    for table in tables:
        table_columns = metadata[metadata['table_name'] == table][['column_name', 'data_type', 'oid']]
        for other_table in tables:
            if table == other_table:
                similarities[table][other_table] = 1.0
                continue
            other_table_columns = metadata[metadata['table_name'] == other_table][['column_name', 'data_type', 'oid']]
            total_similarity = 0
            comparisons = 0
            for col in table_columns['column_name']:
                for other_col in other_table_columns['column_name']:
                    total_similarity += levenshtein_distance(col, other_col)
                    comparisons += 1
            average_similarity = total_similarity / comparisons if comparisons > 0 else float('inf')
            normalized_similarity = 1 / (1 + average_similarity) if average_similarity != float('inf') else 0
            similarities[table][other_table] = normalized_similarity
    return pd.DataFrame(similarities)


def predict_relationships(model, X_test, pairs):
    predictions = []
    for index, x in enumerate(X_test):
        probability = model.predict_proba([x])[0][1]
        predictions.append((pairs[index], probability))
    return predictions


def analyze_data_type(metadata):
    data_type_counts = metadata.groupby(['table_name', 'data_type']).size().unstack(fill_value=0)
    data_type_counts = data_type_counts.reindex(columns=data_types, fill_value=0)
    return data_type_counts


def load_model(filepath):
    with open(filepath, 'rb') as f:
        return pickle.load(f)