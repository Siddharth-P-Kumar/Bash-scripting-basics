#!/bin/bash

# Script: Backup and Restore System
# Purpose: Create automated backups with compression and rotation
# Usage: ./13-backup-system.sh [backup|restore] [source] [destination]

echo "=== Backup and Restore System ==="

# Configuration
BACKUP_DIR="/tmp/backups"
MAX_BACKUPS=5
COMPRESSION="gzip"  # Options: gzip, bzip2, xz
LOG_FILE="/tmp/backup.log"

# Function to log messages
log_message() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Function to display usage
usage() {
    echo "Usage: $0 [command] [options]"
    echo "Commands:"
    echo "  backup <source> [destination]  - Create backup"
    echo "  restore <backup_file> <destination> - Restore from backup"
    echo "  list                          - List available backups"
    echo "  cleanup                       - Remove old backups"
    echo "Examples:"
    echo "  $0 backup /home/user/documents"
    echo "  $0 backup /etc /tmp/my_backups"
    echo "  $0 restore backup_20240131.tar.gz /tmp/restore"
    echo "  $0 list"
    exit 1
}

# Function to create backup
create_backup() {
    local source_dir=$1
    local dest_dir=${2:-$BACKUP_DIR}
    
    # Validate source directory
    if [ ! -d "$source_dir" ]; then
        log_message "ERROR" "Source directory '$source_dir' does not exist"
        return 1
    fi
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    
    # Generate backup filename with timestamp
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local source_name=$(basename "$source_dir")
    local backup_file="$dest_dir/backup_${source_name}_${timestamp}.tar.gz"
    
    log_message "INFO" "Starting backup of '$source_dir'"
    log_message "INFO" "Backup file: $backup_file"
    
    # Calculate source size
    local source_size=$(du -sh "$source_dir" | cut -f1)
    log_message "INFO" "Source size: $source_size"
    
    # Create backup with progress
    if tar -czf "$backup_file" -C "$(dirname "$source_dir")" "$(basename "$source_dir")" 2>/dev/null; then
        local backup_size=$(du -sh "$backup_file" | cut -f1)
        log_message "INFO" "Backup completed successfully"
        log_message "INFO" "Backup size: $backup_size"
        log_message "INFO" "Backup location: $backup_file"
        
        # Verify backup integrity
        if tar -tzf "$backup_file" >/dev/null 2>&1; then
            log_message "INFO" "Backup integrity verified"
        else
            log_message "WARNING" "Backup integrity check failed"
        fi
        
        return 0
    else
        log_message "ERROR" "Backup failed"
        return 1
    fi
}

# Function to restore backup
restore_backup() {
    local backup_file=$1
    local restore_dir=$2
    
    # Validate backup file
    if [ ! -f "$backup_file" ]; then
        log_message "ERROR" "Backup file '$backup_file' does not exist"
        return 1
    fi
    
    # Create restore directory
    mkdir -p "$restore_dir"
    
    log_message "INFO" "Starting restore from '$backup_file'"
    log_message "INFO" "Restore location: $restore_dir"
    
    # Verify backup integrity before restore
    if ! tar -tzf "$backup_file" >/dev/null 2>&1; then
        log_message "ERROR" "Backup file is corrupted"
        return 1
    fi
    
    # Extract backup
    if tar -xzf "$backup_file" -C "$restore_dir" 2>/dev/null; then
        log_message "INFO" "Restore completed successfully"
        log_message "INFO" "Files restored to: $restore_dir"
        return 0
    else
        log_message "ERROR" "Restore failed"
        return 1
    fi
}

# Function to list backups
list_backups() {
    local backup_dir=${1:-$BACKUP_DIR}
    
    if [ ! -d "$backup_dir" ]; then
        echo "No backup directory found at: $backup_dir"
        return 1
    fi
    
    echo "Available backups in $backup_dir:"
    echo "================================================"
    
    local count=0
    for backup in "$backup_dir"/backup_*.tar.gz; do
        if [ -f "$backup" ]; then
            local size=$(du -sh "$backup" | cut -f1)
            local date=$(stat -c %y "$backup" | cut -d' ' -f1,2 | cut -d'.' -f1)
            printf "%-40s %8s %s\n" "$(basename "$backup")" "$size" "$date"
            count=$((count + 1))
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo "No backups found"
    else
        echo "================================================"
        echo "Total backups: $count"
    fi
}

# Function to cleanup old backups
cleanup_backups() {
    local backup_dir=${1:-$BACKUP_DIR}
    
    if [ ! -d "$backup_dir" ]; then
        log_message "INFO" "No backup directory to cleanup"
        return 0
    fi
    
    log_message "INFO" "Cleaning up old backups (keeping $MAX_BACKUPS most recent)"
    
    # Count current backups
    local backup_count=$(find "$backup_dir" -name "backup_*.tar.gz" | wc -l)
    
    if [ $backup_count -le $MAX_BACKUPS ]; then
        log_message "INFO" "No cleanup needed ($backup_count backups, limit: $MAX_BACKUPS)"
        return 0
    fi
    
    # Remove old backups
    local to_remove=$((backup_count - MAX_BACKUPS))
    find "$backup_dir" -name "backup_*.tar.gz" -type f -printf '%T@ %p\n' | \
        sort -n | head -n $to_remove | cut -d' ' -f2- | \
        while read -r old_backup; do
            log_message "INFO" "Removing old backup: $(basename "$old_backup")"
            rm -f "$old_backup"
        done
    
    log_message "INFO" "Cleanup completed"
}

# Function for incremental backup
incremental_backup() {
    local source_dir=$1
    local dest_dir=${2:-$BACKUP_DIR}
    local reference_file="$dest_dir/.last_backup"
    
    mkdir -p "$dest_dir"
    
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local source_name=$(basename "$source_dir")
    local backup_file="$dest_dir/incremental_${source_name}_${timestamp}.tar.gz"
    
    log_message "INFO" "Creating incremental backup"
    
    if [ -f "$reference_file" ]; then
        # Incremental backup - only files newer than reference
        find "$source_dir" -newer "$reference_file" -type f | \
            tar -czf "$backup_file" -T - 2>/dev/null
        log_message "INFO" "Incremental backup created: $backup_file"
    else
        # First backup - full backup
        create_backup "$source_dir" "$dest_dir"
    fi
    
    # Update reference file
    touch "$reference_file"
}

# Main script logic
case "${1:-}" in
    "backup")
        if [ $# -lt 2 ]; then
            echo "Error: Source directory required for backup"
            usage
        fi
        create_backup "$2" "$3"
        cleanup_backups "$3"
        ;;
    "restore")
        if [ $# -lt 3 ]; then
            echo "Error: Backup file and destination required for restore"
            usage
        fi
        restore_backup "$2" "$3"
        ;;
    "list")
        list_backups "$2"
        ;;
    "cleanup")
        cleanup_backups "$2"
        ;;
    "incremental")
        if [ $# -lt 2 ]; then
            echo "Error: Source directory required for incremental backup"
            usage
        fi
        incremental_backup "$2" "$3"
        ;;
    *)
        usage
        ;;
esac
