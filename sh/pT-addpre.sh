#!/bin/bash

# MySQL database connection details
db_host=""
db_user=""
db_password=""
db_name=""
db_table="MAIN"

# Validate input arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <release> <section>"
    exit 1
fi

release="$1"
section="$2"
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')
current_unixtime=$(date '+%s')

# Function to execute MySQL queries and handle errors
execute_query() {
    local query="$1"
    mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query"
    if [ $? -ne 0 ]; then
        echo "Error: MySQL query execution failed: $query"
        exit 1
    fi
}

# Check if release already exists
existing_release=$(mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -N -B -e \
    "SELECT rlsname FROM $db_table WHERE rlsname='$release';")

if [ -n "$existing_release" ]; then
    exit 0
fi

# Insert new record since release does not exist
query="INSERT INTO $db_table (rlsname, section, datetime, lastupdated, status, \`group\`, unixtime)
       VALUES ('$release', '$section', '$current_datetime', '$current_datetime', 'ADDPRE', SUBSTRING_INDEX('$release', '-', -1), '$current_unixtime');"

execute_query "$query"

# Echo the output in the required format
echo "11[PRE] ::7 $section :: $release"

exit 0
