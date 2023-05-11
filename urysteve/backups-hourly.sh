#!/usr/bin/env bash

LOG=/var/log/replication.log

/usr/sbin/syncoid -r --no-sync-snap music root@stratford.ury.york.ac.uk:musicstore | tee -a $LOG 2>&1
/usr/sbin/syncoid -r --no-sync-snap music root@moyles.ury.york.ac.uk:pool0/music | tee -a $LOG 2>&1
/usr/sbin/syncoid -r filestore root@stratford.ury.york.ac.uk:filestore | tee -a $LOG 2>&1
/usr/sbin/syncoid -r filestore root@moyles.ury.york.ac.uk:pool0/pool1 | tee -a $LOG 2>&1

echo "`date` - replication complete." | tee -a $LOG