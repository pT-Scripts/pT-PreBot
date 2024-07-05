#!/bin/bash

# Database credentials
DB_HOST=""
DB_USER=""
DB_PASS=""
DB_NAME=""
DB_TABLE_MAIN="MAIN"
DB_TABLE_NUKE="NUKE"

# Base MySQL command with stderr redirected to /dev/null
MYSQL_CMD="mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -D $DB_NAME -s -N -e"

# Function to execute MySQL queries and suppress warnings
execute_query() {
  local query="$1"
  # Append 2>/dev/null to redirect stderr to /dev/null
  $MYSQL_CMD "$query" 2>/dev/null
}

# Function to format numbers with commas
format_number() {
  printf "%'d" "$1"
}

# Function to get total number of releases in MAIN table
get_total_releases() {
  local query="SELECT COUNT(*) FROM $DB_TABLE_MAIN;"
  execute_query "$query"
}

# Function to get total number of nuked releases in NUKE table
get_total_nukes() {
  local query="SELECT COUNT(*) FROM $DB_TABLE_NUKE WHERE nuke='NUKE';"
  execute_query "$query"
}

# Function to get total number of unnuked releases in NUKE table
get_total_unnukes() {
  local query="SELECT COUNT(*) FROM $DB_TABLE_NUKE WHERE nuke='UNNUKE';"
  execute_query "$query"
}

# Function to get total number of distinct groups in MAIN table
get_total_groups() {
  local query="SELECT COUNT(DISTINCT \`group\`) FROM $DB_TABLE_MAIN WHERE \`group\` REGEXP '^[^0-9]';"
  execute_query "$query"
}

# Function to get total number of distinct sections in MAIN table
get_total_sections() {
  local query="SELECT COUNT(DISTINCT section) FROM $DB_TABLE_MAIN;"
  execute_query "$query"
}

# Function to get the group with the most releases in MAIN table
get_group_most_releases() {
  local query="SELECT \`group\`, COUNT(*) AS total_releases FROM $DB_TABLE_MAIN WHERE \`group\` REGEXP '^[^0-9]' GROUP BY \`group\` ORDER BY total_releases DESC LIMIT 1;"
  execute_query "$query"
}

# Function to get the newest group added to the database (group with only one release)
get_newest_group() {
  local query="SELECT \`group\`, MAX(\`datetime\`) AS newest_date FROM $DB_TABLE_MAIN WHERE \`group\` IN (SELECT \`group\` FROM $DB_TABLE_MAIN GROUP BY \`group\` HAVING COUNT(*) = 1) AND \`group\` REGEXP '^[^0-9]' GROUP BY \`group\` ORDER BY newest_date DESC LIMIT 1;"
  execute_query "$query"
}

# Function to get the first release that meets criteria
get_first_release() {
  local query="SELECT \`rlsname\`, \`datetime\` FROM $DB_TABLE_MAIN WHERE \`datetime\` != '0000-00-00 00:00:00' AND \`datetime\` >= '1972-01-01 00:00:00' ORDER BY \`datetime\` ASC LIMIT 1;"
  execute_query "$query"
}

# Function to get the latest release in MAIN table
get_latest_release() {
  local query="SELECT \`rlsname\`, \`datetime\` FROM $DB_TABLE_MAIN WHERE \`datetime\` = (SELECT MAX(\`datetime\`) FROM $DB_TABLE_MAIN WHERE \`datetime\` != '0000-00-00 00:00:00');"
  execute_query "$query"
}

# Function to count invalid datetime values (0000-00-00 00:00:00) and calculate percentage
get_invalid_date_stats() {
  local total_releases=$(get_total_releases)
  local query="SELECT COUNT(*) FROM $DB_TABLE_MAIN WHERE \`datetime\` = '0000-00-00 00:00:00';"
  local invalid_count=$(execute_query "$query")
  
  echo "$invalid_count $total_releases"
}

# Function to count NULL or missing values in specified column
count_null_values() {
  local column="$1"
  local query="SELECT COUNT(*) FROM $DB_TABLE_MAIN WHERE $column IS NULL OR $column = '';"
  execute_query "$query"
}

# Function to get counts and percentages of NULL values in size, files, and genre
get_missing_data_stats() {
  local total_releases=$(get_total_releases)

  # Count NULL values for size, files, and genre
  local missing_size=$(count_null_values "size")
  local missing_files=$(count_null_values "files")
  local missing_genre=$(count_null_values "genre")

  echo "$missing_size $missing_files $missing_genre $total_releases"
}

# Function to get counts and percentages of NULL or invalid datetime values
get_missing_datetime_stats() {
  local total_releases=$(get_total_releases)

  # Count NULL or '0000-00-00 00:00:00' datetime values
  local missing_datetime_query="SELECT COUNT(*) FROM $DB_TABLE_MAIN WHERE \`datetime\` IS NULL OR \`datetime\` = '0000-00-00 00:00:00';"
  local missing_datetime_count=$(execute_query "$missing_datetime_query")

  echo "$missing_datetime_count $total_releases"
}

# Function to calculate database size in GB
get_database_size_gb() {
  local query="SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024 / 1024, 2) AS size_gb FROM information_schema.tables WHERE table_schema = '$DB_NAME';"
  execute_query "$query"
}

# Function to calculate percentage
calculate_percentage() {
  local numerator="$1"
  local denominator="$2"
  
  if [[ $denominator -eq 0 ]]; then
    echo "0.00%"
  else
    local percentage=$(echo "scale=2; ($numerator / $denominator) * 100" | bc)
    echo "$percentage%"
  fi
}

