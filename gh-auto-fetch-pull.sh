#!/bin/bash

# === CONFIGURE ===
REPO_DIR="/path/to/your/repo"
BACKUP_DIR="/path/to/your/backups"
BRANCH="main"
# =======================

echo "->>> Checking repo directory: $REPO_DIR"

if [ ! -d "$REPO_DIR/.git" ]; then
    echo "ERROR: $REPO_DIR is NOT a git repository."
    exit 1
fi

# BACKUP DIR
mkdir -p "$BACKUP_DIR"

cd "$REPO_DIR" || exit 1

echo "->>> Fetching origin..."
git fetch origin

echo "->>> Pulling latest changes from origin $BRANCH..."
if git pull origin "$BRANCH"; then
    echo "->>> Pull successful! Creating backup..."

    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_FILE="$BACKUP_DIR/repo-backup-$TIMESTAMP.tar.gz"

    tar -czf "$BACKUP_FILE" -C "$REPO_DIR" .

    echo "->>> Backup created:"
    echo "$BACKUP_FILE"
else
    echo "Pull failed! Backup NOT created."
    exit 1
fi

echo "->>> Restarting PM2 process ID 0..."
pm2 restart 0

echo "->>> Done!"
