# Mparticle
# Summary

This bash script does those following:
* Backup of a filesystem directory to an existing s3 bucket
* Add time and date in the backup file name.
* Purge backups older than 7 days
* Monitor job status, confirm archive file exists in s3, and email a status message at the
end of the script run
* Log the results to a log file

# How to use it

This bash script requires:
* [S3CMD](https://help.dreamhost.com/hc/en-us/articles/215916627-Installing-S3cmd) to upload the backup files to S3
* [Mailutils](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-16-04) to send email when script is completed
* [PV](https://www.cyberciti.biz/open-source/command-line-hacks/pv-command-examples/) to show a progress bar and monitor job status

If those requirements are not installed the script will exit with an error.

Clone the repository
```bash
git clone https://github.com/highlloyd/Mparticle && cd Mparticle/
```
Make the script executable
```bash
chmod u+x S3backup.sh
```
Run the script
```bash
./S3backup.sh
```
Make the script run everyday:
```bash
crontab -e
```
Press I to switch to insert mode and add and edit this line:
```
0 0 * * * /full/path/to/script/S3backup.sh
```

# What this template project contains
This project contains the S3cmd.sh file.
