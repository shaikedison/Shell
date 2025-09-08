#!/bin/bash

# A script to backup and then delete old log files.

# Define the log directory. Change this to the actual path of your log files.
LOG_DIR="/c/temp/logs"

# Define the backup directory. Create this directory if it doesn't exist.
BACKUP_DIR="/c/temp/backups"

# Define the number of days after which log files should be backed up and deleted.
DAYS_TO_KEEP=7

# Check if the log directory exists.
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Log directory $LOG_DIR not found."
    exit 1
fi

# Check if the backup directory exists. If not, create it.
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory $BACKUP_DIR not found. Creating it..."
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create backup directory."
        exit 1
    fi
fi

# Create a timestamp for the backup filename.
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_FILE="logs_backup_$TIMESTAMP.tar.gz"

echo "Creating backup of log files older than $DAYS_TO_KEEP days..."

# Use find to locate old files and tar to compress them into a single backup file.
# The `find ... -print0` and `tar ... -T -` combo safely handles filenames with spaces or special characters.
find "$LOG_DIR" -type f -mtime +$DAYS_TO_KEEP -print0 | tar -czvf "$BACKUP_DIR/$BACKUP_FILE" --null -T -

# Check if the tar command was successful.
if [ $? -eq 0 ]; then
    echo "Backup created successfully: $BACKUP_DIR/$BACKUP_FILE"

    # Now, delete the old log files.
    echo "Deleting old log files from $LOG_DIR..."
    find "$LOG_DIR" -type f -mtime +$DAYS_TO_KEEP -delete
    
    if [ $? -eq 0 ]; then
        echo "Old log files successfully deleted."
    else
        echo "An error occurred while deleting files."
    fi
else
    echo "An error occurred during the backup process. No files were deleted."
fi

exit 0
