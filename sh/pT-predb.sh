#!/bin/bash

# Database credentials
db_host=""
db_user=""
db_password=""
db_name=""
main_table="MAIN"
nuke_table="NUKE"

# Base MySQL command with stderr redirected to /dev/null
MYSQL_CMD="mysql -h $db_host -u $db_user -p$db_password -D $db_name -s -N -e"

# Function to execute MySQL queries and suppress warnings
execute_query() {
  local query="$1"
  $MYSQL_CMD "$query" 2>/dev/null
}

# Function to format numbers with commas
format_number() {
  printf "%'d" "$1"
}

# Function to create indexes if they do not exist
create_indexes() {
  execute_query "CREATE INDEX IF NOT EXISTS idx_datetime ON $main_table (\`datetime\`);"
  execute_query "CREATE INDEX IF NOT EXISTS idx_group ON $main_table (\`group\`);"
  execute_query "CREATE INDEX IF NOT EXISTS idx_status ON $nuke_table (\`status\`);"
}

# Function to get total number of releases in MAIN table
get_total_releases() {
  local query="SELECT COUNT(*) FROM $main_table;"
  execute_query "$query"
}

# Function to get the first release (rlsname and datetime) based on the earliest datetime after 1989 in MAIN table
get_first_release() {
  local query="SELECT \`rlsname\`, UNIX_TIMESTAMP(\`datetime\`) AS unix_datetime FROM $main_table WHERE \`datetime\` >= '1989-01-01 00:00:00' ORDER BY \`datetime\` ASC LIMIT 1;"
  execute_query "$query"
}

# Function to get the latest release (rlsname and datetime) in MAIN table
get_latest_release() {
  local query="SELECT \`rlsname\`, UNIX_TIMESTAMP(\`datetime\`) AS unix_datetime FROM $main_table WHERE \`datetime\` != '0000-00-00 00:00:00' ORDER BY \`datetime\` DESC LIMIT 1;"
  execute_query "$query"
}

# Function to calculate database size in GB
get_database_size_gb() {
  local query="SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024 / 1024, 2) AS size_gb FROM information_schema.tables WHERE table_schema = '$db_name';"
  execute_query "$query"
}

# Function to calculate time difference in human-readable format
calculate_time_since() {
  local unix_time="$1"
  local current_unix_time=$(date +%s)
  local time_diff=$((current_unix_time - unix_time))

  local seconds=$((time_diff % 60))
  local minutes=$((time_diff / 60 % 60))
  local hours=$((time_diff / 3600 % 24))
  local days=$((time_diff / 86400 % 30))
  local months=$((time_diff / 2629746 % 12))
  local years=$((time_diff / 31556952))

  local time_since="09PRED:"
  if (( years > 0 )); then
    time_since+=" $years y"
  fi
  if (( months > 0 )); then
    time_since+=" $months m"
  fi
  if (( days > 0 )); then
    time_since+=" $days d"
  fi
  if (( hours > 0 )); then
    time_since+=" $hours h"
  fi
  if (( minutes > 0 )); then
    time_since+=" $minutes min"
  fi
  time_since+=" $seconds sec ago"

  echo "$time_since"
}

# Function to get total counts for NUKE and UNNUKE statuses
get_nuke_counts() {
  local query="SELECT \`status\`, COUNT(*) FROM $nuke_table GROUP BY \`status\`;"
  execute_query "$query"
}

# Function to get total number of unique groups in MAIN table
get_total_groups() {
  local query="SELECT COUNT(DISTINCT \`group\`) FROM $main_table;"
  execute_query "$query"
}

# Create indexes
create_indexes

# Main script execution starts here

# Get total number of releases in MAIN table
total_releases=$(get_total_releases)

# Get the first release in MAIN table based on earliest datetime after 1989
first_release_info=$(get_first_release)
first_release_name=$(echo "$first_release_info" | cut -f1)
first_release_unix_time=$(echo "$first_release_info" | cut -f2)
time_since_first_release=$(calculate_time_since "$first_release_unix_time")

# Get the latest release in MAIN table
latest_release_info=$(get_latest_release)
latest_release_name=$(echo "$latest_release_info" | cut -f1)
latest_release_unix_time=$(echo "$latest_release_info" | cut -f2)
time_since_latest_release=$(calculate_time_since "$latest_release_unix_time")

# Get database size in GB
database_size_gb=$(get_database_size_gb)

# Get NUKE and UNNUKE counts
nuke_counts=$(get_nuke_counts)
total_nukes=$(echo "$nuke_counts" | grep -w "NUKE" | cut -f2)
total_unnukes=$(echo "$nuke_counts" | grep -w "UNNUKE" | cut -f2)

# Get total number of unique groups
total_groups=$(get_total_groups)

# Output the summary
echo "09[DB STATS]"
echo "07Total releases: $(format_number "$total_releases")"
echo "14First release: $first_release_name :: $(calculate_time_since "$first_release_unix_time")"
echo "11Latest release: $latest_release_name :: $(calculate_time_since "$latest_release_unix_time")"
echo "04Total NUKES: $(format_number "${total_nukes:-0}")"
echo "09Total UNNUKES: $(format_number "${total_unnukes:-0}")"
echo "12Total groups: $(format_number "$total_groups")"
echo "02Database size: ${database_size_gb}GB"
