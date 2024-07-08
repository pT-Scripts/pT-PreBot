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

# Function to fetch details (size, files, datetime, and any XTRA fields) for a release
fetch_release_details() {
  local rlsname="$1"
  local main_fields="m.files, m.size, m.datetime"
  local xtra_fields="x.sfv, x.nfo, x.jpg, x.addurl, x.m3u"

  local details_query="SELECT $main_fields, $xtra_fields FROM $DB_TABLE_MAIN AS m LEFT JOIN $DB_TABLE_XTRA AS x ON m.rlsname = x.rlsname WHERE m.rlsname='$rlsname';"
  execute_query "$details_query"
}

# Function to check if a release is NUKE and get reason if NUKE'd
check_if_nuked() {
  local rlsname="$1"
  local nuke_query="SELECT reason FROM $DB_TABLE_NUKE WHERE rlsname='$rlsname';"
  local nuke_result=$(execute_query "$nuke_query")
  if [ -n "$nuke_result" ]; then
    echo "04[NUKED] $nuke_result"
  fi
}

# Function to calculate time elapsed since a given datetime
calculate_time_elapsed() {
  local datetime="$1"

  # Check if datetime is valid
  if [[ "$datetime" == "0000-00-00 00:00:00" || -z "$datetime" ]]; then
    echo "Invalid date"
    return
  fi

  local current_time=$(date +%s)
  local datetime_seconds=$(date -d "$datetime" +%s)
  local elapsed_seconds=$(( current_time - datetime_seconds ))

  local years=$(( elapsed_seconds / 31536000 ))
  local months=$(( (elapsed_seconds % 31536000) / 2592000 ))
  local days=$(( (elapsed_seconds % 2592000) / 86400 ))
  local hours=$(( (elapsed_seconds % 86400) / 3600 ))
  local minutes=$(( (elapsed_seconds % 3600) / 60 ))
  local seconds=$(( elapsed_seconds % 60 ))

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

  echo "$elapsed_time"
}

# Main script starts here

# Parse command-line arguments into a single string
keywords="$*"

# Check if keywords are provided
if [ -z "$keywords" ]; then
  echo "Usage: $0 <keywords>"
  exit 1
fi

# Construct the search query to find records with all keywords in rlsname, ordered by datetime descending
search_query="SELECT m.rlsname, m.files, m.size, m.datetime, x.sfv, x.nfo, x.jpg, x.addurl, x.m3u FROM $DB_TABLE_MAIN AS m LEFT JOIN $DB_TABLE_XTRA AS x ON m.rlsname = x.rlsname WHERE "

# Split keywords into an array
IFS=' ' read -r -a keyword_array <<< "$keywords"

# Loop through each keyword and add it to the query
for keyword in "${keyword_array[@]}"; do
  search_query+="m.rlsname LIKE '%$keyword%' AND "
done

# Remove the last " AND " from the query string
search_query="${search_query% AND } ORDER BY m.datetime DESC LIMIT 35;"

# Execute the query and capture the results
query_results=$(execute_query "$search_query")

# Check if there are any results
if [ -z "$query_results" ]; then
  echo "No results found, try refining your search keywords."
else
  count=1
  while IFS=$'\t' read -r rlsname files size datetime sfv nfo jpg addurl m3u; do
    # Replace NULL values with empty strings
    files=${files:-""}
    size=${size:-""}
    datetime=${datetime:-""}
    sfv=${sfv:-""}
    nfo=${nfo:-""}
    jpg=${jpg:-""}
    addurl=${addurl:-""}
    m3u=${m3u:-""}

    nuke_info=$(check_if_nuked "$rlsname")
    elapsed_time=$(calculate_time_elapsed "$datetime")

    # Prepare output with mIRC color codes
    output="\n 11#$count ::07 $rlsname :: 10PRED:07$elapsed_time 10ago"

    # Format output based on available data
    if [ -n "$files" ]; then
      output+=" :: 11Files: 07$files"
    fi
    if [ -n "$size" ]; then
      size=$(echo "$size" | sed 's/\.0$//')
      if (( $(echo "$size < 1000" | bc -l) )); then
        output+=" :: 11SIZE: 07${size} MB"
      else
        formatted_size="$(printf "%.1f" $(echo "scale=1; $size / 1000" | bc)) GB"
        output+=" :: 11SIZE: 07$formatted_size"
      fi
    fi
    if [ -n "$datetime" ]; then
      formatted_date=$(date -d "$datetime" +"%d-%m-%Y")
      output+=" :: 09DATE: 07$formatted_date"
    fi

    # Print NUKED info on a new line if it exists
    if [ -n "$nuke_info" ]; then
      output+=" :: $nuke_info"
    fi

    # Add additional fields if they are available
    if [ -n "$sfv" ] && [ "$sfv" != "NULL" ]; then
      output+="\n09SFV: $sfv"
    fi
    if [ -n "$nfo" ] && [ "$nfo" != "NULL" ]; then
      output+="\n12NFO: $nfo"
    fi
    if [ -n "$jpg" ] && [ "$jpg" != "NULL" ]; then
      output+="\n13JPG: $jpg"
    fi
    if [ -n "$addurl" ] && [ "$addurl" != "NULL" ]; then
      output+="\n10URL: $addurl"
    fi
    if [ -n "$m3u" ] && [ "$m3u" != "NULL" ]; then
      output+="\n09M3U: $m3u"
    fi

    # Print the final formatted output
    echo -e "$output\n"

    count=$(( count + 1 ))
  done <<< "$query_results"
fi
