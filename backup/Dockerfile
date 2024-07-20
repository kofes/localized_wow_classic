FROM ubuntu:22.04

# Set environment for silent timezone setup (installation)
ENV DEBIAN_FRONTEND=noninteractive
ARG TIMEZONE=Etc/UTC
ENV TZ=${TIMEZONE}

# Update/upgrade & install required libraries for server usage
RUN apt update &&\
    apt install -y --no-install-recommends\
        tzdata\
        libmariadb-dev\
        mariadb-client\
        cron

COPY config/backup.crontab /etc/cron.d/backup.crontab
RUN chmod +x /etc/cron.d/backup.crontab &&\
    crontab /etc/cron.d/backup.crontab &&\
    touch /var/log/backup.crontab.log

CMD cron && tail -f /var/log/backup.crontab.log
