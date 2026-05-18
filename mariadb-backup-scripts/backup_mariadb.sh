#!/bin/bash
TIME=`date +%b-%d-%y-%H-%M-%S`
FILENAME=backup-$TIME.tar.gz
echo "backing up..."
mysqldump -uroot -proot -h mariadb-layer-farm erpnext > "/etc/mariadb-backup/"$FILENAME

# delete day old backup
find "/etc/mariadb-backup/" -type f -mtime +1 -delete