# --- Email Notification Section ---
EMAIL="chennakesavareddy.boreddy@gmail.com"
LOGFILE="backup.log"  # Or your existing log file path

if [ $? -eq 0 ]; then
    echo " Backup completed successfully on $(date)" | mail -s "Backup Success " "$EMAIL"
    echo "[INFO] Email notification sent for successful backup." | tee -a "$LOGFILE"
else
    echo " Backup failed on $(date)" | mail -s "Backup Failed " "$EMAIL"
    echo "[ERROR] Email notification sent for failed backup." | tee -a "$LOGFILE"
fi
