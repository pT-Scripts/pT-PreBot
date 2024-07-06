#!/bin/bash

# MySQL database configuration
db_host=""
db_user=""
db_password=""
db_name=""    # Updated database name
main_table="MAIN" # MAIN table name

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
