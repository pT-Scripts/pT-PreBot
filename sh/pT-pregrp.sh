#!/bin/bash

# Database credentials
db_host="133.133.133.133"
db_user="someuser"
db_password="somepass"
db_name="YourDBname"
DB_TABLE_MAIN="MAIN"
DB_TABLE_NUKE="NUKE"

# Base MySQL command
MYSQL_CMD="mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -D $DB_NAME -s -N -e"

# Function to execute MySQL queries and suppress warnings
execute_query() {
  local query="$1"
  $MYSQL_CMD "$query" 2>/dev/null  # Redirect stderr to /dev/null
}

# Function to calculate time elapsed since a given datetime
calculate_time_elapsed() {
  local datetime="$1"
  
  # Check if datetime is '0000-00-00 00:00:00'
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

# Function to get total releases in MAIN table
get_total_releases() {
  local query="SELECT COUNT(*) FROM $DB_TABLE_MAIN WHERE \`group\`='$GROUP';"
  execute_query "$query"
}

# Function to get last release in MAIN table
get_last_release() {
  local query="SELECT rlsname, datetime FROM $DB_TABLE_MAIN WHERE \`group\`='$GROUP' ORDER BY datetime DESC LIMIT 1;"
  execute_query "$query"
}

# Function to get first release in MAIN table
get_first_release() {
  local query="SELECT rlsname, datetime FROM $DB_TABLE_MAIN WHERE \`group\`='$GROUP' ORDER BY datetime ASC LIMIT 1;"
  execute_query "$query"
}

# Function to get total size of releases in MAIN table
get_total_size() {
  local query="SELECT SUM(size) FROM $DB_TABLE_MAIN WHERE \`group\`='$GROUP';"
  execute_query "$query"
}

# Function to get number of nuked releases in NUKE table (only counting 'NUKE' and ignoring 'MODNUKE')
get_nuked_releases() {
  local query="SELECT COUNT(*) FROM $DB_TABLE_NUKE WHERE \`group\`='$GROUP' AND nuke='NUKE';"
  execute_query "$query"
}

# Function to get number of unnuked releases in NUKE table (counting 'UNNUKE' and ignoring 'MODNUKE')
get_unnuked_releases() {
  local query="SELECT COUNT(*) FROM $DB_TABLE_NUKE WHERE \`group\`='$GROUP' AND nuke='UNNUKE';"
  execute_query "$query"
}

# Function to get last nuked release name and reason
get_last_nuked() {
  local query="SELECT rlsname, raison FROM $DB_TABLE_NUKE WHERE \`group\`='$GROUP' AND nuke='NUKE' ORDER BY datetime DESC LIMIT 1;"
  execute_query "$query"
}

# Function to get last unnuked release name and reason
get_last_unnuked() {
  local query="SELECT rlsname, raison FROM $DB_TABLE_NUKE WHERE \`group\`='$GROUP' AND nuke='UNNUKE' ORDER BY datetime DESC LIMIT 1;"
  execute_query "$query"
}

# Main script execution starts here

# Check for the correct number of arguments
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <groupname>"
  exit 1
fi

# Assign argument to variable
GROUP="$1"

# Total releases in MAIN table
total_releases=$(get_total_releases)
echo "Group has a total of $total_releases releases"

# Last release in MAIN table
last_release=$(get_last_release)
if [ -n "$last_release" ]; then
  read -r last_rlsname last_datetime <<< "$last_release"
  time_since_last_release=$(calculate_time_elapsed "$last_datetime")
  echo "Last release: $last_rlsname - pred $time_since_last_release"
else
  echo "No releases found."
fi

# First release in MAIN table
first_release=$(get_first_release)
if [ -n "$first_release" ]; then
  read -r first_rlsname first_datetime <<< "$first_release"
  time_since_first_release=$(calculate_time_elapsed "$first_datetime")
  echo "First release: $first_rlsname - pred $time_since_first_release"
else
  echo "No releases found."
fi

# Total size of releases in MAIN table (in original format)
total_size_str=$(get_total_size)
echo "Total size of releases: $total_size_str bytes"

# Number of nuked releases in NUKE table
nuked_releases=$(get_nuked_releases)
echo "NUKES: $nuked_releases"

# Number of unnuked releases in NUKE table
unnuked_releases=$(get_unnuked_releases)
echo "UNNUKES: $unnuked_releases"

# Calculate percentage of nuked releases
if [ "$total_releases" -gt 0 ]; then
  percentage_nuked=$(echo "scale=2; ($nuked_releases / $total_releases) * 100" | bc)
else
  percentage_nuked="0.00"
fi

echo "Percentage of nuked releases: $percentage_nuked%"

# Last nuked release name and reason
last_nuked=$(get_last_nuked)
if [ -n "$last_nuked" ]; then
  read -r rlsname raison <<< "$last_nuked"
  echo "Last NUKED release: $rlsname - Reason: $raison"
else
  echo "No nuked releases found."
fi

# Last unnuked release name and reason
last_unnuked=$(get_last_unnuked)
if [ -n "$last_unnuked" ]; then
  read -r rlsname raison <<< "$last_unnuked"
  echo "Last UNNUKED release: $rlsname - Reason: $raison"
else
  echo "No unnuked releases found."
fi

