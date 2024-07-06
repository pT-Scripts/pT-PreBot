#!/bin/bash

# MySQL database configuration
db_host=""
db_user=""
db_password=""
db_name=""
nuke_table="NUKE"
main_table="MAIN"
xtra_table="XTRA"

# Main script logic
if [ $# -lt 3 ]; then
    echo "Insufficient arguments."
    echo "Usage: $0 <release> <reason> <nukenet>"
    exit 1
fi

release="$1"
reason="$2"
nukenet="$3"
current_datetime=$(date '+%Y-%m-%d %H:%M:%S')  # Current datetime in the format MySQL expects

# Extract group from release (assuming format: releasename-group)
group=$(echo "$release" | awk -F '-' '{print $NF}')  # Get last field after the last hyphen

# Construct the query for inserting into the NUKE table as UNNUKE
nuke_query="INSERT INTO $nuke_table (rlsname, \`group\`, datetime, nuke, reason, nukenet) 
            VALUES ('$release', '$group', '$current_datetime', 'UNNUKE', '$reason', '$nukenet');"

# Execute MySQL query for inserting into NUKE table silently
mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$nuke_query" >/dev/null 2>&1

# Check if the query was successful
if [ $? -eq 0 ]; then
    echo "09[UNNUKE] ::09 $release :: 11REASON:09 $reason :: 11NUKENET:09 $nukenet"
else
    echo "Failed to insert into NUKE table."
    exit 1
fi

# Construct the query for updating nukereason to NULL in MAIN table
main_query="UPDATE $main_table 
            SET nukereason = NULL
            WHERE rlsname = '$release';"

# Execute MySQL query for updating MAIN table silently
mysql -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" -e "$main_query" >/dev/null 2>&1

# Check if the query was successful
if [ $? -ne 0 ]; then
    echo "Failed to update MAIN table."
    exit 1
fi

exit 0
