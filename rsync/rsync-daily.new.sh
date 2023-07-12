#!/usr/bin/env bash

# URY's New Backup Script for General Server Backups

# Author: Michael Grace <michael.grace@ury.org.uk>

# for this script we need:
# - servers file - lists the full hostnames of the servers to backup
# - exclusions/$X where $X is the first part of the server name
# - urybackup-exclude.new.conf - contains what to exclude in general

set -uo pipefail

log () {
        echo -e $(date) '\t' $1 '\t' ${@:2}
}

case $(hostname) in
        "stratford")
                BACKUP_ROOT="/backup/servers"
                ;;

        "moyles")
                BACKUP_ROOT="/pool0/backup"
                ;;

        *)
                echo >&2 "this isn't running on stratford or moyles"
                exit 1
                ;;
esac


EXCLUDE_FILE=/opt/ury-backups/rsync/urybackup-exclude.new.conf
SERVER_LIST=/opt/ury-backups/rsync/servers

log root Backups Started
while read server; do
        [[ $(echo $server | head -c 1) == '#' ]] && continue
        server_name=$(echo $server | cut -d '.' -f 1)
        log $server_name Attempting connection to $server_name
        ping -c 1 $server > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
                log $server_name could not establish connection
                continue
        else
                log $server_name established connection - starting rsync
                # Rsync Command
                (rsync -ah --stats --delete --delete-delay --delete-excluded --exclude-from=$EXCLUDE_FILE --exclude-from=/opt/ury-backups/rsync/exclusions/$server_name $server:/ $BACKUP_ROOT/$server_name && log $server_name rsync complete) &
        fi
done < $SERVER_LIST
wait
log root Backups Done