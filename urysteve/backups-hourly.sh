#!/bin/bash

LOG=/var/log/replication.log

onsite () {
 echo "`date` - syncing music-backup0" | tee -a $LOG
 /usr/sbin/syncoid -r --no-sync-snap --sshkey="/usr/local/share/backup/steve-bup0-rsa" music root@urybackup0.york.ac.uk:music | tee -a $LOG 2>&1
 echo "`date` - syncing filestore-backup0..." | tee -a $LOG
 /usr/sbin/syncoid -r --no-sync-snap --sshkey="/usr/local/share/backup/steve-bup0-rsa" filestore root@urybackup0.york.ac.uk:pool1 | tee -a $LOG 2>&1
}

offsite () {
 echo "`date` - syncing filestore-moyles..." | tee -a $LOG
 /usr/sbin/syncoid -r --no-sync-snap --sshkey="/usr/local/share/backup/steve-moyles-rsa" filestore root@moyles.ury.york.ac.uk:pool0/pool1 | tee -a $LOG 2>&1
 echo "`date` - syncing music-moyles" | tee -a $LOG
 /usr/sbin/syncoid -r --no-sync-snap --sshkey="/usr/local/share/backup/steve-moyles-rsa" music root@moyles.ury.york.ac.uk:pool0/music | tee -a $LOG 2>&1
}



onsite &
offsite &
wait
echo "`date` - replication complete." | tee -a $LOG