# Function to calculate time difference in years, months, days, hours, minutes, and seconds
calculate_time_since() {
  local datetime="$1"
  local now=$(date +%s)
  local release_date=$(date -d "$datetime" +%s)
  local time_since=$((now - release_date))

  local years=$((time_since / 31536000))  # 31536000 seconds = 1 year
  local remaining_seconds=$((time_since % 31536000))
  local months=$((remaining_seconds / 2628000))  # 2628000 seconds = 1 month
  local days=$((remaining_seconds / 86400))     # 86400 seconds = 1 day
  remaining_seconds=$((remaining_seconds % 86400))
  local hours=$((remaining_seconds / 3600))
  remaining_seconds=$((remaining_seconds % 3600))
  local minutes=$((remaining_seconds / 60))
  local seconds=$((remaining_seconds % 60))

  if [[ $years -gt 0 ]]; then
    echo "($years years ago)"
  elif [[ $months -gt 0 ]]; then
    echo "($months months ago)"
  else
    echo "($days days $hours hours $minutes minutes $seconds seconds ago)"
  fi
}


# Main script execution starts here

# Get total number of releases
total_releases=$(get_total_releases)

# Get total number of nuked releases from NUKE table
total_nukes=$(get_total_nukes)

# Get total number of unnuked releases
total_unnukes=$(get_total_unnukes)

# Get total number of distinct groups
total_groups=$(get_total_groups)

# Get total number of distinct sections
total_sections=$(get_total_sections)

# Get the group with the most releases
group_most_releases=$(get_group_most_releases)
most_releases_group=$(echo "$group_most_releases" | cut -d$'\t' -f1)
total_releases_most=$(echo "$group_most_releases" | cut -d$'\t' -f2)

# Get the newest group added (group with only one release)
newest_group=$(get_newest_group)
newest_group_name=$(echo "$newest_group" | cut -d$'\t' -f1)
newest_group_date=$(echo "$newest_group" | cut -d$'\t' -f2)
newest_group_time_since=$(calculate_time_since "$newest_group_date")

# Get the first release
first_release=$(get_first_release)
first_release_name=$(echo "$first_release" | cut -d$'\t' -f1)
first_release_date=$(echo "$first_release" | cut -d$'\t' -f2)
first_release_time_since=$(calculate_time_since "$first_release_date")

# Get the latest release
latest_release=$(get_latest_release)
latest_release_name=$(echo "$latest_release" | cut -d$'\t' -f1)
latest_release_date=$(echo "$latest_release" | cut -d$'\t' -f2)

# Get invalid datetime statistics
invalid_date_stats=$(get_invalid_date_stats)
invalid_count=$(echo "$invalid_date_stats" | cut -d' ' -f1)
total_releases_count=$(echo "$invalid_date_stats" | cut -d' ' -f2)

# Get missing data statistics
missing_data_stats=$(get_missing_data_stats)
missing_size=$(echo "$missing_data_stats" | cut -d' ' -f1)
missing_files=$(echo "$missing_data_stats" | cut -d' ' -f2)
missing_genre=$(echo "$missing_data_stats" | cut -d' ' -f3)
total_releases_count=$(echo "$missing_data_stats" | cut -d' ' -f4)

# Get missing datetime statistics
missing_datetime_stats=$(get_missing_datetime_stats)
missing_datetime_count=$(echo "$missing_datetime_stats" | cut -d' ' -f1)
total_releases_count=$(echo "$missing_datetime_stats" | cut -d' ' -f2)

# Get database size in GB
database_size_gb=$(get_database_size_gb)

# Calculate percentages
percentage_nuked=$(calculate_percentage "$total_nukes" "$total_releases")
percentage_invalid=$(calculate_percentage "$invalid_count" "$total_releases_count")
percentage_missing_size=$(calculate_percentage "$missing_size" "$total_releases_count")
percentage_missing_files=$(calculate_percentage "$missing_files" "$total_releases_count")
percentage_missing_genre=$(calculate_percentage "$missing_genre" "$total_releases_count")
percentage_missing_datetime=$(calculate_percentage "$missing_datetime_count" "$total_releases_count")

# Output the summary with timestamps and time differences in seconds
echo "09Total releases: $(format_number "$total_releases") | 04Total nukes: $(format_number "$total_nukes") | 03Total unnukes: $(format_number "$total_unnukes") | 04% Nuked: $percentage_nuked | 10Total groups: $(format_number "$total_groups") | 10Total sections: $(format_number "$total_sections")"
echo "10Group with most releases: $most_releases_group :: 07Total releases: $(format_number "$total_releases_most")"
echo "12Newest group added (with only one release): $newest_group_name :: 10Added on: $newest_group_date $newest_group_time_since"
echo "12First release in DB: $first_release_name :: ($first_release_date) $first_release_time_since"
echo "14Latest release in DB: $latest_release_name :: ($latest_release_date)"
echo "14Invalid datetimes: $(format_number "$invalid_count") :: 04 Invalid datetimes in %: $percentage_invalid"
echo "06Missing size: $(format_number "$missing_size") :: 04 Missing size in %: $percentage_missing_size"
echo "06Missing files: $(format_number "$missing_files") :: 04 Missing files in %: $percentage_missing_files"
echo "06Missing genre: $(format_number "$missing_genre") :: 04 Missing genre in %: $percentage_missing_genre"
echo "06Missing datetime: $(format_number "$missing_datetime_count") :: 04 Missing datetime in %: $percentage_missing_datetime"
echo "12Database size: $database_size_gb GB"

