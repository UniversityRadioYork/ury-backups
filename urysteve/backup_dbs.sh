#!/usr/bin/env bash
set -euo pipefail

PG_USERNAME=web
PG_PASSWORD=*****
PG_DATABASES=(membership bitwarden snipe_it roundcube wikis)
LOCAL_BACKUP_PATH=/db
#REMOTE_BACKUP_PATH=/pool0/backup/db.steve

for db in ${PG_DATABASES[@]}; do
        echo "$(date): backing up $db"
 (export PGPASSWORD="$PG_PASSWORD" && /usr/bin/pg_dump -U "$PG_USERNAME" -F custom -f "$LOCAL_BACKUP_PATH/$db.sql.dump" "$db")
done

for server in "urybackup0.york.ac.uk" "moyles.ury.york.ac.uk"; do
 # i hate this
 if [[ $server == "moyles.ury.york.ac.uk" ]]; then
        remote_path=/pool0/db
 else
        remote_path=/pool0/backup/db
 fi
 
 set +e
 nc -vz $server 22 > /dev/null 2>&1
 ping_ok=$?
 set -e
 
 if [[ $ping_ok -eq 0 ]]; then
        echo $(date): transferring to $server
        rsync -ah --stats --delete --delete-delay --delete-excluded $LOCAL_BACKUP_PATH/* $server:$remote_path
        echo $(date): transfer to $server done
 else
        echo $(date): could not ping $server - skipping
 fi

done
echo "$(date): done"
