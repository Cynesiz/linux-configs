#!/bin/bash
 
#
# CREATE MYSQL BACKUP
# Author:Robert Chain
# Mail:robert.c@lampnode.com
#

##
## Crond setup 
## If you want to run this script in crontab mode, please perform the following steps:
## 1.cp this file  to ~/crondScripts/YOURFILE.crond.sh
## 2.Enable and setup the following variables: EC_USER_DIR
## 3.chmod +x YOURFILE.crond.sh
## 4.setup crontab
 
#Define Users Vars
DBUSER="root";
DBHOST="localhost";
DEFAULTCHARSET="utf8";
EC_USER_DIR="/opt/site-bak";

#Define Program Vars
MYSQL=/usr/bin/mysql;
GREP=/bin/grep;
REMOVE=/bin/rm;
GZIP=/bin/gzip;
DATE=/bin/date;
MK=/bin/mkdir;
MYSQLDUMP=/usr/bin/mysqldump;
NOW=`$DATE '+%Y%m'%d-%H%M`;

#Setup backup dir
echo ""
echo "#Init environment"
echo "--------------------------------------------------------"
if [ "$EC_USER_DIR" = "" ]; then
  echo "Backup is on Local mode"
	MYSQLBACKUPDIR="./$NOW"
else
	echo "Backup is on Crond mode"
    	MYSQLBACKUPDIR="$EC_USER_DIR/$NOW"
fi 
#create backup path
$MK $MYSQLBACKUPDIR;
echo "$MYSQLBACKUPDIR had been created";
 
# Mysql dump
#
# options list:
#       -Q Quote identifiers (such as database, table, and column names) within "`" characters.
#       -c Use complete INSERT statements that include column names.
#       -C Compress all information sent between the client and the server if both support compression
#       --add-drop-table Add a DROP TABLE statement before each CREATE TABLE statement
#       --add-locks  Surround each table dump with LOCK TABLES and UNLOCK TABLES statements.
#       --quick This option is useful for dumping large tables.
#       --lock-tables For each dumped database, lock all tables to be dumped before dumping them.
#       --default-character-set Use charset_name as the default character set
#
#
echo ""
echo "#Backup databases"
echo "--------------------------------------------------------"
for i in $(echo 'SHOW DATABASES;' | $MYSQL -u$DBUSER  -h$DBHOST|$GREP -v '^Database$'); 
do
if [ $i != 'information_schema' ] && [ $i != 'mysql' ] && [ $i != 'test' ]; then       
	$MYSQLDUMP                                        \
                -u$DBUSER -h$DBHOST     \
                -Q -c -C --add-drop-table --extended-insert=false  --add-locks --quick --lock-tables  \
                --default-character-set=$DEFAULTCHARSET \
                $i | $GZIP > $MYSQLBACKUPDIR/$i.sql.gz;
        echo "Database $i has been dumped";
fi
done;
