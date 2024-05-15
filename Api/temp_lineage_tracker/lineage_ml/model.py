import pickle
import numpy as np
import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt
from itertools import permutations
from collections import defaultdict
from sqlalchemy import create_engine
from sklearn.metrics import accuracy_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from Levenshtein import distance as levenshtein_distance


true_relationships = {
    ('products', 'categories'): 1,
    ('orders', 'users'): 1,
    ('order_details', 'orders'): 1,
    ('order_details', 'products'): 1,
    ('payments', 'orders'): 1,
    ('addresses', 'users'): 1,
    ('reviews', 'products'): 1,
    ('reviews', 'users'): 1,
    ('carts', 'users'): 1,
    ('cart_products', 'carts'): 1,
    ('cart_products', 'products'): 1,
    ('supplier_products', 'suppliers'): 1,
    ('supplier_products', 'products'): 1,
    ('order_history', 'orders'): 1,
    ('payment_history', 'payments'): 1,
    ('review_history', 'reviews'): 1,
    ('returns', 'orders'): 1,
    ('complaints', 'products'): 1,
    ('complaints', 'users'): 1,
    ('related_products', 'products'): 1,
    ('warehouse_products', 'products'): 1,
    ('warehouse_products', 'warehouses'): 1,
    ('employees', 'employee_roles'): 1,
    ('action_logs', 'employees'): 1,
    ('shipments', 'orders'): 1,
    ('shipments', 'shipments'): 1,
    ('shipment_products', 'shipments'): 1,
    ('shipment_products', 'products'): 1,
    ('conversations', 'users'): 1,
    ('messages', 'conversations'): 1,
    ('messages', 'users'): 1,
    ('promotion_products', 'products'): 1,
    ('promotion_products', 'promotion'): 1,
    ('vip_clients', 'users'): 1,
    ('login_history', 'users'): 1,
    ('favorite_products', 'users'): 1,
    ('favorite_products', 'products'): 1,
    ('promotion_calendar', 'promotion'): 1,
    ('notifications', 'users'): 1,
    ('cart_history', 'carts'): 1,
    ('sales_statistics', 'products'): 1,
    ('cart_history', 'cart_history_view'): 1,
    ('carts', 'cart_history_view'): 1,
    ('users', 'cart_history_view'): 1,
    ('action_logs', 'employee_action_logs_view'): 1,
    ('employee_roles', 'employee_action_logs_view'): 1,
    ('employees', 'employee_action_logs_view'): 1,
    ('employee_roles', 'employees_and_roles_view'): 1,
    ('employees', 'employees_and_roles_view'): 1,
    ('favorite_products', 'favorite_products_view'): 1,
    ('products', 'favorite_products_view'): 1,
    ('users', 'favorite_products_view'): 1,
    ('newsletters', 'newsletter_subscribers_view'): 1,
    ('order_details', 'order_details_view'): 1,
    ('products', 'order_details_view'): 1,
    ('order_history', 'order_history_view'): 1,
    ('orders', 'order_history_view'): 1,
    ('payment_history', 'payment_history_view'): 1,
    ('payments', 'payment_history_view'): 1,
    ('complaints', 'product_complaints_view'): 1,
    ('products', 'product_complaints_view'): 1,
    ('users', 'product_complaints_view'): 1,
    ('products', 'product_reviews_view'): 1,
    ('reviews', 'product_reviews_view'): 1,
    ('users', 'product_reviews_view'): 1,
    ('products', 'promotional_products_view'): 1,
    ('promotions', 'promotional_products_view'): 1,
    ('products', 'sales_statistics_view'): 1,
    ('sales_statistics', 'sales_statistics_view'): 1,
    ('products', 'supplier_products_view'): 1,
    ('supplier_products', 'supplier_products_view'): 1,
    ('suppliers', 'supplier_products_view'): 1,
    ('cart_products', 'user_cart_view'): 1,
    ('carts', 'user_cart_view'): 1,
    ('products', 'user_cart_view'): 1,
    ('discount_codes', 'user_discount_codes_view'): 1,
    ('users', 'user_discount_codes_view'): 1,
    ('orders', 'user_orders_view'): 1,
    ('users', 'user_orders_view'): 1,
    ('orders', 'user_returns_view'): 1,
    ('returns', 'user_returns_view'): 1,
    ('users', 'user_returns_view'): 1,
    ('users', 'vip_clients_view'): 1,
    ('vip_clients', 'vip_clients_view'): 1,
    ('products', 'warehouse_products_view'): 1,
    ('warehouse_products', 'warehouse_products_view'): 1,
    ('warehouses', 'warehouse_products_view'): 1,
    ('add_user_and_cart', 'create_cart_for_user'): 1,
    ('get_promotional_products_with_suppliers', 'products'): 1,
    ('get_promotional_products_with_suppliers', 'promotion_products'): 1,
    ('get_promotional_products_with_suppliers', 'promotions'): 1,
    ('get_promotional_products_with_suppliers', 'supplier_products'): 1,
    ('get_promotional_products_with_suppliers', 'suppliers'): 1
}

