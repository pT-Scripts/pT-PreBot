# Command handler for !nuke
bind pub - !nuke nukeStats

proc nukeStats {nick host handle channel text} {
    global eggdrop

    # Execute the shell script with the text after !addpre as arguments
    set script_path "/glftpd/sitebot/scripts/sh/pT-addnuke.sh"
    set result [exec $script_path {*}[split $text]]

    # Split the result into lines
    set lines [split $result \n]

    # Announce each line to the specified channel
    foreach line $lines {
        # Sending the line to the #destiny.site channel
        putserv "PRIVMSG #somechan :$line"
    }
}
