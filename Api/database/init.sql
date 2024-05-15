CREATE TABLE databases (
    database_id SERIAL PRIMARY KEY,
    database_name VARCHAR(255) NOT NULL
);

CREATE TABLE objects (
    database_id INT NOT NULL,
    object_id SERIAL PRIMARY KEY,
    object_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (database_id) REFERENCES databases(database_id)
);

CREATE TABLE object_relationships (
    database_id INT NOT NULL,
    source_object_id INT NOT NULL,
    target_object_id INT NOT NULL,
    connection_probability FLOAT CHECK (connection_probability >= 0 AND connection_probability <= 1),
    PRIMARY KEY (database_id, source_object_id, target_object_id),
    FOREIGN KEY (database_id) REFERENCES databases(database_id),
    FOREIGN KEY (source_object_id) REFERENCES objects(object_id),
    FOREIGN KEY (target_object_id) REFERENCES objects(object_id)
);

CREATE TABLE object_details (
    database_id INT NOT NULL,
    object_id INT NOT NULL,
    column_name VARCHAR(255) NOT NULL,
    column_type VARCHAR(255) NOT NULL,
    PRIMARY KEY (database_id, object_id, column_name),
    FOREIGN KEY (database_id) REFERENCES databases(database_id),
    FOREIGN KEY (object_id) REFERENCES objects(object_id)
);