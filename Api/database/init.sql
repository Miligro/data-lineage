CREATE TABLE databases (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE objects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    database_id INT NOT NULL,
    FOREIGN KEY (database_id) REFERENCES databases(id)
);

CREATE TABLE object_relationships (
    id SERIAL PRIMARY KEY,
    database_id INT NOT NULL,
    source_object_id INT NOT NULL,
    target_object_id INT NOT NULL,
    connection_probability FLOAT CHECK (connection_probability >= 0 AND connection_probability <= 1),
    FOREIGN KEY (database_id) REFERENCES databases(id),
    FOREIGN KEY (source_object_id) REFERENCES objects(id),
    FOREIGN KEY (target_object_id) REFERENCES objects(id),
    UNIQUE (database_id, source_object_id, target_object_id)
);

CREATE TABLE object_details (
    id SERIAL PRIMARY KEY,
    database_id INT NOT NULL,
    object_id INT NOT NULL,
    column_name VARCHAR(255) NOT NULL,
    column_type VARCHAR(255) NOT NULL,
    FOREIGN KEY (database_id) REFERENCES databases(id),
    FOREIGN KEY (object_id) REFERENCES objects(id),
    UNIQUE (database_id, object_id, column_name)
);