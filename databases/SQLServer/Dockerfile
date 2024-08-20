FROM mcr.microsoft.com/mssql/server:2022-latest

USER root

RUN mkdir -p /usr/config
WORKDIR /usr/config

COPY test-database-init.sql /usr/config/init.sql
COPY entrypoint.sh /usr/config/entrypoint.sh
RUN chmod +x /usr/config/entrypoint.sh

ENTRYPOINT ["bash", "/usr/config/entrypoint.sh"]
