#!/bin/bash

ipb_user=
ipb_dir=
mysql_dbname=
mysql_user=

check_perms() {
	[ $EUID = 0 ] || { echo 'You are not root. Bye...'; exit 1; }
}

sql_query() {
	echo Username: $mysql_user
	mysql --database $mysql_dbname -u $mysql_user -p < <(echo "$1")
}

enable_user() {
	sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
	service ssh reload
	passwd --unlock $ipb_user
	echo "[*] $ipb_user enabled for SSH login"
	chown -R $ipb_user: $ipb_dir
	chown -R www-data: $ipb_dir/datastore $ipb_dir/uploads
	echo "[*] $ipb_dir permissions set"
	sql_query "UPDATE core_members SET temp_ban=0 WHERE name='$ipb_user';"
	echo "[*] $ipb_user ENABLED on this system and AdminCP"
}

disable_user() {
	sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
	service ssh reload
	passwd --lock $ipb_user
	echo "[*] $ipb_user disabled for SSH login"
	chown -R www-data: $ipb_dir
	echo "[*] $ipb_dir permissions set"
	sql_query "UPDATE core_members SET temp_ban=-1 WHERE name='$ipb_user';"
	echo "[*] $ipb_user DISABLED on this system and AdminCP"
}

if [ "$1" == "--enable" -o "$1" == "-e" ]; then
	check_perms
	enable_user
elif [ "$1" == "--disable" -o "$1" == "-d" ]; then
	check_perms
	disable_user
else
	echo -e "Usage:\n\t$0 [--enable | --disable]"
	exit 0
fi

