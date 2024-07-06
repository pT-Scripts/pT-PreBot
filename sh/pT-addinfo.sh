#!/bin/bash

# MySQL database connection details
db_host=""
db_user="w"
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

# Function to execute MySQL queries and handle errors
execute_query() {
    local query="$1"
    mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: MySQL query execution failed: $query"
        exit 1
    fi
}

# Check if rlsname already exists in MAIN table
exists=$(mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -se "SELECT COUNT(*) FROM $db_table WHERE rlsname='$release' AND status <> 'ADDINFO';" 2>/dev/null)

if [ "$exists" -eq 1 ]; then
    # Release exists and status is not ADDINFO, update existing record
    query="UPDATE $db_table 
           SET files = '$files',
               size = '$size',
               lastupdated = '$current_datetime',
               status = 'ADDINFO'
           WHERE rlsname = '$release';"
    
    # Execute the MySQL update query
    execute_query "$query"
    
    # Echo the INFO line for update
    echo "11[INFO] :: $release :: 11FILES: $files :: 11SIZE: $size"
fi

exit 0
