#!/bin/bash

mysql_dbname=
mysql_user=
temp=$(mktemp)
tz=-0300

echo $temp

sql_query() {
	echo Username: $mysql_user
	mysql --database $mysql_dbname -u $mysql_user -p < <(echo "$1")
}

get_post_date() {
	date -d @$(tr \\n , < $temp | tr \\t , | cut -d, -f8) "+%F %R:%S %z"
}

get_topic() {
	tr \\n , < $temp | tr \\t , | cut -d, -f9
}


read -p 'Post ID: ' pid

sql_query "SELECT pid,author_name,post_date,topic_id FROM forums_posts WHERE pid=$pid;" > $temp

echo "Current post date is $(get_post_date)"
read -p "New post date (YYYY-MM-DD HH:mm:SS $tz): " new_date

new_date_str=$(date -d "$new_date" "+%F %R:%S %z")
new_date_timestamp=$(date -d "$new_date" +%s)

read -p "Do you confirm changing date of topic to $new_date_str (y/N)? " answer
[ "$answer" == "y" ] || exit

sql_query "UPDATE forums_posts SET post_date=$new_date_timestamp WHERE pid=$pid;"
echo Done.

tid=$(get_topic)

read -p "Update parent topic (TID: $tid) timestamps too (y/N)? "
[ "$answer" == "y" ] || exit

sql_query "UPDATE forums_topics SET last_post=$new_date_timestamp, last_real_post=$new_date_timestamp WHERE tid=$tid;"
rm -f $temp
