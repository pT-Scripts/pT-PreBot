#!/bin/bash

# MySQL database configuration
db_host="133.133.133.133"
db_user="someuser"
db_password="somepass"
db_name="YourDBname"
main_table="MAIN" # Dont edit if you using included .sql structure

# Main script logic
if [ $# -lt 2 ]; then
    exit 1
fi

release="$1"
genre="$2"
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')  # Current datetime in the format MySQL expects

# Construct MySQL query to insert or update record
query="INSERT INTO $main_table (rlsname, lastupdated, genre) 
       VALUES ('$release', '$current_datetime', '$genre')
       ON DUPLICATE KEY UPDATE lastupdated='$current_datetime', genre='$genre';"

# Execute MySQL query silently
mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query" > /dev/null 2>&1
