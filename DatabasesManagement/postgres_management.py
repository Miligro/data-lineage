import psycopg2


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
                    system_operations;
            """)
            return cur.fetchall()
        
    def handle_create_table_as_function(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                CREATE OR REPLACE FUNCTION handle_create_table_as_function()
                RETURNS event_trigger AS $$
                DECLARE
                    query_text text;
                    name text;
                    parent text;
                BEGIN
                    EXECUTE 'SELECT current_query()' INTO query_text;

                    -- Parsowanie zapytania SQL i wstawienie danych do system_operations
                    name := (SELECT (regexp_matches(query_text, 'CREATE (?:TEMP )?TABLE (\w+)', 'g'))[1]);
                    parent := (SELECT (regexp_matches(query_text, 'FROM (\w+)', 'g'))[1]);
                    INSERT INTO system_operations (operation_type, obj_name, obj_parent) VALUES ('CREATE TABLE', name, parent);

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

    def create_system_operations_table(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS system_operations (
                    id SERIAL PRIMARY KEY,
                    operation_type TEXT,
                    obj_name TEXT,
                    obj_parent TEXT
                )
            """)
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
        self.conn.commit()
