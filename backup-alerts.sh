#!/usr/bin/env bash

# URY Backup Alerting Script
# Author: Michael Grace <michael.grace@ury.org.uk>

set -eo pipefail

[[ $BACKUP_ALERT_SLACK_HOOK == "" ]] && { echo >&2 "BACKUP_ALERT_SLACK_HOOK not set"; exit 1; }

set -u

BACKUP_SERVER=$(hostname)
case $BACKUP_SERVER in
    "stratford")
        musicstore="musicstore"
        filestore="filestore"
        database="backup/db"
        server_backup="backup/servers"
        ;;

    "moyles")
        musicstore="pool0/music"
        filestore="pool0/pool1"
        database="pool0/db"
        server_backup="pool0/backup"
        ;;

    *)
        echo >&2 "this isn't running on stratford or moyles"
        exit 1
        ;;
esac

yesterday=$(date -d yesterday +'%Y-%m-%d')

tmp_file=/tmp/$(date +'%s').backupalert
alerts_started=0

alert () {
    [[ alerts_started -eq 0 ]] && { echo "$BACKUP_SERVER Backup Alert" > $tmp_file; alerts_started=1; }

    local message=$1
    echo "- $message" >> $tmp_file
}

daily_snapshot_exist () {
    local dataset=$1
    local date=$2
    zfs list -t snapshot | grep "${dataset}@autosnap_${date}_.*_daily"
}


for dataset in $musicstore $filestore $database $server_backup; do
        [[ $(daily_snapshot_exist $dataset $yesterday) == "" ]] && alert "$dataset missing daily snapshot"
done

while read pool && read state; do
    [[ $(echo $state | grep ONLINE) == "" ]] && alert "$pool ZFS Status: $state"
done < <(zpool status | grep 'pool:\|state:')

while read line; do
    percent=$(echo $line | cut -d '%' -f 1)
    mnt=$(echo $line | cut -d ' ' -f 2)
    [[ $percent -ge 90 ]] && alert "$mnt at $percent%"
done < <(df | tail +2 | tr -s ' ' | cut -d ' ' -f 5,6 | grep -v '/dev')

check_server="urysteve/root"
[[ $(find "/$server_backup/$check_server" -mtime -1 | head -1) == "" ]] && alert "No backup data on $server_backup (checked $check_server)"
[[ $(find "/$database" -mtime -1 | head -1) == "" ]] && alert "No new database files"

[[ -f $tmp_file ]] && curl -X POST --data-urlencode "payload={\"text\": \"$(cat $tmp_file)\"}" $BACKUP_ALERT_SLACK_HOOK

rm $tmp_file 2>/dev/null    
