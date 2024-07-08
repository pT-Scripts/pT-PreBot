#!/bin/bash

# Database credentials
db_host=""
db_user=""
db_password=""
db_name=""  # Adjusted to your database name
main_table="MAIN"
nuke_table="NUKE"

# Base MySQL command
MYSQL_CMD="mysql -h $db_host -u $db_user -p$db_password -D $db_name -s -N -e"

# Function to execute MySQL queries
execute_query() {
  local query="$1"
  result=$($MYSQL_CMD "$query")
  if [ $? -ne 0 ]; then
    echo "MySQL query failed: $query"
    exit 1
  fi
  echo "$result"
}

# Function to calculate time elapsed since a given datetime
calculate_time_elapsed() {
  local datetime="$1"
  
  if [ "$datetime" = "0000-00-00 00:00:00" ]; then
    echo "No time found"
    return
  fi

  local current_time=$(date +%s)
  local datetime_seconds=$(date -d "$datetime" +%s)
  local elapsed_seconds=$(( current_time - datetime_seconds ))

  local years=$(( elapsed_seconds / 31536000 ))
  local remainder=$(( elapsed_seconds % 31536000 ))
  local months=$(( remainder / 2592000 ))
  remainder=$(( remainder % 2592000 ))
  local days=$(( remainder / 86400 ))
  remainder=$(( remainder % 86400 ))
  local hours=$(( remainder / 3600 ))
  remainder=$(( remainder % 3600 ))
  local minutes=$(( remainder / 60 ))
  local seconds=$(( remainder % 60 ))

  local elapsed_time=""

  if [ $years -gt 0 ]; then
    elapsed_time+=" $years y"
  fi
  if [ $months -gt 0 ]; then
    elapsed_time+=" $months m"
  fi
  if [ $days -gt 0 ]; then
    elapsed_time+=" $days d"
  fi
  if [ $hours -gt 0 ]; then
    elapsed_time+=" $hours h"
  fi
  if [ $minutes -gt 0 ]; then
    elapsed_time+=" $minutes min"
  fi
  if [ $seconds -gt 0 ]; then
    elapsed_time+=" $seconds sec"
  fi

  echo "$elapsed_time ago"
}

# Function to fetch database statistics
fetch_database_stats() {
  local group_name="$1"

  # Total releases in MAIN table
  total_releases=$(execute_query "SELECT COUNT(*) FROM $main_table WHERE \`group\`='$group_name';")
  if [ "$total_releases" -eq 0 ]; then
    echo "Group '$group_name' not found in database."
    exit 1
  fi

  echo "14[GROUP INFO] ::09 $group_name  has a total of 09 $total_releases  releases"

  # Last release in MAIN table
  last_release=$(execute_query "SELECT rlsname, datetime FROM $main_table WHERE \`group\`='$group_name' ORDER BY datetime DESC LIMIT 1;")
  if [ -n "$last_release" ]; then
    read -r last_rlsname last_datetime <<< "$last_release"
    time_since_last_release=$(calculate_time_elapsed "$last_datetime")
    echo "07Latest release: $last_rlsname - pred $time_since_last_release"
  fi

  # First release in MAIN table
  first_release=$(execute_query "SELECT rlsname, datetime FROM $main_table WHERE \`group\`='$group_name' ORDER BY datetime ASC LIMIT 1;")
  if [ -n "$first_release" ]; then
    read -r first_rlsname first_datetime <<< "$first_release"
    time_since_first_release=$(calculate_time_elapsed "$first_datetime")
    echo "07First release: $first_rlsname - pred $time_since_first_release"
  fi

  # Total size of releases in MAIN table (in original format)
  total_size_str=$(execute_query "SELECT SUM(size) FROM $main_table WHERE \`group\`='$group_name';")
  echo "07Total size of releases: $total_size_str bytes"

  # Number of nuked releases in NUKE table
  nuked_releases=$(execute_query "SELECT COUNT(*) FROM $nuke_table WHERE \`group\`='$group_name' AND status='NUKE';")
  echo "NUKES: $nuked_releases"

  # Last nuked release name and reason
  last_nuked=$(execute_query "SELECT rlsname, reason FROM $nuke_table WHERE \`group\`='$group_name' AND status='NUKE' ORDER BY datetime DESC LIMIT 1;")
  if [ -n "$last_nuked" ]; then
    read -r rlsname reason <<< "$last_nuked"
    echo "Last NUKED release: $rlsname - Reason: $reason"
  fi
}

# Function to fetch group statistics from API
fetch_api_stats() {
  local group_name="$1"
  local api_url="https://api.predb.net/?type=groupstats&group=${group_name}"
  local response=$(curl -s "$api_url")

  # Check if API request was successful
  local status=$(echo "$response" | jq -r '.status')
  if [ "$status" != "success" ]; then
    echo "Group '$group_name' not found in PreDB.net."
    exit 1
  fi

  # Extract data from API response
  local total=$(echo "$response" | jq -r '.data.total')
  local first_pre=$(echo "$response" | jq -r '.data.first_pre[0].release')
  local first_pre_date=$(echo "$response" | jq -r '.data.first_pre[0].pretime' | xargs -I{} date -d @{} '+%Y-%m-%d %H:%M:%S')
  local last_pre=$(echo "$response" | jq -r '.data.last_pre[0].release')
  local last_pre_date=$(echo "$response" | jq -r '.data.last_pre[0].pretime' | xargs -I{} date -d @{} '+%Y-%m-%d %H:%M:%S')

  # Print the fetched data
  echo "11[PreDB.Net] - Fetching from API"
  echo "07Total Releases: ${total}"
  echo "07First Release: ${first_pre} on ${first_pre_date}"
  echo "07Latest Release: ${last_pre} on ${last_pre_date}"
}

# Function to create indexes if not exist
create_indexes() {
  execute_query "CREATE INDEX IF NOT EXISTS idx_group_main ON $main_table (\`group\`);"
  execute_query "CREATE INDEX IF NOT EXISTS idx_group_nuke ON $nuke_table (\`group\`);"
}

# Function to display usage
usage() {
  echo "Usage: $0 [group name]"
  exit 1
}

# Main script execution starts here

# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
  usage
fi

# Assign argument to variable
group_name="$1"

# Create indexes if not already existing
create_indexes

# Fetch and display database data if group exists
fetch_database_stats "$group_name"

# Fetch and display API data
fetch_api_stats "$group_name"

exit 0
