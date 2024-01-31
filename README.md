# URY's Server Backups

## `urysteve` (primary filestore)
- `backup_dbs.sh` - run daily, takes SQL dumps of our databses, and rsyncs them to `stratford` and `moyles`
- `backups-hourly.sh` - runs hourly, sends all the `filestore` and `musicstore` snapshots to `stratford` and `moyles`
- `sanoid` runs to snapshot the `filestore` and `musicstore`

## `stratford` (on-site backup server)
- `sanoid` runs to prune old `filestore`/`musicstore` snapshots, and to snapshot `backup/servers`
TODO:
    - `rsync-daily.new.sh`
    - `backup-alerts.sh`

## `moyles` (offsite backup server)
- `sanoid` runs to prune old `filestore`/`musicstore`/`pool0` snapshots
TODO - add `rsync-daily.new.sh` to get moyles backups to be independent of on site backups, and also change the sanid config as needed (i.e. copy stratford)

**Both `urybackup0` and `moyles` run `backup-alerts.sh` daily to send any important information to us in Slack, such as:**
- missing snapshots
- ZFS pools not being OK
- running out of storage space


## `uryrrod` (studio webcam recording server)
- `movempg.sh` transfers recorded footage to the `filestore`, where `urysteve` will also tidy up older recordings (older than 90 days)

## TODO
- mailbox backups - other than just the `ury` server backup
- external monitoring of `backup-alerts.sh` script actually running

## [DEPRECATED]`urybackup0` (old on-site backup server)
## This is an achived section - no longer in use
- `sanoid` runs to prune old `filestore`/`musicstore` snapshots, and to snapshot `pool0`
- `rsync-daily.new.sh` runs to backup all the other servers we have, i.e. home directories. these are backed up to `pool0`
