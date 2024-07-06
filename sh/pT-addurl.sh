#!/bin/bash

# MySQL database configuration
db_host="133.133.133.133"
db_user="someuser"
db_password="somepass"
db_name="YourDBname"
db_name="ADD"
xtra_table="XTRA"

# Main script logic
if [ $# -lt 2 ]; then
    exit 1
fi

release="$1"
url="$2"
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')  # Current datetime in the format MySQL expects

# Check if rlsname already exists in XTRA table
exists=$(mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -se "SELECT COUNT(*) FROM $xtra_table WHERE rlsname='$release';" 2>/dev/null)

if [ "$exists" -eq 0 ]; then
    # Construct MySQL query to insert new record
    query="INSERT INTO $xtra_table (rlsname, lastupdated, addurl, \`group\`, tvmaze, imdb, screen, sfv, nfo, m3u) 
           VALUES ('$release', '$current_datetime', '$url', NULL, NULL, NULL, NULL, NULL, NULL, NULL);"

    # Execute MySQL query silently
    mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query" > /dev/null 2>&1
fi

