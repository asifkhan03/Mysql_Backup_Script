s Mysql_Backup_Script


First run the below command on the server.
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash



after that the vi mysql_backup.sh in the /home/ubuntu

and then set cronjob which take the backup of the mysql daily at 1 AM UTC

0 1 * * * /bin/bash /home/ubuntu/mysql_backup.sh >> /home/ubuntu/mysql_backup.log 2>&1
