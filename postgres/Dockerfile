# postgres/Dockerfile

FROM postgres:latest

COPY ./init_db.sql /docker-entrypoint-initdb.d/
COPY ./entrypoint.sh /entrypoint-postgres.sh

RUN chmod +x /entrypoint-postgres.sh

ENTRYPOINT ["/entrypoint-postgres.sh"]
