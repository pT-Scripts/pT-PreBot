#!/bin/bash

# MySQL database configuration
db_host=""
db_user=""
db_password=""
db_name=""    # Updated database name
xtra_table="XTRA" # XTRA table name for additional URLs

# Main script logic
if [ $# -lt 2 ]; then
    echo "Usage: $0 <release> <url>"
    exit 1
fi

release="$1"
url="$2"
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')  # Current datetime in the format MySQL expects

# Check if rlsname already exists in XTRA table
exists=$(mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -se "SELECT COUNT(*) FROM $xtra_table WHERE rlsname='$release';" 2>/dev/null)

if [ "$exists" -eq 0 ]; then
    # Construct MySQL query to insert new record
    query="INSERT INTO $xtra_table (rlsname, lastupdated, addurl) 
           VALUES ('$release', '$current_datetime', '$url');"

    # Execute MySQL query silently
    mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query" > /dev/null 2>&1

    # Echo the INFO line
    echo "12[URL] :: $release :: $url"
fi
