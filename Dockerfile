FROM ubuntu:22.04 as builder

# Set environment for silent timezone setup (installation)
ENV DEBIAN_FRONTEND=noninteractive
ARG TIMEZONE=Etc/UTC
ENV TZ=${TIMEZONE}

# Update/upgrade & install required libraries for server compilation/usage
RUN apt update && apt upgrade
RUN apt -y install\
    build-essential\
    cmake\
    g++-12\
    git-core\
    patch\
    libboost-all-dev\
    libmariadb-dev-compat\
    mariadb-client\
    libssl-dev\
    grep\
    binutils\
&&\
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 12 --slave /usr/bin/g++ g++ /usr/bin/g++-12


ARG MANGOS_TYPE=classic
ENV MANGOS_TYPE=${MANGOS_TYPE}

ARG MANGOS_PATH

WORKDIR ${MANGOS_PATH}
RUN git clone https://github.com/cmangos/mangos-${MANGOS_TYPE}.git --branch latest --single-branch --depth 1 mangos
RUN git clone https://github.com/cmangos/${MANGOS_TYPE}-db.git --branch latest --single-branch --depth 1 database

# if selected classic server sources then
# download ru localization patch-module & patch cmangos app sources
# & also move classic db updates
ADD localization_patch_update.patch /tmp/localization_patch_update.patch
ADD database/patch/install_full_db.patch /tmp/install_full_db.patch
ADD database/updates /tmp/database_updates
ADD playerbots.patch /tmp/playerbots.patch

SHELL ["/bin/bash", "-c"]
RUN if [[ "$MANGOS_TYPE" == "classic" ]]; then\
        git clone https://github.com/WoWruRU/classicdb_ruRU\
            --branch master\
            --single-branch\
            --depth 1\
            localization_patch &&\
        pushd localization_patch &&\
            cp /tmp/localization_patch_update.patch . &&\
            patch -p0 < localization_patch_update.patch &&\
            ln -s ${MANGOS_PATH}/mangos mangos &&\
            cp cmangos_ruRU_support.patch mangos &&\
            pushd mangos &&\
                patch -p1 < cmangos_ruRU_support.patch &&\
            popd &&\
        popd &&\
        pushd ${MANGOS_PATH} &&\
            # move localization patch sql scripts to database's directories
            cp localization_patch/Updates/* database/Updates/ &&\
            cp /tmp/database_updates/* database/Updates/ &&\
            cp localization_patch/Full_DB/* database/Full_DB/ &&\
            # patch database initialization
            pushd database/ &&\
                ln -s /tmp/install_full_db.patch . &&\
                patch -p1 < install_full_db.patch &&\
            popd &&\
        popd;\
    fi;


## Configure release server with bots
WORKDIR ${MANGOS_PATH}/build
RUN cmake\
    -B${MANGOS_PATH}/build\
    -S${MANGOS_PATH}/mangos\
    -D CMAKE_INSTALL_PREFIX=${MANGOS_PATH}/run\
    # payerbots wont compile without precomiled headers optimization on
    -D PCH=ON\
    -D CMAKE_INTERPROCEDURAL_OPTIMIZATION=ON\
    # Build type
    -D CMAKE_BUILD_TYPE=Release\
    -D DEBUG=0\
    # compile extractors for client resources extraction
    -D BUILD_EXTRACTORS=ON\
    # enable bots
    -D BUILD_PLAYERBOTS=ON\
    -D BUILD_AHBOT=ON

## Build server
RUN cmake --build . --target install --config Release


# Make configuration files from those templates
WORKDIR ${MANGOS_PATH}/run/etc
RUN cp anticheat.conf.dist anticheat.conf
RUN cp aiplayerbot.conf.dist aiplayerbot.conf

# Change configuration files
ARG DATABASE_HOST
ARG MANGOS_DB_PORT
ARG MANGOS_DBUSER
ARG MANGOS_DBPASS

ENV DATABASE_HOST=${DATABASE_HOST}
ENV MANGOS_DB_PORT=${MANGOS_DB_PORT}
ENV MANGOS_DBUSER=${MANGOS_DBUSER}
ENV MANGOS_DBPASS=${MANGOS_DBPASS}

# FROM scratch
# COPY --from=build / /
