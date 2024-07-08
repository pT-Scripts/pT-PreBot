#!/bin/bash

# Database credentials
DB_HOST=""
DB_USER=""
DB_PASS=""
DB_NAME=""
DB_TABLE_MAIN="MAIN"
DB_TABLE_XTRA="XTRA"
DB_TABLE_NUKE="NUKE"

# Function to execute MySQL queries
execute_query() {
  local query="$1"
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -s -N -e "$query" 2>/dev/null
}

# Function to fetch release details including SFV, NFO, JPG, URL from MAIN and XTRA tables
fetch_release_details() {
  local rlsname="$1"
  local query="SELECT m.rlsname, m.size, m.files, m.genre, m.section, UNIX_TIMESTAMP(m.datetime),
                      x.sfv, x.nfo, x.jpg, x.addurl
               FROM $DB_TABLE_MAIN AS m
               LEFT JOIN $DB_TABLE_XTRA AS x ON m.rlsname = x.rlsname
               WHERE m.rlsname='$rlsname';"
  execute_query "$query"
}

# Function to calculate time difference
calculate_time_since() {
  local datetime="$1"
  local current_time=$(date +%s)
  
  # Calculate the difference in seconds
  local diff_seconds=$((current_time - datetime))
  
  # Calculate years, months, days, hours, minutes, and seconds
  local years=$(( diff_seconds / 31536000 ))
  local diff_seconds=$(( diff_seconds % 31536000 ))
  local months=$(( diff_seconds / 2628000 ))
  local diff_seconds=$(( diff_seconds % 2628000 ))
  local days=$(( diff_seconds / 86400 ))
  local diff_seconds=$(( diff_seconds % 86400 ))
  local hours=$(( diff_seconds / 3600 ))
  local diff_seconds=$(( diff_seconds % 3600 ))
  local minutes=$(( diff_seconds / 60 ))
  local seconds=$(( diff_seconds % 60 ))
  
  # Prepare formatted time string
  local formatted_time=""
  
  if [ "$years" -gt 0 ]; then
    formatted_time+=" ${years}y"
  fi
  if [ "$months" -gt 0 ]; then
    formatted_time+=" ${months}m"
  fi
  if [ "$days" -gt 0 ]; then
    formatted_time+=" ${days}d"
  fi
  if [ "$hours" -gt 0 ]; then
    formatted_time+=" ${hours}h"
  fi
  if [ "$minutes" -gt 0 ]; then
    formatted_time+=" ${minutes}min"
  fi
  if [ "$seconds" -gt 0 ] || [ -z "$formatted_time" ]; then
    formatted_time+=" ${seconds}sec"
  fi
  
  echo "$formatted_time"
}

# Main script starts here

# Check if release name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <releasename>"
  exit 1
fi

# Assign the first argument to rlsname
rlsname="$1"

# Fetch release details including SFV, NFO, JPG, URL from MAIN and XTRA tables
details=$(fetch_release_details "$rlsname")
if [ -n "$details" ]; then
  read -r rlsname size files genre section datetime sfv nfo jpg addurl <<< "$details"
  
  # Format size to remove decimals and unnecessary zeros
  if [ "$size" != "NULL" ]; then
    size_human_readable=$(printf "%.0f" "$size")
  else
    size_human_readable="Unknown"
  fi
  
  # Format files count to handle NULL
  if [ "$files" != "NULL" ]; then
    files_count="$files"
  else
    files_count="Unknown"
  fi

  # Format genre to handle NULL
  if [ "$genre" != "NULL" ]; then
    formatted_genre="11GENRE: $genre"
  else
    formatted_genre=""
  fi

  # Calculate time since and format the output
  time_since=$(calculate_time_since "$datetime")
  
  # Prepare output with mIRC color codes
  output="07[RELEASE] $rlsname -> 12SIZE: ${size_human_readable} MB :: 12FILES: $files_count"
  output+="\n09PRED: $time_since ago"
  
  if [ -n "$formatted_genre" ]; then
    output+="\n$formatted_genre"
  fi
  
  # Check if rlsname is marked as NUKED or UNNUKED and get reason
  nuke_status=$(execute_query "SELECT status, reason FROM $DB_TABLE_NUKE WHERE rlsname='$rlsname';")
  if [ -n "$nuke_status" ]; then
    read -r status reason <<< "$nuke_status"
    if [ "$status" == "NUKE" ]; then
      output+="\n04NUKED: $reason"
    elif [ "$status" == "UNNUKE" ]; then
      output+="\n09UNNUKED: $reason"
    fi
  fi
  
  if [ "$section" != "NULL" ]; then
    output+="\n15SECTION: $section"
  fi
   
  if [ "$addurl" != "NULL" ]; then
    output+="\n10URL: $addurl"
  fi
  
  output+="\n "
  output+="\n07[www.PreDB.ws]"
  
  if [ "$sfv" != "NULL" ]; then
    output+="\n09SFV: $sfv"
  fi
  
  if [ "$nfo" != "NULL" ]; then
    output+="\n12NFO: $nfo"
  fi
  
  if [ "$jpg" != "NULL" ]; then
    output+="\n13JPG: $jpg"
  fi

  echo -e "$output"
else
  echo "No details found for release name: $rlsname"
fi
