#!/bin/bash

# Database credentials
DB_HOST=""
DB_USER=""
DB_PASS=""
DB_NAME=""
DB_TABLE_MAIN="MAIN"
DB_TABLE_NUKE="NUKE"
DB_TABLE_XTRA="XTRA"

# Function to execute MySQL queries
execute_query() {
  local query="$1"
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -s -N -e "$query" 2>/dev/null
}

# Function to fetch release details including additional XTRA fields
fetch_release_details() {
  local rlsname="$1"
  local query="SELECT m.files, m.size, m.datetime, m.section, m.genre, x.sfv, x.nfo, x.screen, x.addurl
               FROM $DB_TABLE_MAIN AS m
               LEFT JOIN $DB_TABLE_XTRA AS x ON m.rlsname = x.rlsname
               WHERE m.rlsname='$rlsname';"
  execute_query "$query"
}

# Function to insert release details into database
insert_release_details() {
  local rlsname="$1"
  local files="$2"
  local size="$3"
  local datetime="$4"
  local section="$5"
  local genre="$6"
  local sfv="$7"
  local nfo="$8"
  local screen="$9"
  local addurl="${10}"
  local m3u="${11}"

  local query="INSERT INTO $DB_TABLE_MAIN (rlsname, files, size, datetime, section, genre)
               VALUES ('$rlsname', $files, $size, '$datetime', '$section', '$genre');"
  execute_query "$query"

  query="INSERT INTO $DB_TABLE_XTRA (rlsname, sfv, nfo, screen, addurl, m3u)
         VALUES ('$rlsname', '$sfv', '$nfo', '$screen', '$addurl', '$m3u');"
  execute_query "$query"

  echo "Database updated with release: $rlsname"
}

# Function to fetch release details from API
fetch_release_details_from_api() {
  local rlsname="$1"
  local api_url="https://api.predb.net/?type=pre&release=$rlsname"
  local response=$(curl -s "$api_url")

  if [[ "$response" =~ '"status": "success"' ]]; then
    local files=$(echo "$response" | jq -r '.data[0].files')
    local size=$(echo "$response" | jq -r '.data[0].size')
    local datetime=$(echo "$response" | jq -r '.data[0].pretime')
    local section=$(echo "$response" | jq -r '.data[0].section')
    local genre=$(echo "$response" | jq -r '.data[0].genre')
    local sfv=$(echo "$response" | jq -r '.data[0].url')  # Change as per actual API response
    local nfo=$(echo "$response" | jq -r '.data[0].nfo')
    local screen=$(echo "$response" | jq -r '.data[0].nfo_image')
    local addurl=$(echo "$response" | jq -r '.data[0].url')
    local m3u=""

    insert_release_details "$rlsname" "$files" "$size" "$datetime" "$section" "$genre" \
                            "$sfv" "$nfo" "$screen" "$addurl" "$m3u"
  else
    echo "No information found for release: $rlsname"
  fi
}

# Function to calculate time elapsed since a given datetime
calculate_time_elapsed() {
  local rlsname="$1"
  local datetime=$(execute_query "SELECT datetime FROM $DB_TABLE_MAIN WHERE rlsname='$rlsname';")

  if [ -z "$datetime" ]; then
    echo "Error: Datetime not found for release: $rlsname"
    exit 1
  fi

  if [ "$datetime" = "0000-00-00 00:00:00" ]; then
    echo "Datetime is 0000-00-00 00:00:00"
    return  # Exit function without error
  fi

  # Adjust datetime by adding 3 hours (as per your previous requirement)
  local adjusted_datetime=$(date -d "$datetime + 3 hours" "+%Y-%m-%d %H:%M:%S")

  if [ $? -ne 0 ]; then
    echo "Error: Failed to parse datetime: $datetime"
    exit 1
  fi

  # Calculate elapsed time in seconds
  local current_time=$(date +%s)
  local datetime_seconds=$(date -d "$adjusted_datetime" +%s)
  local elapsed_seconds=$(( current_time - datetime_seconds ))

  # Calculate elapsed years, months, days, hours, minutes, seconds
  local years=$(( elapsed_seconds / 31536000 ))
  local months=$(( (elapsed_seconds % 31536000) / 2592000 ))
  local days=$(( (elapsed_seconds % 2592000) / 86400 ))
  local hours=$(( (elapsed_seconds % 86400) / 3600 ))
  local minutes=$(( (elapsed_seconds % 3600) / 60 ))
  local seconds=$(( elapsed_seconds % 60 ))

  # Prepare elapsed time string
  local elapsed_time=""

  if [ $years -gt 0 ]; then
    elapsed_time+=" $years years"
  fi
  if [ $months -gt 0 ]; then
    elapsed_time+=" $months months"
  fi
  if [ $days -gt 0 ]; then
    elapsed_time+=" $days days"
  fi
  if [ $hours -gt 0 ]; then
    elapsed_time+=" $hours hours"
  fi
  if [ $minutes -gt 0 ]; then
    elapsed_time+=" $minutes min"
  fi
  if [ $seconds -gt 0 ]; then
    elapsed_time+=" $seconds sec"
  fi

  echo "$elapsed_time ago"
}

