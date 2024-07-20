#!/usr/bin/env bash

set -xe

source $(dirname $0)/restore_data_from_backup.sh

function main() {
    local latest_backup_path=$(get_latest_backup_directory)

    if ! are_client_resources_extracted_by_this_script; then
        # try restore data from backup
        if [ ! -z $latest_backup_path ]; then
            echo "Client resources restoration from backup started..."
            restore_resources_data $latest_backup_path
        # otherwise start extraction
        else
            echo "Client resources extraction started..."
            extract_client_resources
        fi
        cache_successful_client_resources_extraction
    fi
    echo "Client resources are extracted"

    while [ ! is_database_accesible ]; do sleep 5s; done

    if ! is_database_initialized_by_this_script; then
        # try restore data from backup
        if [ ! -z $latest_backup_path ]; then
            echo "Database records restoration from backup started..."
            restore_databases_data $latest_backup_path
        # otherwise start extraction
        else
            echo "Database initialization..."
            setup_database
        fi
        cache_successful_database_initialization
    fi
    echo "Database initialized"

    configure_mangosd
    run_mangosd
}

function run_mangosd() {
    pushd $MANGOS_PATH/run/bin
        until ./mangosd; do sleep 5s; done
    popd
}

function configure_mangosd() {
    pushd $MANGOS_PATH/run/etc
        cp -f /tmp/configs/* $MANGOS_PATH/run/etc/
        configure_database_info mangosd.conf
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

function setup_database() {
    pushd $MANGOS_PATH/database
        ./InstallFullDB.sh -InstallAll root $DATABASE_PASS DeleteAll
    popd
}

function is_database_accesible() {
    [ ! -z $(wget -O - -T 2 "$DATABASE_HOST:$DATABASE_PORT" 2>&1 | grep -o mariadb) ]
}

SUCCESSFUL_DATABASE_CONFIGURATION_FILE="$STARTUP_CACHE_DIRECTORY/SUCCESSFUL_DATABASE_CONFIGURATION_FILE"

function is_database_initialized_by_this_script() {
    [ -e $SUCCESSFUL_DATABASE_CONFIGURATION_FILE ]
}

function cache_successful_database_initialization() {
    touch $SUCCESSFUL_DATABASE_CONFIGURATION_FILE
}

function extract_client_resources() {
    pushd $MANGOS_PATH
        cp -r client /tmp/client
        cp run/bin/tools/* /tmp/client

        pushd /tmp/client
            chmod +x ExtractResources.sh MoveMapGen.sh
            ./ExtractResources.sh a
            mv Buildings Cameras dbc maps mmaps vmaps $MANGOS_PATH/resources
        popd
    popd
}

SUCCESSFUL_CLIENT_RESOURCES_EXTRACTION_FILE="$STARTUP_CACHE_DIRECTORY/SUCCESSFUL_CLIENT_RESOURCES_EXTRACTION_FILE"

function are_client_resources_extracted_by_this_script() {
    [ -e $SUCCESSFUL_CLIENT_RESOURCES_EXTRACTION_FILE ]
}

function cache_successful_client_resources_extraction() {
    touch $SUCCESSFUL_CLIENT_RESOURCES_EXTRACTION_FILE
}

main "$@"
