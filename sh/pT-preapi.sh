#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [exact release name]"
    exit 1
}

# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
    usage
fi

# Construct the release name from the provided arguments
release_name=$(echo "$*" | sed 's/ /%20/g')

# API URL
api_url="https://api.predb.net/?type=pre&release=${release_name}"

# Make the API request and store the response
response=$(curl -s "$api_url")

# Check if the response contains any results
results=$(echo "$response" | jq '.results')

if [ "$results" -eq 0 ]; then
    echo "No results found for release: $*"
    exit 0
fi

# Print the results in the desired format
echo "11[BACKUP] - Searching 07PreDB.Net10 API"

# Loop through each result and format output
echo "$response" | jq -r '.data[] | select(.nfo != null) | "\(.release) :: \(if .pretime then (.pretime | tonumber | strftime("%Y-%m-%d %H:%M:%S")) else empty end) :: 12SECTION: \(.section) :: 12URL: https://predb.net\(.url) ::"' | while IFS='' read -r line; do
    release_date=$(echo "$line" | awk -F ' :: ' '{print $2}')
    if [ -n "$release_date" ]; then
        release_epoch=$(date -d "$release_date" +%s)
        
        # Adjust for timezone (adding 2 hours)
        release_epoch=$((release_epoch + 7200))  # 7200 seconds = 2 hours

        current_epoch=$(date +%s)
        seconds_since_release=$((current_epoch - release_epoch))

        # Calculate years, months, days, hours, minutes, seconds
        years=$((seconds_since_release / 31536000))
        seconds_since_release=$((seconds_since_release % 31536000))
        months=$((seconds_since_release / 2592000))
        seconds_since_release=$((seconds_since_release % 2592000))
        days=$((seconds_since_release / 86400))
        seconds_since_release=$((seconds_since_release % 86400))
        hours=$((seconds_since_release / 3600))
        seconds_since_release=$((seconds_since_release % 3600))
        minutes=$((seconds_since_release / 60))
        seconds=$((seconds_since_release % 60))

        # Format the time difference
        time_diff=""
        if [ "$years" -gt 0 ]; then
            time_diff="${years}y ${months}m ${days}d ${hours}h ${minutes}min ${seconds}sec ago"
        elif [ "$months" -gt 0 ]; then
            time_diff="${months}m ${days}d ${hours}h ${minutes}min ${seconds}sec ago"
        elif [ "$days" -gt 0 ]; then
            time_diff="${days}d ${hours}h ${minutes}min ${seconds}sec ago"
        elif [ "$hours" -gt 0 ]; then
            time_diff="${hours}h ${minutes}min ${seconds}sec ago"
        elif [ "$minutes" -gt 0 ]; then
            time_diff="${minutes}min ${seconds}sec ago"
        else
            time_diff="${seconds}sec ago"
        fi

        # Replace the placeholder with formatted time difference
        echo "$line" | sed "s/ :: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}/ :: $time_diff/"
    else
        echo "$line"
    fi
done

exit 0

