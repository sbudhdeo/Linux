#!/bin/bash
### System Setup ###

# Uncomment to enable script debugging
# set -x

NOW=$(date +%Y-%m-%d-%H%M)
KEEPDAYS=5

### SSH Info ###
SHOST="db.host.com"                    # Replace with actual host
SUSER="sa"                             # Replace with actual user
SDIR="/mnt/archive5/wp_nomadicone.com" # Replace with actual directory

### MySQL Setup ###
MUSER=""   # Replace with MySQL username
MPASS=""   # Replace with MySQL password
MHOST=""   # Replace with MySQL host
DBS=""     # Space-separated list of databases to backup

### Local Writable directory on the server ###
EMAILID=""    # Email to
EMAILFROM=""  # Email from

### Start MySQL Backup ###
attempts=0
for db in $DBS; do
    attempts=$((attempts + 1))          # Count the backup attempts
    FILE="mysql-$db.$NOW.sql.gz"        # Set the backup filename
    mysqldump -q -u $MUSER -h $MHOST -p$MPASS $db | gzip -9 > $FILE
done
scp -P 1313 $FILE $SUSER@$SHOST:$SDIR  # Copy all the files to backup server

### Mail me! ###
localfiles=$(ls -lh *.sql.gz | awk '{print $9, $6, $7, $8, $5}' | column -t)

count=0 # Count local files from today
for file in $localfiles; do
    count=$((count + 1))
done

### Send mail ###
mail -s "Backups Report" -aFrom:$EMAILFROM $EMAILID << END
Success with $count of $attempts backups.

The following databases were attempted to be backed up:
$DBS

Files stored:
$localfiles
END
