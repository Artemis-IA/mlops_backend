ARG PG_MAJOR=16
FROM postgres:${PG_MAJOR}

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends make gettext git ca-certificates build-essential postgresql-server-dev-${PG_MAJOR} 

# Clone pgvector repository and install
RUN git clone --branch v0.7.4 https://github.com/pgvector/pgvector.git /tmp/pgvector && \
    cd /tmp/pgvector && \
    make && make install && \
    rm -r /tmp/pgvector

# Copy entrypoint and init scripts
COPY entrypoint.sh /usr/local/bin/
COPY init_db.sql.template /docker-entrypoint-initdb.d/

RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chmod +x /docker-entrypoint-initdb.d/init_db.sql.template

# Set entrypoint
ENTRYPOINT ["entrypoint.sh"]
