#!/bin/bash

# MySQL database connection details
db_host=""
db_user=""
db_password=""
db_name=""
db_table="MAIN"  # Assuming MAIN is the main table

# Main script logic
if [ $# -lt 2 ]; then
    echo "Usage: $0 <release> <section>"
    exit 1
fi

release="$1"
section="$2"
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')  # Current datetime in the format MySQL expects

# Extract groupname from release (assuming format: groupname-releasename)
groupname=$(echo "$release" | awk -F '-' '{print $NF}')

# Check if release already exists in the database
existing_release=$(mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -N -B -e "SELECT rlsname FROM $db_table WHERE rlsname='$release';")

if [ -z "$existing_release" ]; then
    # Release does not exist, insert new record with status ADDPRE and section
    query="INSERT INTO $db_table (rlsname, section, datetime, lastupdated, status, \`group\`) 
           VALUES ('$release', '$section', '$current_datetime', '$current_datetime', 'ADDPRE', '$groupname');"
    # Execute MySQL query silently
    mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query" > /dev/null 2>&1

    # Echo the output in the required format
    echo "11[PRE] ::7 $section :: $release"
else
    # Release exists, update section
    query="UPDATE $db_table 
           SET section = '$section',
               lastupdated = '$current_datetime',
               \`group\` = '$groupname'
           WHERE rlsname = '$release';"
    # Execute MySQL query silently
    mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query" > /dev/null 2>&1
fi