def predict_relationships(model, X_test, pairs):
    predictions = []
    for index, x in enumerate(X_test):
        prediction = model.predict([[x[0], x[1]]])[0]
        if prediction:
            predictions.append(pairs[index])
    return predictions

def visualize_relationships(predicted_relationships):
    G = nx.Graph()
    for (table1, table2) in predicted_relationships:
        G.add_edge(table1, table2)
    pos = nx.spring_layout(G)
    plt.figure(figsize=(12, 12))
    nx.draw(G, pos, with_labels=True, node_size=30, node_color="skyblue", font_size=5, font_color="black", font_weight="bold")
    plt.show()


class ModelManager:
    def __init__(self, database_uri='postgresql+psycopg2://postgres:postgres@localhost:5432/online_store'):
        self.database_uri = database_uri
        self.engine = create_engine(database_uri)
        self.model = None

    def _get_metadata(self):
        query = """
            SELECT table_name, column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = 'public'
        """
        return pd.read_sql(query, self.engine)

    def _analyze_table_names(self, metadata):
        table_names = metadata['table_name'].unique()
        n = len(table_names)
        levenshtein_matrix = [[0] * n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                if i != j:
                    levenshtein_matrix[i][j] = levenshtein_distance(table_names[i], table_names[j])
        return pd.DataFrame(levenshtein_matrix, index=table_names, columns=table_names)

    def _analyze_column_names(self, metadata):
        similarities = defaultdict(dict)
        tables = metadata['table_name'].unique()
        for table in tables:
            table_columns = metadata[metadata['table_name'] == table][['column_name', 'data_type']]
            for other_table in tables:
                if table == other_table:
                    similarities[table][other_table] = 1.0
                    continue
                other_table_columns = metadata[metadata['table_name'] == other_table][['column_name', 'data_type']]
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

    def _prepare_training_data(self, metadata, name_similarities, columns_similarities, true_relationships):
        X = []
        y = []
        table_names = metadata['table_name'].unique()
        pairs = list(permutations(table_names, 2))
        for pair in pairs:
            label = true_relationships.get(pair, 0)
            idx1 = name_similarities.index.get_loc(pair[0])
            idx2 = name_similarities.columns.get_loc(pair[1])
            name_similarity = name_similarities.iloc[idx1, idx2]
            columns_similarity = columns_similarities.iloc[idx1, idx2]
            X.append([name_similarity, columns_similarity])
            y.append(label)
        return np.array(X), np.array(y), pairs

    def train_model(self, true_relationships):
        metadata = self._get_metadata()
        table_name_similarities = self._analyze_table_names(metadata)
        table_columns_similarities = self._analyze_column_names(metadata)
        X, y, pairs = self._prepare_training_data(metadata, table_name_similarities, table_columns_similarities,
                                              true_relationships)
        X_train, X_test, y_train, y_test, _, pairs_test = train_test_split(X, y, pairs, test_size=0.3, random_state=42)
        self.model = RandomForestClassifier()
        self.model.fit(X_train, y_train)
        y_pred = self.model.predict(X_test)
        accuracy = accuracy_score(y_test, y_pred)
        print(f"Accuracy: {accuracy}")

        return X_test, pairs_test

    def save_model(self, filepath):
        if self.model:
            with open(filepath, 'wb') as f:
                pickle.dump(self.model, f)
        else:
            print("Model has not been trained yet.")
    
    def load_model(filepath):
        with open(filepath, 'rb') as f:
            return pickle.load(f)
    

# manager = ModelManager()
# X_test, pairs_test = manager.train_model(true_relationships)
# manager.save_model('Api/temp_lineage_tracker/lineage_ml/models/forest.pkl')

# predicted_relationships = predict_relationships(manager.model, X_test, pairs_test)
# visualize_relationships(predicted_relationships)

# loaded_model = ModelManager.load_model('Api/temp_lineage_tracker/lineage_ml/models/forest.pkl')
# predicted_relationships = predict_relationships(loaded_model, X_test, pairs_test)
# visualize_relationships(predicted_relationships)
