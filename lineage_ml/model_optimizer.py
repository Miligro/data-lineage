import pandas as pd
import numpy as np
import csv
import time
from sklearn.model_selection import RandomizedSearchCV

from itertools import permutations
from collections import defaultdict
from sqlalchemy import create_engine
from sklearn.ensemble import RandomForestClassifier
from jellyfish import jaro_winkler_similarity
from true_relationships import true_relationships


param_dist = {
    'n_estimators': [50, 100, 150, 200, 250, 300, 350, 400, 500, 1000],
    'min_samples_split': [5, 10, 15, 20, 25, 30, 50, 70, 100],
    'min_samples_leaf': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    'max_depth': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    'bootstrap': [True, False],
    'max_features': ['auto', 'sqrt', 'log2', None],
    'criterion': ['gini', 'entropy']
}


def get_metadata(engine):
    query = """
        SELECT
            cols.table_name as table_name,
            cols.column_name as column_name,
            cols.data_type as data_type,
            cls.oid as oid
        FROM
            information_schema.columns AS cols
        JOIN
            pg_class AS cls
        ON
            cols.table_name = cls.relname
        WHERE
            cols.table_schema NOT IN ('information_schema', 'pg_catalog');
    """
    with engine.connect() as connection:
        return pd.read_sql(query, con=connection.connection)

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
                similarities[table][other_table] = -1
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
                total_average_similarity += (total_similarity/other_columns_compared) if other_columns_compared > 0 else 0
            similarities[table][other_table] = (total_average_similarity / columns_compared) if columns_compared > 0 else 0
    return pd.DataFrame(similarities)


def analyze_column_idx(metadata):
    similarities = defaultdict(dict)
    tables = metadata['table_name'].unique()
    for table in tables:
        table_columns = metadata[metadata['table_name'] == table][['column_name', 'data_type', 'oid']]
        for other_table in tables:
            idx_similarities = 0
            for col in table_columns['column_name']:
                if jaro_winkler_similarity(col, other_table) > 0.8:
                    idx_similarities += 1
            similarities[table][other_table] = idx_similarities
    return pd.DataFrame(similarities)


def prepare_training_data(metadata, name_similarities, columns_similarities, idx_similarities):
    X = []
    y = []
    table_names = metadata['table_name'].unique()
    pairs = list(permutations(table_names, 2))
    compared_pairs = []
    for pair in pairs:
        if (metadata[metadata['table_name'] == pair[0]].iloc[0]['oid'] <
                metadata[metadata['table_name'] == pair[1]].iloc[0]['oid']):
            compared_pairs.append(pair)
            label = true_relationships.get(pair, 0)
            idx1 = columns_similarities.index.get_loc(pair[0])
            idx2 = columns_similarities.columns.get_loc(pair[1])
            name_similarity = name_similarities.iloc[idx1, idx2]
            columns_similarity = columns_similarities.iloc[idx1, idx2]
            idx_similarity = idx_similarities.iloc[idx1, idx2]
            X.append([name_similarity, columns_similarity, idx_similarity])
            y.append(label)
    return np.array(X), np.array(y), compared_pairs


def prepare_test_data(metadata, name_similarities, columns_similarities, idx_similarities):
    table_names = metadata['table_name'].unique()
    pairs = list(permutations(table_names, 2))

    X_pred = []
    pairs_pred = []

    for pair in pairs:
        if (metadata[metadata['table_name'] == pair[0]].iloc[0]['oid'] <
                metadata[metadata['table_name'] == pair[1]].iloc[0]['oid']):
            pairs_pred.append(pair)
            idx1 = columns_similarities.index.get_loc(pair[0])
            idx2 = columns_similarities.columns.get_loc(pair[1])
            name_similarity = name_similarities.iloc[idx1, idx2]
            columns_similarity = columns_similarities.iloc[idx1, idx2]
            idx_similarity = idx_similarities.iloc[idx1, idx2]
            X_pred.append([name_similarity, columns_similarity, idx_similarity])
    return np.array(X_pred), pairs_pred


def predict_relationships(model, X, pairs):
    predictions = defaultdict(dict)
    for index, x in enumerate(X):
        probability = model.predict_proba([x])[0][1]
        predictions[pairs[index]] = probability
    return predictions


def generate_weights():
    precision = 0.03
    weights = np.arange(0, 1 + precision, precision)
    generated_weights = []

    for w1 in weights:
        if w1 < 0.42 or w1 > 0.5:
            continue
        for w2 in weights:
            if w2 == 0 or w2 > 0.7:
                continue
            w3 = 1 - (w1 + w2)
            if 0 < w3 < 0.7:
                generated_weights.append(np.array([round(w1, 2), round(w2, 2), round(w3, 2)]))
    return generated_weights

# Training
database_uri='postgresql+psycopg2://postgres:postgres@localhost:5435/finance'
engine = create_engine(database_uri)

metadata = get_metadata(engine)
table_names_similarities = analyze_table_names(metadata)
table_columns_similarities = analyze_column_names(metadata)
table_idx_similarities = analyze_column_idx(metadata)
x, y, pairs = prepare_training_data(metadata, table_names_similarities, table_columns_similarities,
                                    table_idx_similarities)

# Testing
test_database_uri='postgresql+psycopg2://postgres:postgres@localhost:5434/healthcare'
test_engine = create_engine(test_database_uri)

test_metadata = get_metadata(test_engine)
test_tables_names_similarities = analyze_table_names(test_metadata)
test_columns_names_similarities = analyze_column_names(test_metadata)
test_table_idx_similarities = analyze_column_idx(test_metadata)

X_test, pred_pairs = prepare_test_data(
    test_metadata,
    test_tables_names_similarities,
    test_columns_names_similarities,
    test_table_idx_similarities)


with open('predictions.csv', mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Weights', 'Params', 'Pair', 'Probability'])
    for weights in generate_weights():
        X_weighted = x * weights

        random_search = RandomizedSearchCV(RandomForestClassifier(random_state=23), param_distributions=param_dist,
                                           n_iter=10, cv=5, random_state=23, n_jobs=-1)
        random_search.fit(X_weighted, y)

        predictions = predict_relationships(random_search.best_estimator_, X_test, pred_pairs)

        pairs_to_check = [
            ('staff', 'staff_first_shift'),
            ('shifts', 'staff_first_shift'),
            ('departments', 'staff_first_shift')
        ]

        weights_str = np.array2string(weights, separator=',')
        params_str = str(random_search.best_params_)

        for pair in pairs_to_check:
            probability = predictions.get(pair, "Pair not found")
            writer.writerow([weights_str, params_str, pair, probability])
