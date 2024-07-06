#!/bin/bash

# Database credentials
db_host="133.133.133.133"
db_user="someuser"
db_password="somepass"
db_name="YourDBname"
DB_TABLE_MAIN="MAIN"
DB_TABLE_NUKE="NUKE"
DB_TABLE_XTRA="XTRA"

# Function to execute MySQL queries
execute_query() {
  local query="$1"
  mysql -h "$db_host" -u "$db_user" -p"$db_pass" -D "$db_name" -s -N -e "$query" 2>/dev/null
}

# Function to fetch details (size, files, datetime, and any XTRA fields) for a release
fetch_release_details() {
  local rlsname="$1"
  local main_fields="m.files, m.size, m.datetime"
  local xtra_fields="x.sfv, x.nfo, x.screen, x.addurl, x.tvmaze, x.imdb, x.m3u"

  local details_query="SELECT $main_fields, $xtra_fields FROM $DB_TABLE_MAIN AS m LEFT JOIN $DB_TABLE_XTRA AS x ON m.rlsname = x.rlsname WHERE m.rlsname='$rlsname';"
  execute_query "$details_query"
}

# Function to check if a release is NUKE and get reason if NUKE'd
check_if_nuked() {
  local rlsname="$1"
  local nuke_query="SELECT raison FROM $DB_TABLE_NUKE WHERE rlsname='$rlsname';"
  local nuke_result=$(execute_query "$nuke_query")
  if [ -n "$nuke_result" ]; then
    echo " - 04[NUKED: Yes, Reason: $nuke_result]"
  else
    echo ""
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
search_query="SELECT m.rlsname FROM $DB_TABLE_MAIN AS m LEFT JOIN $DB_TABLE_XTRA AS x ON m.rlsname = x.rlsname WHERE "

# Split keywords into an array
IFS=' ' read -r -a keyword_array <<< "$keywords"

# Loop through each keyword and add it to the query
for keyword in "${keyword_array[@]}"; do
  search_query+="m.rlsname LIKE '%$keyword%' AND "
done

# Remove the last " AND " from the query string
search_query="${search_query% AND } ORDER BY m.datetime DESC LIMIT 10;"

# Execute the query and capture the results
query_results=$(execute_query "$search_query")

# Check if there are any results
if [ -z "$query_results" ]; then
  echo "No results found, try refining your search keywords."
else
  count=1
  while IFS= read -r rlsname; do
    # Fetch details (size, files, datetime, and any XTRA fields) for each release
    details=$(fetch_release_details "$rlsname")
    if [ -n "$details" ]; then
      # Read MAIN table fields
      read -r files size datetime sfv nfo screen addurl tvmaze imdb m3u <<< "$(echo "$details" | awk '{ print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10 }')"
      
      nuke_info=$(check_if_nuked "$rlsname")
      elapsed_time=$(calculate_time_elapsed "$datetime")
      
      # Format size to MB or GB
      size=$(echo "$size" | sed 's/\.0$//')
      if (( $(echo "$size < 1000" | bc -l) )); then
        formatted_size="${size} MB"
      else
        formatted_size="$(printf "%.1f" $(echo "scale=1; $size / 1000" | bc)) GB"
      fi
      
      # Format datetime
      formatted_date=$(date -d "$datetime" +"%d-%m-%Y")
      formatted_time=$(date -d "$datetime" +"%H:%M:%S")

      # Prepare output with mIRC color codes
      output="11#$count $rlsname :: 10PRED:07$elapsed_time 10ago :: 11Files: 07$files :: 11SIZE: 07$formatted_size :: 09DATE: 07$formatted_date::"

      # Append NFO if not null
      if [ "$nfo" != "NULL" ]; then
        output+="\n09SFV: $nfo ::"
      fi

      # Append SCREEN if not null
      if [ "$screen" != "NULL" ]; then
        output+="\n12NFO: $screen ::"
      fi

      # Append ADDURL if not null
      if [ "$addurl" != "NULL" ]; then
        output+="\n13SCREEN: $addurl ::\n"
      fi

      # Append TVMAZE if not null
      if [ "$tvmaze" != "NULL" ]; then
        output+="\n10URL: $tvmaze ::\n"
      fi

      # Append IMDB if not null
      if [ "$imdb" != "NULL" ]; then
        output+="\n09IMDB: $imdb ::\n"
      fi

      # Append M3U if not null
      if [ "$m3u" != "NULL" ]; then
        output+="\n09M3U: $m3u ::\n"
      fi

      # Append NUKE info
      output+=" $nuke_info"

      # Print the final formatted output
      echo -e "$output\n"

      count=$(( count + 1 ))
    else
      echo "Error fetching details for $rlsname"
    fi
  done <<< "$query_results"
fi

