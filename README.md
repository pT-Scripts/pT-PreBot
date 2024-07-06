[![ptprebotlogo.png](https://i.postimg.cc/VkX7xBFr/ptprebotlogo.png)](https://postimg.cc/jDdQNfmt)

# pT-PreBot v1.2 by Petabyte

**Description:**  
pT-PreBot is an IRC bot designed for managing pre-release data and integrating with MySQL databases, specifically tailored for eggdrop bots.

- Bug Fixes: Various bug fixes and optimizations for better performance and reliability.

## Features:
- **Fast Addpre System for Insert to database, that Supports:** !addpre !info !genre !addurl !nuke !unnuke
- **Extended Search System that Supports:** !pre !dupe !group !db
- **Full Database stats using !db showing:**
  Total releases
  Total nukes
  Total unnukes
  % Nuked
  Total groups
  Total sections
  Group with most releases
  Newest group added (with only one release)
  First release in DB
  Latest release in DB
  How many releases missing size (Count/%)
  How many releases missing files (Count/%)
  How many releases missing genre (Count/%)
  How many releases missing datetime (Count/%)
  Database size in GB
  
- **Module: PreDB.net API support** - Advanced search capabilities using PreDB.net API for precise release queries.
- **Real-time interaction and command execution via IRC channels.**
- **User friendly color outputs for announces in IRC**
- **Included .sql scheme for easy Database structure setup.**

## Installation Guide

### Prerequisites

Ensure you have the following set up before installing pT-PreBot:

- A running MySQL or MariaDB server with a user having necessary privileges. # Prefered MariaDB Newest version wtih Tweaked inno my.cnf
- Eggdrop installed and configured / Running. # Check https://www.eggheads.org/download/ for more info how to install eggdrop
- Basic understanding of managing files and configurations on your system.

### Step-by-Step Installation:

1. **Install Required Packages:**
   ```bash
   sudo apt-get install jq bc
  
2. Download the pT-PreBot files from the repository.

3. Import the dbschema.sql into your new DB

4. Place all .sh scripts and associated files into your eggdrop bot's scripts directory.
   
5. Change all Mysql info in .sh files located in sh folder to your own db info

6. Put .tcl in eggdrop.conf and Rehash your eggdrop bot.

NOTE: If you are using dbschema.sql then dont edit tables, if you running own database make sure to change info and coloumns in .sh files

## **ADDPRE CHANNEL**

Ensure your eggdrop bot is in a addpre channel that outputs following formats:
```bash
!addpre <release> <section>
!info <release> <files> <size>
!addurl <release> <url>
!gn <release> <genre>
!nuke <release> <reason> <nukenet>
!unnuke <release> <reason> <nukenet>

**Testing pT-PreBot:*
Verify that pT-PreBot .sh script is functioning correctly by testing each command in terminal executing shell script:

Simulate the !pre command:
./pT-pre.sh Twister.1996.2160p.UHD.BluRay.x265-SURCODE

Simulate the !dupe command:
./pT-dupe.sh Twister 1996 2160p

Simulate the !db command:
./pT-db.sh

Simulate the !group command:
./pT-group.sh SURCODE
