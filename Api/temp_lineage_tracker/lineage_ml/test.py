import pandas as pd
import numpy as np

from sklearn.model_selection import RandomizedSearchCV

from itertools import permutations
from collections import defaultdict
from sqlalchemy import create_engine
from sklearn.ensemble import RandomForestClassifier
from jellyfish import jaro_winkler_similarity
from true_relationships import true_relationships

param_dist = {
    'reg_alpha': [0, 0.001, 0.005, 0.01, 0.05],
    'reg_lambda': [0.1, 0.5, 1.0, 1.5, 2.0],
    'n_estimators': [100, 200, 300, 400, 500],
    'learning_rate': [0.01, 0.05, 0.1, 0.2, 0.3],
    'max_depth': [5, 6, 7, 8, 9, 10],
    'gamma': [0.1, 0.3, 0.5, 0.7, 1.0, 1.5, 2],
    'subsample': [0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
    'colsample_bytree': [0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
    'early_stopping_rounds': [2, 4, 6, 8, 10, 12, 14]
}


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
                other_table_columns = metadata[metadata['table_name'] == other_table][
                    ['column_name', 'data_type', 'oid']]
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
                    total_average_similarity += (
                                total_similarity / other_columns_compared) if other_columns_compared > 0 else 0
                similarities[table][other_table] = (
                            total_average_similarity / columns_compared) if columns_compared > 0 else 0
        return pd.DataFrame(similarities)

    def _analyze_column_idx(self, metadata):
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
        X, y, pairs = self._prepare_training_data(metadata, table_names_similarities, table_columns_similarities,
                                                  table_idx_similarities)

        weights = np.array([0.55, 0.3, 0.15])
        X_weighted = X * weights

        param_dist = {
            'n_estimators': [50, 100, 150, 200, 250, 300, 350, 400, 500, 1000],
            'min_samples_split': [5, 10, 15, 20, 25, 30, 50, 70, 100],
            'min_samples_leaf': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            'max_depth': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
            'bootstrap': [True, False],
            'max_features': ['auto', 'sqrt', 'log2', None],
            'criterion': ['gini', 'entropy']
        }

        random_search = RandomizedSearchCV(RandomForestClassifier(random_state=23), param_distributions=param_dist,
                                           n_iter=10, cv=5, random_state=23, n_jobs=-1)
        random_search.fit(X_weighted, y)

        print("Best parameters:", random_search.best_params_)

        # importances = model.feature_importances_
        # std = np.std([tree.feature_importances_ for tree in model.estimators_], axis=0)
        #
        # feature_names = ["table_name_similarity", "columns_name_similarity", "idx_similarity"]
        # forest_importances = pd.Series(importances, index=feature_names)
        #
        # fig, ax = plt.subplots()
        # forest_importances.plot.bar(yerr=std, ax=ax)
        # ax.set_title("Feature importances using MDI")
        # ax.set_ylabel("Mean decrease in impurity")
        # fig.tight_layout()

        return X

manager = ModelManager()
X = manager.train_model()

