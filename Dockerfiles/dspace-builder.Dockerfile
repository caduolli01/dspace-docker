FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    apt-get install -y --no-install-recommends \
        wget \
        openjdk-8-jdk-headless \
        maven \
        ant \
        unzip \
        git \
        postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

WORKDIR /build

# Baixa e extrai o DSpace 6.3
RUN wget https://github.com/DSpace/DSpace/releases/download/dspace-6.3/dspace-6.3-src-release.tar.gz && \
    tar -zxf dspace-6.3-src-release.tar.gz && \
    rm dspace-6.3-src-release.tar.gz

WORKDIR /build/dspace-6.3-src-release

# Compila o DSpace
RUN mvn -U package && rm -rf ~/.m2/repository

# Atualiza a configuração do banco no dspace.cfg
RUN sed -i "s|^db.url = .*|db.url = jdbc:postgresql://postgres-dspace:5432/dspace|" \
    /build/dspace-6.3-src-release/dspace/target/dspace-installer/config/dspace.cfg

# Script de entrada do container
ENTRYPOINT ["sh", "-c", "\
  echo 'Esperando o PostgreSQL ficar disponível...'; \
  until pg_isready -h postgres-dspace -U dspace; do \
    echo 'PostgreSQL indisponível, tentando novamente em 2 segundos...'; \
    sleep 2; \
  done; \
  echo 'PostgreSQL disponível! Criando extensão pgcrypto se não existir...'; \
  psql -h postgres-dspace -U dspace -d dspace -c \"CREATE EXTENSION IF NOT EXISTS pgcrypto;\"; \
  echo 'Executando ant fresh_install...'; \
  cd /build/dspace-6.3-src-release/dspace/target/dspace-installer && ant fresh_install; \
  echo 'Instalação concluída! Container rodando...'; \
  tail -f /dev/null"]
