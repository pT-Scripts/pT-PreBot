#!/bin/bash

# Database credentials
db_host=""
db_user=""
db_pass=""
db_name=""
main_table="MAIN"
xtra_table="XTRA"
nuke_table="NUKE"

# Function to execute MySQL queries
execute_query() {
  local query="$1"
  mysql -h "$db_host" -u "$db_user" -p"$db_pass" -D "$db_name" -s -N -e "$query" 2>/dev/null
}

# Function to fetch release details including SFV, NFO, JPG, URL from MAIN and XTRA tables
fetch_release_details() {
  local rlsname="$1"
  local query="SELECT m.rlsname, 
                      COALESCE(m.size, 'NULL'), 
                      COALESCE(m.files, 'NULL'), 
                      UNIX_TIMESTAMP(m.datetime),
                      COALESCE(x.sfv, 'NULL'), 
                      COALESCE(x.nfo, 'NULL'), 
                      COALESCE(x.jpg, 'NULL'), 
                      COALESCE(x.addurl, 'NULL')
               FROM $main_table AS m
               LEFT JOIN $xtra_table AS x ON m.rlsname = x.rlsname
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
  read -r rlsname size files datetime sfv nfo jpg addurl <<< "$details"
  
  # Prepare output with mIRC color codes
  output="07[RELEASE] $rlsname"
  
  # Format size to remove decimals and unnecessary zeros
  if [ "$size" != "NULL" ]; then
    size_human_readable=$(printf "%.0f" "$size")
    output+=" :: 12SIZE: ${size_human_readable} MB"
  fi
  
  # Format files count to handle NULL
  if [ "$files" != "NULL" ]; then
    output+=" :: 12FILES: $files"
  fi

  # Calculate time since and format the output
  time_since=$(calculate_time_since "$datetime")
  if [ -n "$time_since" ]; then
    output+="\n09PRED: $time_since ago"
  fi
  
  # Display SFV, NFO, JPG, URL if they are not NULL
  if [ "$sfv" != "NULL" ]; then
    output+="\n09SFV: $sfv"
  fi
  
  if [ "$nfo" != "NULL" ]; then
    output+="\n12NFO: $nfo"
  fi
  
  if [ "$jpg" != "NULL" ]; then
    output+="\n13JPG: $jpg"
  fi
  
  if [ "$addurl" != "NULL" ]; then
    output+="\n10URL: $addurl"
  fi

  echo -e "$output"
else
  echo "No details found for release name: $rlsname"
fi
