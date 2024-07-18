import pickle
import numpy as np
import pandas as pd
import xgboost as xgb

from itertools import permutations
from collections import defaultdict
from sqlalchemy import create_engine
from true_relationships import true_relationships
from jellyfish import jaro_winkler_similarity
from sklearn.ensemble import  RandomForestClassifier


def predict_relationships(model, X_test, pairs):
    predictions = []
    for index, x in enumerate(X_test):
        probability = model.predict_proba([x])[0][1]
        predictions.append((pairs[index], probability))
    return predictions


class ModelManager:
    def __init__(self, database_uri='postgresql+psycopg2://postgres:postgres@localhost:5435/finance'):
        self.database_uri = database_uri
        self.engine = create_engine(database_uri)
        self.model = None

    def _get_metadata(self):
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
        with self.engine.connect() as connection:
            return pd.read_sql(query, con=connection.connection)

    def _analyze_table_names(self, metadata):
        similarities = defaultdict(dict)
        table_names = metadata['table_name'].unique()
        for tab in table_names:
            for other_tab in table_names:
                if tab == other_tab:
                    similarities[tab][other_tab] = 1.0
                    continue
                similarities[tab][other_tab] = round(jaro_winkler_similarity(tab, other_tab), 3)
        return pd.DataFrame(similarities)

    def _analyze_column_names(self, metadata):
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

    def _analyze_column_idx(self, metadata):
        similarities = defaultdict(dict)
        tables = metadata['table_name'].unique()
        for table in tables:
            table_columns = metadata[metadata['table_name'] == table][['column_name', 'data_type', 'oid']]
            for other_table in tables:
                idx_similarities = 0
                for col in table_columns['column_name']:
                    if jaro_winkler_similarity(col, other_table) > 0.90:
                        idx_similarities += 1
                similarities[table][other_table] = idx_similarities
        return pd.DataFrame(similarities)

    def _prepare_training_data(self, metadata, name_similarities, columns_similarities, idx_similarities):
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

    def train_model(self):
        metadata = self._get_metadata()
        table_names_similarities = self._analyze_table_names(metadata)
        table_columns_similarities = self._analyze_column_names(metadata)
        table_idx_similarities = self._analyze_column_idx(metadata)
        x, y, pairs = self._prepare_training_data(metadata, table_names_similarities, table_columns_similarities,
                                                  table_idx_similarities)

        weights = np.array([0.72, 0.03, 0.25])
        X_weighted = x * weights

        self.model = RandomForestClassifier(n_estimators=200, min_samples_split=200, min_samples_leaf=10, max_depth=14,
                                            max_features='log2', criterion='gini', bootstrap=False)

        # self.model = xgb.XGBClassifier(subsample=1.0, n_estimators=300, min_child_weight=10, max_depth=10,
        #                                learning_rate=0.01, colsample_bytree=0.6)

        self.model.fit(X_weighted, y)

    def save_model(self, filepath):
        if self.model:
            with open(filepath, 'wb') as f:
                pickle.dump(self.model, f)
        else:
            print("Model has not been trained yet.")

    def load_model(filepath):
        with open(filepath, 'rb') as f:
            return pickle.load(f)


manager = ModelManager()
manager.train_model()
manager.save_model('models/forest.pkl')
