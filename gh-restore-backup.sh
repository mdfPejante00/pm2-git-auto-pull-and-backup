#!/bin/bash

# === CONFIGURE ===
REPO_DIR="/path/to/your/repo"
BACKUP_DIR="/path/to/your/backups"
# =======================

# Check parameter
if [ -z "$1" ]; then
    echo "ERROR: You must provide the backup file name."
    echo "Usage: $0 <backup-file.tar.gz>"
    exit 1
fi

BACKUP_FILE="$BACKUP_DIR/$1"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found:"
    echo "$BACKUP_FILE"
    exit 1
fi

echo "->>> Backup to restore:"
echo "$BACKUP_FILE"
echo ""

# Confirm overwrite
read -p "This will OVERWRITE the repo folder. Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

# Ensure repo dir exists
mkdir -p "$REPO_DIR"

echo "->>> Clearing repo directory..."
rm -rf "$REPO_DIR"/*

echo "->>> Restoring backup..."
tar -xzf "$BACKUP_FILE" -C "$REPO_DIR"

echo "->>> Restore complete!"
echo "Repo restored from:"
echo "$BACKUP_FILE"

echo "->>> Restarting PM2 process ID 0..."
pm2 restart 0

echo "->>> Done!"
