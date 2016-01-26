# Backup and Restore of Ontohub Data

We have a backup script in `script/backup` that backs up all the data of the Ontohub instance or restores a backup.
It is tailored to the productive deployments of ontohub.org and cannot be used with development machines.

# Backing up
To create a backup, simply run as `admin` user
```shell
+ su - -c '~ontohub/webapp/script/backup create'
```

What happens is:
* It activates the maintenance mode, which deactivates the Ontohub instance (by creating the file `data/maintenance.txt`). This way, the data gets frozen and the backup will have a consistent state.
* It creates a folder like `2014-12-06_20-06-37` in `~ontohub/ontohub_data_backup` on a production machine.
* In this folder, there is a `ontohub_repositories.tar.gz` created with the repository data inside.
* Also, a `ontohub_sql_dump.postgresql` file is created, which is a compressed PostgreSQL dump.
* It deactivates the maintenance mode (by deleting the `data/maintenance.txt`).

## Timed backup

To create a daily backup at 03:00, add the following line to `admin`'s crontab:
```
* 3 * * * + su - -c '~ontohub/webapp/script/backup create'
```

# Pruning of old backups
When a new backup is created, an old one might be deleted.
This happens if there are at least 30 backups and the oldest of them dates back at least 365 days.
Then, only the ones are deleted that exceed this age threshold such that there will be 30 backups again.

# Restoring
To restore a previously created backup, run as `admin` user
```shell
+ su - -c '~ontohub/webapp/script/backup restore 2014-12-06_20-06-37'
```
(use your own backup name - it is a folder from the above-mentioned backup directory)

Note that there must be no active connection to the database.
Otherwise restoring the SQL dump will fail.

What happens is:
* It activates the maintenance mode.
* It restores the PostgreSQL dump `ontohub_sql_dump.postgresql`. This drops and recreates the whole database. In order to drop the database, there must be no other active connection to it.
* It moves the current (pre-restore) repositories to a temporary directory (which one will be printed to stdout). This is done because the admin can do something with the repositories if restoring the backup fails.
* It extracts the repository archive `ontohub_repositories.tar.gz` to the Ontohub instance. This is first tried with `sudo` because the permissions/file mode are only restored if executed with super user rights. If cancelled (<kbd>CTRL</kbd>+<kbd>C</kbd>) or the wrong password is entered three times, the archive is extracted without `sudo`.
The use of `sudo` is required to restore file permissions of the git repositories.
If cancelled, the file permissions need to be set manually with `chown`.
* It deletes the repositories which were moved to a temporary directory.
* It deactivates the maintenance mode.
