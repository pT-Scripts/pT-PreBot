# Command handler for !info
bind pub - !info infoStats

proc addStats {nick host handle channel text} {
    global eggdrop

    # Execute the shell script with the text after !addpre as arguments
    set script_path "/eggdrop/scripts/sh/pT-addinfo.sh"
    set result [exec $script_path {*}[split $text]]

    # Split the result into lines
    set lines [split $result \n]

    # Announce each line to the specified channel
    foreach line $lines {
        # Sending the line to the #destiny.site channel
        putserv "PRIVMSG #somechan :$line"
    }
}
