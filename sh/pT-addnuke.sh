#!/bin/bash

# MySQL database configuration
db_host=""
db_user=""
db_password=""
db_name=""
nuke_table="NUKE"
main_table="MAIN"

# Main script logic
if [ $# -lt 3 ]; then
    echo "Insufficient arguments."
    exit 1
fi

release="$1"
reason="$2"
nukenet="$3"
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')  # Current datetime in the format MySQL expects

# Extract group from release (assuming format: group-releasename)
group=$(echo "$release" | awk -F '-' '{print $2}')

# Construct the query for inserting into the NUKE table
nuke_query="INSERT INTO $nuke_table (rlsname, \`group\`, datetime, nuke, reason, nukenet) 
            VALUES ('$release', '$group', '$current_datetime', 'NUKE', '$reason', '$nukenet');"

# Execute MySQL query for inserting into NUKE table silently
mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$nuke_query" >/dev/null 2>&1

# Note: You may want to handle errors and logging more robustly in a production script.

# Construct the query for updating nukereason in MAIN table
main_query="UPDATE $main_table 
            SET nukereason = '$reason'
            WHERE rlsname = '$release';"

# Execute MySQL query for updating MAIN table silently
mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$main_query" >/dev/null 2>&1


exit 0
