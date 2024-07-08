# pT-pregrp.tcl

# Command handler for !pre
bind pub - !group grpStats
bind pub - !grp grpStats

proc grpStats {nick host handle channel text} {
    global eggdrop

    # Execute both shell scripts with the text after !pre as argument
    set script_path1 "/eggdrop/scripts/sh/pT-pregrp.sh"

    # Execute first script
    set result1 [exec $script_path1 $text]

    # Split the result into lines
    set lines1 [split $result1 \n]

    # Send each line as a message to the channel
    foreach line1 $lines1 {
        # Send the line as a message to the channel
        putquick "PRIVMSG $channel :$line1"
    }

}
