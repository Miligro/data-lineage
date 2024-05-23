FROM mcr.microsoft.com/mssql/server:2022-latest

# Ustawienie użytkownika na root
USER root

# Tworzenie katalogu konfiguracyjnego i ustawienie go jako bieżącego katalogu roboczego
RUN mkdir -p /usr/config
WORKDIR /usr/config

# Kopiowanie skryptów SQL i startowego do katalogu konfiguracyjnego
# i ustawienie uprawnień do wykonania
COPY test-database-init.sql /usr/config/init.sql
COPY entrypoint.sh /usr/config/entrypoint.sh
RUN chmod +x /usr/config/entrypoint.sh

# Ustawienie entrypoint.sh jako punktu wejściowego
ENTRYPOINT ["bash", "/usr/config/entrypoint.sh"]
