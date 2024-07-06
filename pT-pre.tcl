# pT-pre.tcl

# Command handler for !pre
bind pub - !pre preStats

proc preStats {nick host handle channel text} {
    global eggdrop

    # Execute both shell scripts with the text after !pre as argument
    set script_path1 "/eggdrop/scripts/sh/pT-pre.sh"
    set script_path2 "/eggdrop/scripts/sh/pT-preapi.sh"

    # Execute first script
    set result1 [exec $script_path1 $text]

    # Split the result into lines
    set lines1 [split $result1 \n]

    # Send each line as a message to the channel
    foreach line1 $lines1 {
        # Send the line as a message to the channel
        putquick "PRIVMSG $channel :$line1"
    }

    # Execute second script
    set result2 [exec $script_path2 $text]

    # Split the result into lines
    set lines2 [split $result2 \n]

    # Send each line as a message to the channel
    foreach line2 $lines2 {
        # Send the line as a message to the channel
        putquick "PRIVMSG $channel :$line2"
    }
}

