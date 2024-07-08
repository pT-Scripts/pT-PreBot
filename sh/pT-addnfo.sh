#!/bin/bash

# MySQL database configuration
db_host=""
db_user=""
db_password=""
db_name=""    # Updated database name
xtra_table="XTRA" # XTRA table name for additional URLs

# Main script logic
if [ $# -lt 2 ]; then
    echo "Usage: $0 <release> <nfo>"
    exit 1
fi

release="$1"
nfo="$2"
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')  # Current datetime in the format MySQL expects

# Check if rlsname already exists in XTRA table
exists=$(mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -se "SELECT COUNT(*) FROM $xtra_table WHERE rlsname='$release';" 2>/dev/null)

if [ "$exists" -gt 0 ]; then
    # Construct MySQL query to update existing record
    query="UPDATE $xtra_table SET nfo='$nfo', lastupdated='$current_datetime' WHERE rlsname='$release';"
else
    # Construct MySQL query to insert new record
    query="INSERT INTO $xtra_table (rlsname, nfo, lastupdated) 
           VALUES ('$release', '$nfo', '$current_datetime');"
fi

# Execute MySQL query silently
mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$query" > /dev/null 2>&1
