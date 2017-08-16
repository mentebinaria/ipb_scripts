#!/bin/bash

mysql_dbname=
mysql_user=

sql_query() {
	echo Username: $mysql_user
	mysql -v --database $mysql_dbname -u $mysql_user -p < <(echo "$1")
}

sql_query "$1"
