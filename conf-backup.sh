#!/bin/bash

#Backup mysql db files
#create db backup path if not exits


#date=$(date +"%Y_%b_%d_%H_%M")
date=$(date +"%Y-%m-%d")

#create backup folder
if [ ! -e /root/backup/ ]; then
           mkdir /root/backup
fi

mysql_path="/root/backup/$date/mysql"
conf_path="/root/backup/$date/conf_files"
status_path="/root/backup/$date/status"
bhist_path="/root/backup/$date/bash"

#create backup/mysql folder
if [ ! -e /root/backup/$date ]; then
           mkdir /root/backup/$date
else
echo "Backup Folder $date exists "
exit
fi

echo "Starting MYSQL db backup..."

#create backup/mysql folder
if [ ! -e $mysql_path ]; then
           mkdir $mysql_path
fi


#default permission to file

umask 077

#dump ssh_log & ip_history databases in a SQL file

mysql_ssh="${mysql_path}/ssh_db.sql"
mysql_ip="${mysql_path}/ip_history.sql"
mysql_all="${mysql_path}/alldb.sql"

#mysqldump -u root ssh_log > $mysql_ssh
#mysqldump -u root floating_ip_log > $mysql_ip
mysqldump -u root --all-databases > $mysql_all

# delete old file versions - more than 30 days
#find $conf_path/* -mtime +30 -exec rm {} \;

echo "DB backup ended successfully :-)"

#Backup OpenStack configuration files

#Create backup path if not exists
echo "Starting configuration files backup..."

#create conf_files folder
#if [ ! -e /root/backup/conf_files ]; then
           mkdir $conf_path
#fi

#conf_path="/root/backup/conf_files_$date"
#date=$(date +"%Y_%b_%d_%H_%M")

#default permission to file
umask 077

#nova
echo "backup nova conf files..."
mkdir "${conf_path}/nova"
cp -a -R /etc/nova/* "${conf_path}/nova"

#cinder
echo "backup cinder conf files..."
mkdir "${conf_path}/cinder"
cp -a -R /etc/cinder/* "${conf_path}/cinder"

#glance
echo "backup glance conf files..."
mkdir "${conf_path}/glance"
cp -a -R /etc/glance/* "${conf_path}/glance"

#neutron
echo "backup neutron conf files..."
mkdir "${conf_path}/neutron"
cp -a -R /etc/neutron/* "${conf_path}/neutron"

#swift
echo "backup swift conf files..."
mkdir "${conf_path}/swift"
cp -a -R /etc/swift/* "${conf_path}/swift"

#mysql
echo "backup mysql conf files..."
mkdir "${conf_path}/mysql"
cp -a -R /etc/mysql/ "${conf_path}/mysql"

#keystone
echo "backup keystone conf files..."
mkdir "${conf_path}/keystone"
cp -a -R /etc/keystone/ "${conf_path}/keystone"

#horizon
echo "backup openstack-dashboard conf files..."
mkdir "${conf_path}/openstack-dashboard"
cp -a -R /etc/openstack-dashboard/* "${conf_path}/openstack-dashboard"

#ceph
echo "backup ceph conf files..."
mkdir "${conf_path}/ceph"
cp -a -R /etc/ceph/* "${conf_path}/ceph"


#haproxy
echo "backup haproxy conf files..."
mkdir "${conf_path}/haproxy"
cp -a -R /etc/haproxy/* "${conf_path}/haproxy"


# delete old file versions - more than 30 days
#find $conf_path/* -mtime +30 -exec rm {} \;

echo "Configuration files backup ended successfully :-)"

# bash_history backup

#create bhist folder
if [ ! -e $bhist_path ]; then
           mkdir $bhist_path
fi

cat cat .bash_history > $bhist_path/bhistory_$date

#create status folder
if [ ! -e $status_path ]; then
           mkdir $status_path
fi

#default permission to file

umask 077

cat /var/lib/mysql/grastate.dat > $status_path/grastate_$date

crm status > $status_path/crm_status_$date

#copying backup directory in another host
#echo "Backup syncronizing in another host"
#rsync -avz -e "ssh -i /root/.ssh/rsync" /root/backup/ root@10.250.3.124:/root/backup


#eliminazione vecchi backup
date_limit=$(date +"%Y-%m-%d" -d "-20 days")

echo "Check for backup older than :" $date_limit

for D in `ls backup/`
do

todate=$(date -d $D +"%y%m%d")
cond=$(date -d  $date_limit +"%y%m%d" )
#echo "$cond > $todate"
if [ $cond -ge $todate ]; #put the loop where you need it
then
 echo 'Found old backup : '$D;
rm -r /root/backup/$D
fi

done
