# pT-addinfo.tcl

# Command handler for !info
bind pub - !info infoStats

proc infoStats {nick host handle channel text} {
    global eggdrop

    # Execute the shell script with the text after !info as arguments
    set script_path "/eggdrop/scripts/sh/pT-addinfo.sh"
    set result [exec $script_path {*}[split $text]]

    # Split the result into lines
    set lines [split $result \n]

    # Send each line as a private message to the user
    foreach line $lines {
        # Applying IRC colors for enhanced readability (modify as needed)
        set colored_line "$line"

    }
}

