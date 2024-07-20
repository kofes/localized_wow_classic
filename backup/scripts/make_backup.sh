#!/usr/bin/env bash

set -xe

function main() {
    backup_databases
    backup_resources
    backup_startup_files
    move_backups_to_archives
}

function backup_databases() {
    pushd /tmp/backup
        mariadb-dump --host=$DATABASE_HOST -u root --password=$DATABASE_PASS --lock-tables --all-databases > databases.sql
        tar -cvzf databases.tgz databases.sql
        rm databases.sql
    popd
}

function backup_resources() {
    pushd /tmp/backup/resources_data
        tar -cvzf ../resources.tgz ./*
    popd
}

function backup_startup_files() {
    pushd /tmp/backup/startup_data
        tar -cvzf ../startup.tgz ./*
    popd
}

function move_backups_to_archives() {
    pushd /tmp/backup/
        local timestamp=$(date +"%d-%m-%YT%H-%M")
        mkdir -p archives/backup-$timestamp
        mv *.tgz archives/backup-$timestamp/
    popd
}

main "$@"

