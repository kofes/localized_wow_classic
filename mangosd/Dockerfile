FROM cmangos-base as builder


ARG DATABASE_HOST
ARG DATABASE_PORT

ARG MANGOS_DBUSER
ARG MANGOS_DBPASS
ARG MANGOS_PATH

# Setup database
WORKDIR ${MANGOS_PATH}/database
RUN chmod +x ./InstallFullDB.sh && echo 9 | ./InstallFullDB.sh

## Modify InstallFullDB.config
RUN cp InstallFullDB.config InstallFullDB.config.tmp &&\
    sed -i '/^MYSQL_PATH="*"/c\MYSQL_PATH="/usr/bin/mariadb"' InstallFullDB.config.tmp &&\
    sed -i '/^MYSQL_HOST="*"/c\MYSQL_HOST="'"${DATABASE_HOST}"'"' InstallFullDB.config.tmp &&\
    sed -i '/^MYSQL_PORT="*"/c\MYSQL_PORT="'"${DATABASE_PORT}"'"' InstallFullDB.config.tmp &&\
    sed -i '/^MYSQL_USERNAME="*"/c\MYSQL_USERNAME="'"${MANGOS_DBUSER}"'"' InstallFullDB.config.tmp &&\
    sed -i '/^MYSQL_PASSWORD="*"/c\MYSQL_PASSWORD="'"${MANGOS_DBPASS}"'"' InstallFullDB.config.tmp &&\
    sed -i '/^MYSQL_USERIP="*"/c\MYSQL_USERIP="%"' InstallFullDB.config.tmp &&\
    sed -i '/^CORE_PATH="*"/c\CORE_PATH="../mangos"' InstallFullDB.config.tmp &&\
    sed -i '/^LOCALES="*"/c\LOCALES="YES"' InstallFullDB.config.tmp &&\
    sed -i '/^PLAYERBOTS_DB="*"/c\PLAYERBOTS_DB="YES"' InstallFullDB.config.tmp &&\
    sed -i '/^LOCALIZATION_PATCH="*"/c\LOCALIZATION_PATCH="ClassicDB_ruRU_1_0_2.sql"' InstallFullDB.config.tmp &&\
    mv InstallFullDB.config.tmp InstallFullDB.config

FROM ubuntu:22.04 as runner

# Set environment for silent timezone setup (installation)
ENV DEBIAN_FRONTEND=noninteractive
ARG TIMEZONE=Etc/UTC
ENV TZ=${TIMEZONE}

ARG MANGOS_PATH

# Update/upgrade & install required libraries for server usage
RUN apt update &&\
    apt install -y --no-install-recommends\
        tzdata\
        libmariadb-dev\
        mariadb-client

COPY --from=builder ${MANGOS_PATH}/mangos ${MANGOS_PATH}/mangos
COPY --from=builder ${MANGOS_PATH}/run ${MANGOS_PATH}/run
COPY --from=builder ${MANGOS_PATH}/database ${MANGOS_PATH}/database
