FROM postgres:9.6

RUN mkdir -p /docker-entrypoint-initdb.d

# Script de inicialização que cria a extensão pgcrypto automaticamente
RUN echo "CREATE EXTENSION IF NOT EXISTS pgcrypto;" > /docker-entrypoint-initdb.d/init-pgcrypto.sql