# Function to convert MB size to human-readable format (MB or GB)
convert_mb_to_human_readable() {
  local mb=$1

  if (( $(echo "$mb < 1000" | bc -l) )); then
    echo "${mb} MB"
  else
    echo "$(printf "%.1f" $(echo "scale=1; $mb / 1000" | bc)) GB"
  fi
}

# Function to check if a release is NUKE and get reason if NUKE'd
check_if_nuked() {
  local rlsname="$1"
  local query="SELECT raison FROM $DB_TABLE_NUKE WHERE rlsname='$rlsname';"
  local result=$(execute_query "$query")
  if [ -n "$result" ]; then
    echo "$result"
  else
    echo ""
  fi
}

# Main script starts here

# Check if release name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <releasename>"
  exit 1
fi

# Assign the first argument to rlsname
rlsname="$1"

# Fetch release details including additional XTRA fields
details=$(fetch_release_details "$rlsname")
if [ -n "$details" ]; then
  read -r files size datetime section genre sfv nfo screen addurl <<< "$details"
  
  # Remove any trailing .0 from size
  size=$(echo "$size" | sed 's/\.0$//')
  
  elapsed_time=$(calculate_time_elapsed "$rlsname")
  nuke_info=$(check_if_nuked "$rlsname")

  # Remove any timestamp from section if present
  section=$(echo "$section" | awk '{print $NF}')

  # Format datetime into DD-MM-YYYY and HH:MM:SS formats
  formatted_date=$(date -d "$datetime" +"%d-%m-%Y")
  formatted_time=$(date -d "$datetime" +"%H:%M:%S")

  # Convert size to human-readable format (MB or GB)
  formatted_size=$(convert_mb_to_human_readable "$size")

  # Prepare output with mIRC color codes
  if [ -n "$nuke_info" ]; then
    echo "07$rlsname -> 12SECTION: $genre :: 12Files: $files :: 12SIZE: $formatted_size :: 12PRED: $elapsed_time :: 12RELEASED: $formatted_date "
    if [ -n "$genre" ] && [ "$genre" != "NULL" ]; then
      echo "12SECTION: $genre"
    fi
    if [ -n "$nfo" ] && [ "$nfo" != "NULL" ]; then
      echo "07SFV: $nfo"
    fi
    if [ -n "$screen" ] && [ "$screen" != "NULL" ]; then
      echo "12NFO: $screen"
    fi
    if [ -n "$addurl" ] && [ "$addurl" != "NULL" ]; then
      echo "13SCREEN: $addurl"
    fi
    echo "04[NUKED] - Reason:04 $nuke_info"
  else
    echo "07$rlsname -> 12SIZE: $formatted_size 12Files: $files :: 12PRED: $elapsed_time :: 12RELEASED: $formatted_date "
    if [ -n "$genre" ] && [ "$genre" != "NULL" ]; then
      echo "12SECTION: $genre"
    fi
    if [ -n "$sfv" ] && [ "$sfv" != "NULL" ]; then
      echo "09SFV: $sfv"
    fi
    if [ -n "$nfo" ] && [ "$nfo" != "NULL" ]; then
      echo "12NFO: $nfo"
    fi
    if [ -n "$screen" ] && [ "$screen" != "NULL" ]; then
      echo "13SCREEN: $screen"
    fi
    if [ -n "$addurl" ] && [ "$addurl" != "NULL" ]; then
      echo "10URL: $addurl"
    fi
  fi
else
  echo "No details found for release name: $rlsname"

  # If release details not found locally, fetch from API and add to database
  fetch_release_details_from_api "$rlsname"
fi
