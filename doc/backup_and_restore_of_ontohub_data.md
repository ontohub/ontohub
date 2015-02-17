# Backup and Restore of Ontohub Data

We have a backup script in `script/backup` that backs up all the data of the Ontohub instance or restores a backup.

# Backing up
To create a backup, simply run
```shell
script/backup create
```

What happens is:
* It activates the maintenance mode, which deactivates the Ontohub instance (by creating the file `data/maintenance.txt`). This way, the data gets frozen and the backup will have a consistent state.
* It creates a folder like `2014-12-06_20-06-37` in `/home/ontohub/ontohub_data_backup` on a production machine or in `ontohub/tmp/backup` on a development machine.
* In that folder, there is a `ontohub_repositories.tar.gz` created with the repository data inside.
* Also, a `ontohub_sql_dump.postgresql` file is created, which is a compressed PostgreSQL dump.
* It deactivates the maintenance mode (by deleting the `data/maintenance.txt`).

# Restoring
To restore a previously created backup, run
```shell
script/backup restore 2014-12-06_20-06-37
```
(use your own backup name - it is a folder from the above-mentioned backup directory)

What happens is:
* It activates the maintenance mode.
* It restores the PostgreSQL dump `ontohub_sql_dump.postgresql`.
* It moves the current (pre-restore) repositories to a temporary directory (which one will be printed to stdout). This is done because the admin can do something with the repositories if restore fails.
* It extracts the repository archive `ontohub_repositories.tar.gz` to the Ontohub instance. This is first tried with `sudo` because the permissions/file mode are only restored if executed with super user rights. If canceled (<kbd>CTRL</kbd>+<kbd>C</kbd>) or the wrong password is entered three times, the archive is extracted without `sudo`.
* It deletes the repositories which were moved to a temporary directory.
* It deactivates the maintenance mode.
