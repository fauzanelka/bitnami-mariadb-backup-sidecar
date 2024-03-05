FROM debian:11-slim

LABEL org.opencontainers.image.source https://github.com/fauzanelka/bitnami-mariadb-backup-sidecar

COPY --from=bitnami/mariadb:11.2-debian-11 /opt/bitnami/mariadb/bin/mariadb /opt/bitnami/mariadb/bin/mariadb
COPY --from=bitnami/mariadb:11.2-debian-11 /opt/bitnami/mariadb/bin/mariadb-admin /opt/bitnami/mariadb/bin/mariadb-admin
COPY --from=bitnami/mariadb:11.2-debian-11 /opt/bitnami/mariadb/bin/mariadb-check /opt/bitnami/mariadb/bin/mariadb-check
COPY --from=bitnami/mariadb:11.2-debian-11 /opt/bitnami/mariadb/bin/mariadb-dump /opt/bitnami/mariadb/bin/mariadb-dump
COPY --from=bitnami/mariadb:11.2-debian-11 /opt/bitnami/mariadb/bin/mariadb-import /opt/bitnami/mariadb/bin/mariadb-import
COPY --from=bitnami/mariadb:11.2-debian-11 /opt/bitnami/mariadb/bin/mariadb-slap /opt/bitnami/mariadb/bin/mariadb-slap

ENV PATH="$PATH:/opt/bitnami/mariadb/bin"

ADD https://github.com/rclone/rclone/releases/download/v1.65.2/rclone-v1.65.2-linux-amd64.deb /tmp/rclone-v1.65.2-linux-amd64.deb

RUN apt-get update && apt-get install -y \
    cron \
    vim \
    && dpkg -i /tmp/rclone-v1.65.2-linux-amd64.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

COPY --chmod=755 --chown=root:root scripts/ /root/scripts/
COPY --chmod=600 --chown=root:crontab crontab/ /var/spool/cron/crontabs/

ENTRYPOINT [ "/usr/sbin/cron", "-f" ]