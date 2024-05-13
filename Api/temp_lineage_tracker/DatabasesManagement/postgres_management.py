import psycopg2
from .related_objects_extractor import SQLParser


class PostgresDatabaseManagement:
    def __init__(self, host, dbname, user, password, port=5431):
        self.host = host
        self.dbname = dbname
        self.user = user
        self.password = password
        self.port = port
        self.conn = None

    def connect(self):
        self.conn = psycopg2.connect(
            host=self.host,
            dbname=self.dbname,
            user=self.user,
            password=self.password,
            port=self.port
        )
        print("Connected to the database - PostgreSQL.")

    def close(self):
        if self.conn:
            self.conn.close()
            print("Database connection closed.")
    
    def check_extension_installed(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables
                    WHERE table_name IN (
                        'system_operations_with_query',
                        'system_operations_with_dependencies'
                    )
                ) AND EXISTS (
                    SELECT FROM pg_proc
                    WHERE proname IN (
                        'handle_create_table_as_function',
                        'handle_create_view_function'
                    )
                );
            """)
            result = cur.fetchone()
            return all(result)

    def fetch_table_metadata(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    table_schema,
                    table_name,
                    column_name,
                    data_type,
                    is_nullable,
                    column_default
                FROM
                    information_schema.columns
                WHERE
                    table_schema NOT IN ('information_schema', 'pg_catalog');
            """)
            return cur.fetchall()

    def fetch_table_constraints(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    tc.constraint_name,
                    tc.table_schema,
                    tc.table_name,
                    kcu.column_name,
                    tc.constraint_type
                FROM 
                    information_schema.table_constraints AS tc 
                    JOIN information_schema.key_column_usage AS kcu 
                    ON tc.constraint_name = kcu.constraint_name
                    AND tc.table_schema = kcu.table_schema
                WHERE
                    tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY', 'UNIQUE')
                    AND tc.table_schema NOT IN ('information_schema', 'pg_catalog');
            """)
            return cur.fetchall()

    def fetch_view_dependencies(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    view_schema,
                    view_name,
                    table_schema,
                    table_name
                FROM
                    information_schema.view_table_usage
                WHERE
                    view_schema NOT IN ('information_schema', 'pg_catalog');
            """)
            return cur.fetchall()

    def fetch_stored_procedures(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    routine_schema,
                    routine_name,
                    data_type,
                    routine_definition
                FROM
                    information_schema.routines
                WHERE
                    routine_schema NOT IN ('pg_catalog', 'information_schema')
                    AND routine_type='PROCEDURE';
            """)
            return cur.fetchall()
    
    def fetch_system_operations(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT
                    operation_type,
                    obj_name,
                    obj_parent
                FROM
                    system_operations_with_dependencies;
            """)
            return cur.fetchall()
    
    def create_system_operations_with_query_table(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS system_operations_with_query (
                    id SERIAL PRIMARY KEY,
                    operation_type VARCHAR(255),
                    obj_name VARCHAR(255),
                    query TEXT,
                    UNIQUE(operation_type, obj_name, query)
                )
            """)
        self.conn.commit()

    def create_system_operations_with_dependencies(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS system_operations_with_dependencies (
                    id SERIAL PRIMARY KEY,
                    operation_type VARCHAR(255),
                    obj_name VARCHAR(255),
                    obj_parent VARCHAR(255),
                    UNIQUE(operation_type, obj_name, obj_parent)
                )
            """)
        self.conn.commit()
        
    def handle_create_table_as_function(self):
            with self.conn.cursor() as cur:
                cur.execute("""
                    CREATE OR REPLACE FUNCTION handle_create_table_as_function()
                    RETURNS event_trigger AS $$
                    DECLARE
                        query_text text;
                        name text;
                        ddl_command RECORD;
                    BEGIN
                        EXECUTE 'SELECT current_query()' INTO query_text;

                        SELECT * INTO ddl_command FROM pg_event_trigger_ddl_commands() WHERE command_tag = 'CREATE TABLE AS';
                        IF ddl_command IS NOT NULL THEN
                            name := split_part(ddl_command.object_identity, '.', 2);
                            INSERT INTO system_operations_with_query (operation_type, obj_name, query) VALUES ('CREATE TABLE', name, query_text);
                        END IF;
                    END;
                    $$ LANGUAGE plpgsql;
                """)
            self.conn.commit()

    def create_table_as_trigger(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                CREATE EVENT TRIGGER create_table_as_trigger
                ON ddl_command_end
                WHEN tag IN ('CREATE TABLE AS')
                EXECUTE FUNCTION handle_create_table_as_function();
            """)
        self.conn.commit()
    
    def create_view_trigger(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                CREATE EVENT TRIGGER create_view_trigger
                ON ddl_command_end
                WHEN tag IN ('CREATE VIEW')
                EXECUTE FUNCTION handle_create_view_function();
            """)
        self.conn.commit()

    def handle_create_view_function(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                CREATE OR REPLACE FUNCTION handle_create_view_function()
                RETURNS event_trigger AS $$
                DECLARE
                    query_text text;
                    name text;
                    ddl_command RECORD;
                BEGIN
                    EXECUTE 'SELECT current_query()' INTO query_text;

                    SELECT * INTO ddl_command FROM pg_event_trigger_ddl_commands() WHERE command_tag = 'CREATE VIEW';
                    IF ddl_command IS NOT NULL THEN
                        name := split_part(ddl_command.object_identity, '.', 2);
                        INSERT INTO system_operations_with_query (operation_type, obj_name, query) VALUES ('CREATE VIEW', name, query_text);
                    END IF;
                END;
                $$ LANGUAGE plpgsql;
            """)
        self.conn.commit()
    
    def operations_with_query_to_dependencies(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT operation_type, obj_name, query FROM system_operations_with_query;
            """)
            rows = cur.fetchall()
            for row in rows:
                self._extract_tables_from_queries(row)
            cur.execute("""
                DELETE FROM system_operations_with_query;
            """)
        self.conn.commit()
    
    def _extract_tables_from_queries(self, row):
        with self.conn.cursor() as cur:
            query_text = row[2]
            parser = SQLParser(query_text)
            objects = parser.extract_related_objects()
            for obj in objects:
                if obj != row[1]:
                    cur.execute("""
                        INSERT INTO system_operations_with_dependencies (operation_type, obj_name, obj_parent)
                        SELECT %s, %s, %s
                        WHERE NOT EXISTS (
                            SELECT 1 FROM system_operations_with_dependencies
                            WHERE operation_type = %s AND obj_name = %s AND obj_parent = %s
                        );
                    """, (row[0], row[1], obj, row[0], row[1], obj))
        self.conn.commit()
    
    # Test function - to be removed later
    def create_customer_finance_summary(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                CREATE TEMP TABLE extended_customer_finance_temp AS
                SELECT 
                    catv.customer_id,
                    catv.first_name,
                    catv.last_name,
                    catv.ssn,
                    catv.address,
                    catv.phone_number,
                    catv.email_address,
                    catv.account_number,
                    catv.account_type,
                    catv.balance,
                    catv.transaction_id,
                    catv.sender_account_number,
                    catv.receiver_account_number,
                    catv.amount,
                    catv.transaction_date,
                    catv.transaction_description,
                    l.loan_id,
                    l.loan_amount,
                    l.repayment_period,
                    l.interest_rate,
                    l.loan_date,
                    l.loan_status
                FROM customer_account_transactions_view catv
                LEFT JOIN loans l ON catv.customer_id = l.customer_id;
            """)
            
            cur.execute("""
                CREATE TABLE customer_finance_summary AS
                SELECT
                    customer_id,
                    first_name,
                    last_name,
                    COUNT(DISTINCT account_number) AS number_of_accounts,
                    SUM(balance) AS total_balance,
                    SUM(CASE WHEN loan_status = 'Active' THEN loan_amount ELSE 0 END) AS total_active_loans,
                    SUM(amount) AS total_transactions_value,
                    MAX(transaction_date) AS last_transaction_date
                FROM extended_customer_finance_temp
                GROUP BY customer_id, first_name, last_name;
            """)

            cur.execute("""
                CREATE OR REPLACE PROCEDURE calculate_and_update_total_balances()
                LANGUAGE plpgsql
                AS $$
                BEGIN
                    DELETE FROM customer_total_balances;
                    INSERT INTO customer_total_balances(customer_id, total_balance)
                    SELECT customer_id, SUM(balance)
                    FROM bank_accounts
                    GROUP BY customer_id;
                END;
                $$;
            """)
        self.conn.commit()

    # Test function - to be removed later
    def create_temp_customer_loan_summary_table(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                CREATE TEMP VIEW customer_loan_summary_view_temp AS
                SELECT
                    c.customer_id,
                    c.first_name,
                    c.last_name,
                    SUM(l.loan_amount) AS total_loan_amount,
                    COUNT(l.loan_id) AS number_of_loans
                FROM customers c
                LEFT JOIN loans l ON c.customer_id = l.customer_id
                GROUP BY c.customer_id, c.first_name, c.last_name;
            """)

            cur.execute("""
                CREATE TEMP TABLE customer_loan_summary_table AS
                SELECT
                    customer_id,
                    first_name,
                    last_name,
                    total_loan_amount,
                    number_of_loans
                FROM customer_loan_summary_view_temp;
            """)

        self.conn.commit()
