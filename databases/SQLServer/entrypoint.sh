#!/bin/bash

/opt/mssql/bin/sqlservr &

echo "Waiting for SQL Server to start..."
until /opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "Sqlserver123" -Q "SELECT 1" > /dev/null 2>&1; do
    echo "SQL Server is not ready yet. Waiting..."
    sleep 5
done

/opt/mssql-tools18/bin/sqlcmd -S localhost -U SA -P "Sqlserver123" -i /usr/config/init.sql

wait