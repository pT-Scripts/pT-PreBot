#!/bin/bash

# MySQL database configuration
db_host="133.133.133.133"
db_user="someuser"
db_password="somepass"
db_name="YourDBname"
nuke_table="NUKE"
main_table="MAIN"
xtra_table="XTRA"

# Main script logic
if [ $# -lt 3 ]; then
    exit 1
fi

release="$1"
reason="$2"
nukenet="$3"
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')  # Current datetime in the format MySQL expects

# Extract group from release (assuming format: group-releasename)
group=$(echo "$release" | awk -F '-' '{print $2}')

# Construct the query for updating the NUKE table to UNNUKE
nuke_query="INSERT INTO $nuke_table (rlsname, \`group\`, datetime, nuke, reason, nukenet) 
            VALUES ('$release', '$group', '$current_datetime', 'UNNUKE', '$reason', '$nukenet');"

# Execute MySQL query for inserting into NUKE table silently
mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$nuke_query" >/dev/null 2>&1

# Construct the query for updating nukereason to NULL in MAIN table
main_query="UPDATE $main_table 
            SET nukereason = NULL
            WHERE rlsname = '$release';"

# Execute MySQL query for updating MAIN table silently
mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$main_query" >/dev/null 2>&1
