import pickle
import pandas as pd
from collections import defaultdict
from jellyfish import jaro_winkler_similarity


def analyze_table_names(metadata):
    similarities = defaultdict(dict)
    table_names = metadata['table_name'].unique()
    for tab in table_names:
        for other_tab in table_names:
            if tab == other_tab:
                similarities[tab][other_tab] = 1.0
                continue
            similarities[tab][other_tab] = round(jaro_winkler_similarity(tab, other_tab), 3)
    return pd.DataFrame(similarities)


def analyze_column_names(metadata):
    similarities = defaultdict(dict)
    tables = metadata['table_name'].unique()
    for table in tables:
        table_columns = metadata[metadata['table_name'] == table][['column_name', 'data_type', 'oid']]
        for other_table in tables:
            if table == other_table:
                similarities[table][other_table] = -1.0
                continue
            other_table_columns = metadata[metadata['table_name'] == other_table][['column_name', 'data_type', 'oid']]
            total_average_similarity = 0
            columns_compared = 0
            for col in table_columns['column_name']:
                if "id" in col:
                    continue
                columns_compared += 1
                total_similarity = 0
                other_columns_compared = 0
                for other_col in other_table_columns['column_name']:
                    if "id" in other_col:
                        continue
                    other_columns_compared += 1
                    total_similarity += jaro_winkler_similarity(col, other_col)
                total_average_similarity += total_similarity / other_columns_compared if other_columns_compared > 0 else 0
            similarities[table][other_table] = total_average_similarity / columns_compared if columns_compared > 0 else 0
    return pd.DataFrame(similarities)


def analyze_column_idx(metadata):
    similarities = defaultdict(dict)
    tables = metadata['table_name'].unique()
    for table in tables:
        table_columns = metadata[metadata['table_name'] == table][['column_name', 'data_type', 'oid']]
        for other_table in tables:
            idx_similarities = 0
            for col in table_columns['column_name']:
                if jaro_winkler_similarity(col, other_table) > 0.9:
                    idx_similarities += 1
            similarities[table][other_table] = idx_similarities
    return pd.DataFrame(similarities)


def predict_relationships(model, X, pairs):
    predictions = []
    for index, x in enumerate(X):
        probability = model.predict_proba([x])[0][1]
        predictions.append((pairs[index], probability))
    return predictions


def load_model(filepath):
    with open(filepath, 'rb') as f:
        return pickle.load(f)
