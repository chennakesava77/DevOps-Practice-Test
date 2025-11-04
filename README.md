Backup-bash-task
Summery:
      the automated backup system is a bash script that automatically backup important files and directories in linux.

      it compresses the data, add time stamps, manages  logs and can run automatically using corn jobs.
                      ensuring that no data is lost.

 Main features:
 1.Automated Backups: creates .tar.gz compressed backup files automatically.
 2.time stamp archeived: each backup includes the current date and time for easy tracking.
 3.configurable settings: paths and options are stored in a separate backup.config file
 4.Detailed logs: evaery backup operation is recorded in the logs/folder.
 5.Auto scheduling: can be set to run daily,weekly etc. using "corn job"
 6.Error handling: checks permissions,disk space,and directories before running.

 How to its works:
 ---the script reads paths and setting from backup.config
 ---it checks all directories exist
 ---it creates a backup file name using the data and time.
 --it compresses the source directory into .tar.gz
 -the backup file is stored in the destination folder.
 -A long file records the details(success or failure).

 --- project structure--
 backup-system/
├── backup.sh          → Main backup script
├── backup.config      → Configuration file
├── logs/              → Stores log files
└── README.md          → Documentation

      ----In my role in this task----
--Writing and testing the Bash backup script.
--Designing configuration and logging logic.
--Setting up cron automation.
--Documenting the system for GitHub.
