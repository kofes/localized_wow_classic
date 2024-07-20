#!/usr/bin/env bash

function restore_databases_data() {
    pushd /tmp/
        tar -xvzf $1/databases.tgz -C .
        mariadb --host=database -u root --password=$DATABASE_PASS --force < databases.sql
        rm databases.sql
    popd
}

function restore_resources_data() {
    pushd /tmp/
        tar -xvzf $1/resources.tgz -C $MANGOS_PATH/resources
    popd
}

function restore_startup_data() {
    pushd /tmp/
        tar -xvzf $1/startup.tgz -C $STARTUP_CACHE_DIRECTORY
    popd
}

function get_latest_backup_directory() {
    local backup_archives_directory="/tmp/backup/archives"
    echo $backup_archives_directory/$(ls $backup_archives_directory | sort -n | tail -1)
}
