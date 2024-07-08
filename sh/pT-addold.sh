#!/bin/bash

# MySQL database connection details
db_host=""
db_user=""
db_password=""
db_name=""
main_table="MAIN"  # Assuming MAIN is the main table

# Main script logic
if [ $# -lt 4 ]; then
    echo "Usage: $0 <release> <section> <date> <time>"
    exit 1
fi

release="$1"
section="$2"
date="$3"
time="$4"

# Combine date and time into datetime format MySQL expects
datetime="$date $time"

# Extract groupname from release (assuming format: groupname-releasename)
groupname=$(echo "$release" | awk -F '-' '{print $NF}')

# Get current datetime on the server
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')

# Check if release already exists in the database
existing_release=$(mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -N -B -e "SELECT rlsname FROM $main_table WHERE rlsname='$release';")

if [ -z "$existing_release" ]; then
    # Release does not exist, insert new record with status ADDOLD and section
    query="INSERT INTO $main_table (rlsname, section, datetime, lastupdated, status, \`group\`) 
           VALUES ('$release', '$section', '$datetime', '$current_datetime', 'ADDOLD', '$groupname');"
    # Execute MySQL query silently
    mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query" > /dev/null 2>&1

    # Echo the output in the required format
    echo "11[ADDOLD] ::7 $section :: $release"
else
    # Release exists, update datetime, lastupdated, section, group, and status
    query="UPDATE $main_table 
           SET section = '$section',
               datetime = '$datetime',
               lastupdated = '$current_datetime',
               \`group\` = '$groupname',
               status = 'ADDOLD'
           WHERE rlsname = '$release';"
    # Execute MySQL query silently
    mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query" > /dev/null 2>&1

    # Echo the output in the required format
    echo "11[ADDOLD] ::7 $section :: $release"
fi
