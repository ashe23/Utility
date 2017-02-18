#!/bin/bash -x
# Script for creating virtualhosts for Apache2 and Nginx in Ubuntu
# default path for apache2 is /etc/apache2/sites-available
# default path for nginx is /etc/nginx/sites-available
# Algorithm for creating vhosts
# 1) Checking if required directories existing(/etc/apache2/sites-available and /etc/nginx/sites-available)
# 2) Getting Server name
# 3) Getting Project Directory name
# 4) Getting Url to host
# 4) Checking if project dir name exist
# 6) Creating config file for specified server
# 7) adding to /etc/hosts

# constant variables (actual for ubuntu style distros)
apacheDir="/etc/apache2/sites-available"
nginxDir="/etc/nginx/sites-available"
APACHE_LOG_DIR="/var/log/apache2"
NGINX_LOG_DIR="/var/log/nginx"
E_NOT_ROOT=87
APACHE=1
NGINX=2
vHostConfFile=""
vHostRootDir="/var/www"
vHostName=""
apachePort=8000
nginxPort=80


# function for checking vhost directories
isDirectoriesExist () {
	if [ ! -d $apacheDir ]; then
		echo "Apache vhosts directory not existing($apacheDir).Try install Apache."
		exit
	# elif [ ! -d $nginxDir ]; then
	# 	echo 'Nginx vhosts directory not existing($nginxDir).Try install Nginx.'
	# 	exit
	fi
}

createApacheVhost () {
if ! echo "<VirtualHost *:$apachePort>
	ServerName $vHostName
	DocumentRoot $vHostRootDir
	ErrorLog $APACHE_LOG_DIR/error.log
	CustomLog $APACHE_LOG_DIR/access.log combined
</VirtualHost>" > $vHostConfFile
		then
			echo "There is an ERROR creating $vHostName file\n"
			exit;
		else
			echo "New Virtual Host Created\nVhost-$vHostName\tRootDir-$vHostRootDir"
		fi
}

# Script available only for root
checkPermission () {
	if [ "$(whoami)" != 'root' ]; then
		echo "You have no permission to run $0 as non-root user. Use sudo instead"
		exit $E_NOT_ROOT;
	fi
}

createAlias () {
	if ! echo "127.0.0.1	$vHostName" >> /etc/hosts
	then
		echo "ERROR: Not able to write in /etc/hosts"
		exit;
	else
		echo "Host added to /etc/hosts file \n"
	fi
}

activateVhost () {
	a2ensite $vHostName
}

createvHostTempFiles () {
	mkdir $vHostRootDir
	chmod 755 $vHostRootDir
	touch $vHostRootDir/index.php
	if ! echo "<?php phpinfo();" >> $vHostRootDir/index.php
	then
		echo "ERROR: Not able to write in $vHostRootDir/index.php"
		exit;
	else
		echo "Index file created."
	fi
}

checkPermission
isDirectoriesExist

# Getting Server Name
echo 'What server\n1 - Apache2\n2 - Nginx'
read server
echo 'processing...'
if [ "$server" = $APACHE ]; then
	echo "Type vhost dirname:"
	# TODO Check for empty string and allowed charecters
	read vHostName
	# creating apache virtualhost
	vHostRootDir="$vHostRootDir/$vHostName"
	vHostConfFile="$apacheDir/$vHostName.conf"
	echo $vHostName
	echo $vHostRootDir
	echo $vHostConfFile
	createApacheVhost
	createAlias
	activateVhost
	createvHostTempFiles
elif [ $server = $NGINX ]; then
	# creating nginx virtualhost
	createNginxVhost
else
	echo 'Wrong data.Server not exist'
fi