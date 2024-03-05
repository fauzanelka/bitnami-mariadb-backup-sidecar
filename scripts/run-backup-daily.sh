#!/usr/bin/env bash
# Backup daily with 7 days rotation

# shellcheck source=/dev/null
. <(xargs -0 bash -c 'printf "export %q\n" "$@"' -- < /proc/1/environ)

RESULT_FILE="$DAILY_BACKUP_DIR/$MARIADB_DATABASE-$(date +%Y%m%d%H%M%S).sql"

if mariadb-dump --single-transaction --skip-add-drop-table --no-tablespaces --host="$MARIADB_HOST" --user="$MARIADB_USER" --password="$MARIADB_PASSWORD" --result-file="$RESULT_FILE" "${MARIADB_DATABASE}" && gzip "$RESULT_FILE"; then
    echo "$MARIADB_DATABASE dump was successful."
else
    echo "$MARIADB_DATABASE dump failed."
    exit 1
fi

find "$DAILY_BACKUP_DIR" -type f -name '*.sql' -mtime +7 -exec rm {} \;

if rclone copy "$RESULT_FILE.gz" ":s3:$RCLONE_S3_BUCKET_DAILY/"; then
    echo "$RESULT_FILE.gz successfully copied to remote location."
else
    echo "Failed to copy $RESULT_FILE.gz to remote location."
    exit 1
fi
