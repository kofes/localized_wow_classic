#!/usr/bin/env bash

set -xe

function main() {
    while [ ! is_database_accesible ]; do sleep 5s; done

    configure_realmd
    run_realmd
}

function run_realmd() {
    pushd $MANGOS_PATH/run/bin
    until ./realmd; do sleep 5s; done
    popd
}

function configure_realmd() {
    pushd $MANGOS_PATH/run/etc
        cp -f /tmp/configs/* $MANGOS_PATH/run/etc/
        configure_database_info realmd.conf
    popd
}

function configure_database_info() {
    grep -ne 'DatabaseInfo.*=*"*;*;*;*;*"' $1 | while read line; do
        index=${line%:*};
        name=$(echo $line | cut -d ':' -f 2 | cut -d ' ' -f 1);
        tablename=$(echo $line | cut -d ';' -f 5 | cut -d '"' -f 1);
        sed $index's/.*/'$name' = "'$DATABASE_HOST';'$DATABASE_PORT';'$MANGOS_DBUSER';'$MANGOS_DBPASS';'$tablename'"/' $1 > $1.temp;
        mv $1.temp $1;
    done;
}

function is_database_accesible() {
    [ ! -z $(wget -O - -T 2 "$DATABASE_HOST:$DATABASE_PORT" 2>&1 | grep -o mariadb) ]
}

main "$@"
