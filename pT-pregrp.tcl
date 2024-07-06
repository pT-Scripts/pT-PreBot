# pT-pregrp.tcl

# Command handler for !group
bind pub - !group groupSearch
bind pub - !grp groupSearch

proc groupSearch {nick host handle channel text} {
    global eggdrop

    # Announce that search is in progress
    putquick "PRIVMSG $channel :Searching stats for $text - may take a moment"

    # Execute the shell script with the text after !group as argument
    set script_path "/eggdrop/scripts/sh/pT-pregrp.sh"
    set result [exec $script_path $text]

    # Split the result into lines and send each line to the channel
    foreach line [split $result \n] {
        # Applying IRC colors for enhanced readability
        set line [string map {
            "Group has a total of" "Group has a total of"
            "Last release:" "\00307Latest Release:\003"
            "First release:" "\00307First Release:\003"
            "Total size of releases:" "\00307Total size PRED:\003"
            "Percentage of nuked releases:" "\00307Percentage of NUKED Releases:\003"
            "NUKES:" "\00304NUKES:\003"
            "Last NUKED release:" "\00304Latest NUKED Release:\003"
            "UNNUKES:" "\00303UNNUKES:\003"
            "Last UNNUKED release:" "\00303Latest UNNUKED Release:\003"
        } $line]

        # Send each formatted line to the channel
        putquick "PRIVMSG $channel :$line"
    }
}

