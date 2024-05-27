#!/bin/bash

# Uruchomienie SQL Server w tle
/opt/mssql/bin/sqlservr &

# Czekanie na pełne uruchomienie SQL Server
# Uwaga: 30 sekund to przykładowy czas. Może wymagać dostosowania w zależności od środowiska
sleep 30

# Wykonanie skryptu inicjalizującego
# Uwaga: Załóżmy, że skrypt init.sql znajduje się w /usr/config
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "Sqlserver123" -i /usr/config/init.sql

# Czekanie, aby kontener nie zakończył działania
wait
