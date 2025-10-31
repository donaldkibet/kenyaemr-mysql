FROM mysql:8.0

ENV MYSQL_DATABASE=openmrs \
    MYSQL_USER=openmrs

COPY init-scripts/ /docker-entrypoint-initdb.d/

EXPOSE 3306

# Basic healthcheck
HEALTHCHECK --interval=30s --timeout=5s --retries=5 \
  CMD mysqladmin ping -h 127.0.0.1 -u"${MYSQL_USER:-root}" -p"${MYSQL_PASSWORD:-$MYSQL_ROOT_PASSWORD}" || exit 1


