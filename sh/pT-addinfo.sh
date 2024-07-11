#!/bin/bash

# MySQL database connection details
db_host=""
db_user=""
db_password=""
db_name=""
main_table="MAIN"  # Assuming MAIN is the main table

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
    mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" --skip-column-names --batch -e "$query"
    if [ $? -ne 0 ]; then
        echo "Error: MySQL query execution failed: $query"
        exit 1
    fi
}

# Check if rlsname already exists in MAIN table and status is ADDINFO
status=$(mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" --skip-column-names --batch -se "SELECT status FROM $main_table WHERE rlsname='$release';" 2>/dev/null)

if [ "$status" == "ADDINFO" ]; then
    # Release exists and status is ADDINFO, skip processing
    exit 0
fi

if [ "$status" != "" ]; then
    # Release exists and status is not ADDINFO, update existing record
    query="UPDATE $main_table 
           SET files = '$files',
               size = '$size',
               lastupdated = '$current_datetime',
               status = 'ADDINFO'
           WHERE rlsname = '$release' AND status <> 'ADDINFO';"

    # Execute the MySQL update query
    execute_query "$query"

    # Echo the INFO line for update
    echo "11INFO ::  $release  :: 11FiLES: $files  :: 11SiZE: $size 11MB"
fi

exit 0
