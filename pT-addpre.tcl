# pT-addpre.tcl

# Command handler for !addpre
bind pub - !addpre addStats

proc addStats {nick host handle channel text} {
    global eggdrop

    # Execute the shell script with the text after !addpre as arguments
    set script_path "/eggdrop/scripts/sh/pT-addpre.sh"
    set result [exec $script_path {*}[split $text]]

    # Split the result into lines
    set lines [split $result \n]

    # Send each line as a private message to the user
    foreach line $lines {
        # Applying IRC colors for enhanced readability (modify as needed)
        set colored_line "$line"
    }
}

