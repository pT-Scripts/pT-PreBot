#!/bin/bash

# MySQL database connection details
db_host=""
db_user=""
db_password=""
db_name=""
main_table="MAIN"  # Assuming MAIN is the main table

# Main script logic
if [ $# -ne 3 ]; then
    echo "Usage: $0 <release> <files> <size>"
    exit 1
fi

release="$1"
files="$2"
size="$3"

# Check for special case where files or size is '-'
if [ "$files" == "-" ] || [ "$size" == "-" ]; then
    exit 0  # Exit silently without performing any updates
fi

# Get current datetime on the server
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')

# Check if release already exists in the database
existing_release=$(mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -N -B -e "SELECT rlsname FROM $main_table WHERE rlsname='$release';")

if [ -z "$existing_release" ]; then
    # Release does not exist, insert new record with status ADDOLD
    query="INSERT INTO $main_table (rlsname, files, size, lastupdated, status) 
           VALUES ('$release', '$files', '$size', '$current_datetime', 'ADDOLD');"
else
    # Release exists, update files, size, and set status to ADDOLD
    query="UPDATE $main_table 
           SET files = '$files',
               size = '$size',
               lastupdated = '$current_datetime',
               status = 'ADDOLD'
           WHERE rlsname = '$release';"
fi

# Execute MySQL query silently
mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query" > /dev/null 2>&1

# Echo the output in the required format
echo "Updated files and size for $release with status ADDOLD"
