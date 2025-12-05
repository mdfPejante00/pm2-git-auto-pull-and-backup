# Git Auto Fetch/Pull and Restore Scripts

This repository includes two shell scripts to help manage a Git repository deployed on a server:

- `gh-auto-fetch-pull.sh` — Fetch and pull the latest changes from a specified branch, create a timestamped backup of the working directory, and restart a PM2 process.
- `gh-restore-backup.sh` — Restore the repository working directory from a previously created backup archive and restart a PM2 process.

Both scripts are designed for simple server-side deployment workflows where you want a lightweight backup and restore mechanism around Git pulls.

## Prerequisites

- Linux/Unix shell environment (bash)
- git
- tar
- PM2 (Node.js process manager), if you rely on the included restart step
- Permissions to read/write the repository directory and backup directory

## Configuration

Both scripts include a configuration section at the top. Update these variables before use:

- `REPO_DIR` — Absolute path to the target Git repository working directory.
- `BACKUP_DIR` — Absolute path where backups should be stored and/or read from.
- `BRANCH` (only in `gh-auto-fetch-pull.sh`) — Name of the branch to pull from `origin`.

The scripts also restart `PM2` process ID `0` by default. Update the restart step if your setup differs (see PM2 notes below).

## Script: gh-auto-fetch-pull.sh

Purpose:
- Verifies `REPO_DIR` is a Git repository.
- Runs `git fetch origin` followed by `git pull origin <BRANCH>`.
- On successful pull, creates a gzip-compressed backup archive of the repository working directory in `BACKUP_DIR` using a timestamped filename: `repo-backup-YYYY-MM-DD_HH-MM-SS.tar.gz`.
- Restarts PM2 process ID `0`.

Usage:
1. Edit the config section in the script to set `REPO_DIR`, `BACKUP_DIR`, and `BRANCH`.
2. Ensure the script is executable: `chmod +x gh-auto-fetch-pull.sh`.
3. Run: `./gh-auto-fetch-pull.sh`.

Notes:
- If `git pull` fails, the script exits and no backup is created.
- The backup is a snapshot of the working directory at the time of the pull (includes untracked files that exist in the working tree).

## Script: gh-restore-backup.sh

Purpose:
- Restores the repository working directory from a specified backup archive located in `BACKUP_DIR`.
- Prompts for confirmation, then clears the contents of `REPO_DIR` and extracts the archive there.
- Restarts PM2 process ID `0`.

Usage:
1. Edit the config section in the script to set `REPO_DIR` and `BACKUP_DIR`.
2. Ensure the script is executable: `chmod +x gh-restore-backup.sh`.
3. Run: `./gh-restore-backup.sh <backup-file.tar.gz>`
   - Example: `./gh-restore-backup.sh repo-backup-1990-01-01_00-00-00.tar.gz`

Notes:
- The restore process will OVERWRITE the contents of `REPO_DIR`. The script prompts for confirmation.
- The backup file must exist at the path: `${BACKUP_DIR}/<backup-file.tar.gz>`.

## PM2 Restart Behavior

Both scripts end with:

```
pm2 restart 0
```

Adjust this to fit your environment. Common options:
- Restart by process name: `pm2 restart my-app`
- Reload (zero-downtime for cluster mode): `pm2 reload my-app`
- Skip PM2 entirely by commenting/removing the line if you do not use PM2.

## Backup Details

- Backup files are created under `BACKUP_DIR` with the format: `repo-backup-YYYY-MM-DD_HH-MM-SS.tar.gz`.
- Contents: the entire working directory of `REPO_DIR` at backup time.
- Ensure `BACKUP_DIR` has adequate disk space and proper permissions.

## Safety and Best Practices

- Validate `REPO_DIR` points to the intended Git repository and contains a `.git` directory.
- Test the scripts on a non-production copy first.
- Store backups on a separate volume or remote storage if possible.
- Consider log rotation or cleanup for old backups (e.g., via cron) to manage disk usage.
- If you have long-running Node.js apps, prefer `pm2 reload` over `restart` for zero-downtime in cluster mode.

## Example Setup

- Example config:
  - `REPO_DIR=/var/www/my-app`
  - `BACKUP_DIR=/var/backups/my-app`
  - `BRANCH=main`

- Make scripts executable:
  - `chmod +x gh-auto-fetch-pull.sh gh-restore-backup.sh`

- Run pull + backup:
  - `./gh-auto-fetch-pull.sh`

- List available backups:
  - `ls -lh /var/backups/my-app/*.tar.gz`

- Restore a backup:
  - `./gh-restore-backup.sh repo-backup-1990-01-01_00-00-00.tar.gz`

## Automation (Optional)

You can schedule `gh-auto-fetch-pull.sh` via cron to regularly pull and back up:

- Edit crontab: `crontab -e`
- Example entry (pull and backup every day at 02:00):
  - `0 2 * * * /path/to/gh-auto-fetch-pull.sh >> /var/log/gh-auto-fetch-pull.log 2>&1`

Ensure environment variables and permissions are set correctly for cron.

## Troubleshooting

- "is NOT a git repository" — Verify `REPO_DIR` points to a folder with `.git`.
- `git pull` failures — Check network, branch name, or local changes causing conflicts.
- Permission denied — Ensure the user has read/write access to `REPO_DIR` and `BACKUP_DIR`.
- PM2 errors — Confirm PM2 is installed and the target process identifier or name is correct.
- Restore errors — Ensure the specified backup file exists in `BACKUP_DIR` and is readable.

## License

Use these scripts at your own risk. Adapt as needed for your environment.
