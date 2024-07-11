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
        libmariadb-dev

COPY --from=cmangos-base ${MANGOS_PATH}/run ${MANGOS_PATH}/run
