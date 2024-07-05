# pT-PreBot v1.0 by Petabyte

**Description:**  
pT-PreBot is a tool designed for searching pre releases fetched from your MySQL database. 
It includes MySQL database connectivity and IRC/TCL integration for real-time interaction for your eggdrop.
+ PreDB.net API Search

**Commands:**  
- `!pre` - Search full release name.  
- `!db` - Database Stats.  
- `!dupe` - Find duplicate entries based on specified criteria.  
- `!group` - Shows group Stats.

**Configuration:**  
- **MySQL Connection:**  
  Modify MySQL connection details, columns, and structure in each .sh script file within the script's directory.

- **IRC Integration:**  
  Edit Tcl scripts for additional triggers or set `o` for ops only mode. It operates on all channels by default unless specified otherwise.

- **API PreDB.Net Setting:**  
  API PreDB.Net is enabled by default. To disable API announcements, comment out the line in `pT-pre.tcl`:  
#set script_path2 "/glftpd/bin/pT-preapi.sh"

Remember to rehash the bot after making changes.

**Install:**  
Install packages

sudo apt-get install jq

sudo apt-get install bc

1. Place all files into your eggdrop scripts folder.  
2. Load .tcl scripts in your eggdrop configuration.

   For Test in terminal
4. Use the commands to manage your database:  
 - For `!pre` command: `./pT-pre.sh Twister.1996.2160p.UHD.BluRay.x265-SURCODE`  
 - For `!dupe` command: `./pT-dupe.sh Twister 1996 2160p`  
 - For `!db` command: `./pT-db.sh`  
 - For `!group` command: `./pT-group.sh SURCODE`
