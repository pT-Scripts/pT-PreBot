#!/bin/bash

# MySQL database connection details
db_host=""
db_user=""
db_password=""
db_name=""
db_table="MAIN"  # Assuming MAIN is the main table

# Main script logic
if [ $# -lt 3 ]; then
    echo "Usage: $0 <release> <files> <size>"
    exit 1
fi

release="$1"
files="$2"
size="$3"
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')  # Current datetime in the format MySQL expects

# Check if rlsname already exists in MAIN table
exists=$(mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -se "SELECT COUNT(*) FROM $db_table WHERE rlsname='$release';" 2>/dev/null)

if [ "$exists" -eq 0 ]; then
    # Construct MySQL query to insert new record with status ADDPRE
    query="INSERT INTO $db_table (rlsname, files, size, datetime, lastupdated, status) 
           VALUES ('$release', '$files', '$size', '$current_datetime', '$current_datetime', 'ADDPRE');"
    # Execute MySQL query silently
    mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query" > /dev/null 2>&1

    # Echo the INFO line
    echo "11[INFO] :: $release :: 11FILES: $files :: 11SIZE: $size MiB"
else
    # Construct MySQL query to update existing record
    query="UPDATE $db_table 
           SET files = '$files',
               size = '$size',
               lastupdated = '$current_datetime'
           WHERE rlsname = '$release';"
    # Execute MySQL query silently
    mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query" > /dev/null 2>&1
fi

exit 0
