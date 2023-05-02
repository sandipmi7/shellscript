#!/bin/bash


# Database credentials
user="root1"
password="Root1@hmc"
host="10.10.2.61"

db_name1="hmc_db"

# Other options
backup_path="/cogen_db"

# Backup date format ran ok
#date=$(date +"%d-%b-%Y")
date=$(date +%Y-%m-%d_%H-%M)

filename="hmc_db-$date"
logfile="/var/log/script_activity.log"
# Set default file permissions
#umask 177

cd $backup_path
# Dump database into SQL file
mysqldump --user=$user --password=$password --host=$host --databases $db_name1 >$backup_path/$filename.sql
chmod 777 $backup_path/$filename.sql
tar -czvf $filename.tgz $backup_path/$filename.sql
aws s3 cp $backup_path/$filename.tgz s3://cogen-hmc-db/dailybackup/
echo "* $filename.tgz File Copied to S3 Bucket **"  >>$logfile
rm -f  $backup_path/$filename.tgz

# Delete files older than 10 days
find $backup_path -name "*.sql" -type f -mtime +10 -delete;


echo "Script Finished Running at $(date +%Y-%m-%d_%H:%M)" >>$logfile
