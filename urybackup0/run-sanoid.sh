#!/usr/bin/env bash
sanoid --cron
syncoid -r --no-sync-snap --sshkey="/root/.ssh/id_rsa" pool0/backup root@moyles.ury.york.ac.uk:pool0/backup