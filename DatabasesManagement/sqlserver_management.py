import pyodbc


class SQLServerDatabaseManagement:
    def __init__(self, server, database, username, password, port=1433):
        self.server = server
        self.database = database
        self.username = username
        self.password = password
        self.port = port
        self.conn = None

    def connect(self):
        conn_str = f"DRIVER=ODBC Driver 17 for SQL Server;SERVER={self.server};DATABASE={self.database};UID={self.username};PWD={self.password}"
        try:
            self.conn = pyodbc.connect(conn_str)
        except pyodbc.Error as e:
            print(e)
        print("Connected to the database - SQL Server.")

    def close(self):
        if self.conn:
            self.conn.close()
            print("Database connection closed.")

    def fetch_table_metadata(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    TABLE_SCHEMA,
                    TABLE_NAME,
                    COLUMN_NAME,
                    DATA_TYPE,
                    IS_NULLABLE,
                    COLUMN_DEFAULT
                FROM
                    INFORMATION_SCHEMA.COLUMNS;
            """)
            return cur.fetchall()

    def fetch_table_constraints(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    tc.CONSTRAINT_NAME,
                    tc.TABLE_SCHEMA,
                    tc.TABLE_NAME,
                    kcu.COLUMN_NAME,
                    tc.CONSTRAINT_TYPE
                FROM
                    INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
                    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu
                    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
                    AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA;
            """)
            return cur.fetchall()

    def fetch_view_dependencies(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    VIEW_SCHEMA,
                    VIEW_NAME,
                    TABLE_SCHEMA,
                    TABLE_NAME
                FROM
                    INFORMATION_SCHEMA.VIEW_TABLE_USAGE;
            """)
            return cur.fetchall()

    def fetch_stored_procedures(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    ROUTINE_SCHEMA,
                    ROUTINE_NAME,
                    DATA_TYPE,
                    ROUTINE_DEFINITION
                FROM
                    INFORMATION_SCHEMA.ROUTINES
                WHERE
                    ROUTINE_TYPE='PROCEDURE';
            """)
            return cur.fetchall()

    def create_system_operations_table(self):
        with self.conn.cursor() as cur:
            cur.execute("""SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.system_operations') AND type in (N'U')""")
            exists = cur.fetchone()
            if not exists:
                cur.execute("""
                    CREATE TABLE dbo.system_operations (
                        id INT IDENTITY PRIMARY KEY,
                        operation_type VARCHAR(255),
                        obj_name VARCHAR(255),
                        query VARCHAR(MAX),
                        query_hash VARBINARY(32),
                        UNIQUE(operation_type, obj_name, query_hash)
                    );
                """)
        self.conn.commit()

    def handle_create_table_as_function(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT * FROM sys.objects 
                WHERE object_id = OBJECT_ID(N'dbo.handle_create_table_as_procedure') 
                AND type in (N'P', N'PC')
            """)
            exists = cur.fetchone()
            if not exists:
                cur.execute("""
                    CREATE PROCEDURE handle_create_table_as_procedure
                        @ObjectName VARCHAR(255),
                        @QueryText VARCHAR(MAX)
                    AS
                    BEGIN
                        INSERT INTO system_operations(operation_type, obj_name, query, query_hash) VALUES('CREATE TABLE', @ObjectName, @QueryText, HASHBYTES('SHA2_256', @QueryText));
                    END
                """)
        self.conn.commit()

    def create_table_as_trigger(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT * FROM sys.triggers
                WHERE name = 'create_table_as_trigger'
            """)
            exists = cur.fetchone()
            if not exists:
                cur.execute("""
                    CREATE TRIGGER create_table_as_trigger
                    ON DATABASE
                    FOR CREATE_TABLE
                    AS
                    BEGIN
                        DECLARE @EventData XML = EVENTDATA();
                        DECLARE @ObjectName NVARCHAR(128) = @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(128)');
                        DECLARE @QueryText NVARCHAR(MAX) = @EventData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)');
                        EXEC handle_create_table_as_procedure @ObjectName=@ObjectName, @QueryText = @QueryText
                    END
                """)
        self.conn.commit()

    def handle_create_view_function(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT * FROM sys.objects 
                WHERE object_id = OBJECT_ID(N'dbo.handle_create_view_as_procedure') 
                AND type in (N'P', N'PC')
            """)
            exists = cur.fetchone()
            if not exists:
                cur.execute("""
                    CREATE PROCEDURE handle_create_view_as_procedure
                        @ObjectName VARCHAR(255),
                        @QueryText VARCHAR(MAX)
                    AS
                    BEGIN
                        INSERT INTO system_operations(operation_type, obj_name, query, query_hash) VALUES('CREATE VIEW', @ObjectName, @QueryText, HASHBYTES('SHA2_256', @QueryText));
                    END
                """)
        self.conn.commit()

    def create_view_trigger(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT * FROM sys.triggers
                WHERE name = 'create_view_as_trigger'
            """)
            exists = cur.fetchone()
            if not exists:
                cur.execute("""
                    CREATE TRIGGER create_view_as_trigger
                    ON DATABASE
                    FOR CREATE_VIEW
                    AS
                    BEGIN
                        DECLARE @EventData XML = EVENTDATA();
                        DECLARE @ObjectName NVARCHAR(128) = @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(128)');
                        DECLARE @QueryText NVARCHAR(MAX) = @EventData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)');
                        EXEC handle_create_view_as_procedure @ObjectName=@ObjectName, @QueryText = @QueryText
                    END
                """)
        self.conn.commit()

    def create_temp_table_extended_event(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT *
                FROM sys.server_event_sessions
                WHERE name = N'MonitorCreateTable'
            """)
            exists = cur.fetchone()
            if not exists:
                cur.execute("""
                    CREATE EVENT SESSION [MonitorCreateTable] ON SERVER
                    ADD EVENT sqlserver.object_created
                    (
                        ACTION(sqlserver.sql_text)
                        WHERE sqlserver.database_name = N'bank' AND
                        (
                            (sqlserver.sql_text LIKE '%CREATE%TABLE%#[a-z, A-Z, 0-9]%' AND
                             sqlserver.sql_text NOT LIKE '%CREATE%TABLE%##%') OR
                            (sqlserver.sql_text LIKE '%SELECT%INTO%#%' AND
                             sqlserver.sql_text NOT LIKE '%INTO%#@%' AND
                             sqlserver.sql_text NOT LIKE '%INTO%##%')
                        )
                    )
                    ADD TARGET package0.event_file(SET filename=N'EventFile.xel', max_file_size=(51200))
                    WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB, MEMORY_PARTITION_MODE=NONE, TRACK_CAUSALITY=ON, STARTUP_STATE=OFF);
                """)
                cur.execute("""
                    ALTER EVENT SESSION [MonitorCreateTable] ON SERVER STATE = START;
                """)
        self.conn.commit()

    def insert_from_events_file(self):
        with self.conn.cursor() as cur:
            cur.execute("""
            INSERT INTO system_operations (operation_type, obj_name, query, query_hash)
            SELECT
                DISTINCT 'CREATE TABLE',
                event_data.value( '(event/data[@name="object_name"]/value)[1]', 'nvarchar(255)' ) AS object_name,
                event_data.value( '(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)' ) AS query,
                HASHBYTES('SHA2_256', event_data.value( '(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)' )) as query_hash
            FROM
                (SELECT CAST(event_data AS XML) AS event_data
                 FROM sys.fn_xe_file_target_read_file('EventFile*.xel', NULL, NULL, NULL)) AS tab
            WHERE NOT EXISTS (
                SELECT 1 FROM system_operations WHERE
                operation_type = 'CREATE TABLE' AND
                obj_name = event_data.value('(event/data[@name="object_name"]/value)[1]', 'nvarchar(255)') AND
                query_hash = HASHBYTES('SHA2_256', event_data.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)'))
            );
            """)


