FROM cmangos-base as builder


ARG DATABASE_HOST
ARG DATABASE_PORT
ARG DATABASE_PASS

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
