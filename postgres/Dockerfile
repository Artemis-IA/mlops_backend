 # postgres/Dockerfile
FROM postgres:latest

COPY ./init_db.sql /docker-entrypoint-initdb.d/

COPY ./entrypoint.sh /usr/local/bin/entrypoint_postgres.sh
RUN chmod +x /usr/local/bin/entrypoint_postgres.sh

ENTRYPOINT ["/usr/local/bin/entrypoint_postgres.sh"]
