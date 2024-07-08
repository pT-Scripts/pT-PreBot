# pT-predupe.tcl

# Command handler for !dupe
bind pub - !dupe dupeStats

proc dupeStats {nick host handle channel text} {
    global eggdrop

    # Send a notice to the user indicating that the search is in progress
    putquick "PRIVMSG $channel :Searching duplicates for $text - this may take a moment. Showing max of 25 results in private message."

    # Execute the shell script with the text after !dupe as argument
    set script_path "/eggdrop/scripts/sh/pT-predupe.sh"
    set result [exec $script_path $text]

    # Split the result into lines
    set lines [split $result \n]

    # Send the initial search message
    putquick "PRIVMSG $nick :DUPE SEARCH - Showing max 35 results. Improve your search keywords for better filtering."

    # Send each line as a private message to the user
    foreach line $lines {
        # Applying IRC colors for enhanced readability
        # You can modify the color codes based on your IRC client's capabilities

        # Example: Yellow color for highlighting important information
        set colored_line "$line"
        
        # Send the colored line as a private message to the user
        putquick "PRIVMSG $nick :$colored_line"
    }
}
