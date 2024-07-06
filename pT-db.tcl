# db.tcl

# Command handler for !db
bind pub - !db dbStats

proc dbStats {nick host handle channel text} {
    global eggdrop

    # Announce that the DB info is being fetched
    putquick "PRIVMSG $channel :Fetching DB info, Takes a while please wait."

    # Path to the shell script
    set script_path "/eggdrop/scripts/sh/pT-predb.sh"

    # Execute the shell script and capture the output
    set result [catch {exec $script_path} output]

    if {$result == 0} {
        # If the script executed successfully, split the output into lines
        set lines [split $output "\n"]

        # Send each line as a message to the channel
        foreach line $lines {
            if {$line ne ""} {
                putquick "PRIVMSG $channel :$line"
            }
        }
    } else {
        # If there was an error executing the script, announce the error
        putquick "PRIVMSG $channel :Error executing script: $output"
    }
}

