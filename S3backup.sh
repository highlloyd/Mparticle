#!/bin/bash
# Create a log file 
LOG_FILE=/var/log/myscript.log
exec > >(while read -r line; do printf '%s %s\n' "$(date --rfc-3339=seconds)" "$line" | tee -a $LOG_FILE; done)
exec 2> >(while read -r line; do printf '%s %s\n' "$(date --rfc-3339=seconds)" "$line" | tee -a $LOG_FILE; done >&2)

#Verify if those dependencies exists
if [ $(dpkg-query -W -f='${Status}' s3cmd 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "Please install using apt-get install s3cmd and configure it using s3cmd --confirgure"
  exit 1
fi

if [ $(dpkg-query -W -f='${Status}' mailutils 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
 echo "Please install using apt-get install mailutils"
 exit 1
fi

if [ $(dpkg-query -W -f='${Status}' pv 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "Please install using apt-get install pv"
  exit 1
fi

#backup folder within the server where backup files are stored
backup_destination=~/backup
#folders for backup, can be comma separated for multiple folders
backup_source=/change/it/to/the/folders/you/wamt/
#s3 bucket name that contains backup
S3_bucket_name=bucket_name
#number of days to keep archives
KEEP_DAYS=7
#Email address 
email_address='youre@email.com'
#script variables
backup_date=`date +%F`
backup_datetime=`date +%F-%H%M`

#ARCHIVING FILES / FOLDER and upload to S3
echo 'Archiving files and folders...'
tar cf - $backup_source -P | pv -s $(du -sb $backup_source | awk '{print $1}') | gzip > $backup_destination/$backup_date.$backup_datetime.tar.gz
s3cmd put $backup_destination/$backup_date.$backup_datetime.tar.gz s3://${S3_bucket_name}/backup/$backup_date.$backup_datetime.tar.gz


#check if files exists and email the result
checkbackup=$(s3cmd ls s3://${S3_bucket_name}/backup/ | grep -E -o $backup_date.$backup_datetime.tar.gz)

if [ -z "$checkbackup" ]; then   
   echo "The backup file was not found please check the logs" | mail -s "Backup failed" $email_address
else
   echo "New backup file $backup_date.$backup_datetime.tar.gz created successfully" | mail -s "backup finished" $email_address
fi
#DELETE FILES OLDER THAN 7 days
echo 'Deleting backup older than '${KEEP_DAYS}' days'
find ${backup_destination} -type f -mtime +${KEEP_DAYS} -name '*.gz' -execdir rm -- {} \;
