CREATE TABLE ingest_status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(25) NOT NULL
);

CREATE TABLE databases (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    ingest_status_id INT,
    FOREIGN KEY (ingest_status_id) REFERENCES ingest_status(id) ON DELETE SET NULL
);

CREATE TABLE objects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    database_id VARCHAR(50) NOT NULL,
    FOREIGN KEY (database_id) REFERENCES databases(id) ON DELETE CASCADE
);

CREATE TABLE object_relationships (
    id SERIAL PRIMARY KEY,
    database_id VARCHAR(50) NOT NULL,
    source_object_id INT NOT NULL,
    target_object_id INT NOT NULL,
    connection_probability FLOAT CHECK (connection_probability >= 0 AND connection_probability <= 1),
    FOREIGN KEY (database_id) REFERENCES databases(id) ON DELETE CASCADE,
    FOREIGN KEY (source_object_id) REFERENCES objects(id) ON DELETE CASCADE,
    FOREIGN KEY (target_object_id) REFERENCES objects(id) ON DELETE CASCADE,
    UNIQUE (database_id, source_object_id, target_object_id)
);

CREATE TABLE object_relationships_details (
    id SERIAL PRIMARY KEY,
    database_id VARCHAR(50) NOT NULL,
    relation_id INT NOT NULL,
    column_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (relation_id) REFERENCES object_relationships(id) ON DELETE CASCADE,
    FOREIGN KEY (database_id) REFERENCES databases(id) ON DELETE CASCADE
);

CREATE TABLE object_details (
    id SERIAL PRIMARY KEY,
    database_id VARCHAR(50) NOT NULL,
    object_id INT NOT NULL,
    column_name VARCHAR(255) NOT NULL,
    column_type VARCHAR(255) NOT NULL,
    FOREIGN KEY (database_id) REFERENCES databases(id) ON DELETE CASCADE,
    FOREIGN KEY (object_id) REFERENCES objects(id) ON DELETE CASCADE,
    UNIQUE (database_id, object_id, column_name)
);

INSERT INTO ingest_status VALUES(1, 'Sukces');
INSERT INTO ingest_status VALUES(2, 'Niepowodzenie');
INSERT INTO ingest_status VALUES(3, 'W toku');