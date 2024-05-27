FROM apache/airflow:2.9.1
USER root

COPY requirements.txt .

RUN apt-get update && apt-get install -y \
    build-essential \
    libaio1 \
    wget \
    unzip

RUN mkdir -p /opt/oracle \
    && cd /opt/oracle \
    && wget https://download.oracle.com/otn_software/linux/instantclient/2340000/instantclient-basic-linux.x64-23.4.0.24.05.zip \
    && unzip instantclient-basic-linux.x64-23.4.0.24.05.zip \
    && rm -f instantclient-basic-linux.x64-23.4.0.24.05.zip \
    && ln -s /opt/oracle/instantclient_23_4 /opt/oracle/instantclient \
    && echo /opt/oracle/instantclient > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig


ENV LD_LIBRARY_PATH /opt/oracle/instantclient:$LD_LIBRARY_PATH
ENV ORACLE_HOME /opt/oracle/instantclient

USER airflow

RUN pip install -r requirements.txt

