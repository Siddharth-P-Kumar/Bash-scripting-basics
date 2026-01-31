#!/bin/bash

# Script: Database Operations
# Purpose: Basic database operations for MySQL/PostgreSQL
# Usage: ./18-database-ops.sh [command] [options]

echo "=== Database Operations Manager ==="

# Configuration
DB_TYPE=""
DB_HOST="localhost"
DB_PORT=""
DB_USER=""
DB_PASSWORD=""
DB_NAME=""
BACKUP_DIR="/tmp/db_backups"

# Function to display usage
usage() {
    echo "Usage: $0 [command] [options]"
    echo "Commands:"
    echo "  connect mysql|postgres    - Test database connection"
    echo "  backup <db_name>          - Backup database"
    echo "  restore <backup_file>     - Restore database"
    echo "  list-dbs                  - List all databases"
    echo "  list-tables <db_name>     - List tables in database"
    echo "  query <db_name> <query>   - Execute SQL query"
    echo "  monitor <db_name>         - Monitor database performance"
    echo "  setup                     - Setup database configuration"
    exit 1
}

# Function to setup database configuration
setup_config() {
    echo "Database Configuration Setup:"
    echo "============================"
    
    echo "Select database type:"
    echo "1) MySQL"
    echo "2) PostgreSQL"
    read -p "Enter choice (1-2): " choice
    
    case $choice in
        1)
            DB_TYPE="mysql"
            DB_PORT="3306"
            ;;
        2)
            DB_TYPE="postgres"
            DB_PORT="5432"
            ;;
        *)
            echo "Invalid choice"
            return 1
            ;;
    esac
    
    read -p "Database host [$DB_HOST]: " input
    DB_HOST=${input:-$DB_HOST}
    
    read -p "Database port [$DB_PORT]: " input
    DB_PORT=${input:-$DB_PORT}
    
    read -p "Database username: " DB_USER
    read -s -p "Database password: " DB_PASSWORD
    echo
    
    # Save configuration
    cat > ~/.db_config << EOF
DB_TYPE=$DB_TYPE
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
EOF
    
    chmod 600 ~/.db_config
    echo "Configuration saved to ~/.db_config"
}

# Function to load configuration
load_config() {
    if [ -f ~/.db_config ]; then
        source ~/.db_config
    else
        echo "No configuration found. Run: $0 setup"
        return 1
    fi
}

# Function to test database connection
test_connection() {
    local db_type=$1
    
    if [ -z "$db_type" ]; then
        echo "Error: Database type required (mysql|postgres)"
        return 1
    fi
    
    if ! load_config; then
        return 1
    fi
    
    echo "Testing $db_type connection to $DB_HOST:$DB_PORT..."
    
    case $db_type in
        "mysql")
            if ! command -v mysql >/dev/null 2>&1; then
                echo "Error: MySQL client not installed"
                return 1
            fi
            
            if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
                echo "✓ MySQL connection successful"
                mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT VERSION();"
            else
                echo "✗ MySQL connection failed"
                return 1
            fi
            ;;
        "postgres")
            if ! command -v psql >/dev/null 2>&1; then
                echo "Error: PostgreSQL client not installed"
                return 1
            fi
            
            export PGPASSWORD="$DB_PASSWORD"
            if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT 1;" >/dev/null 2>&1; then
                echo "✓ PostgreSQL connection successful"
                psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "SELECT version();"
            else
                echo "✗ PostgreSQL connection failed"
                return 1
            fi
            ;;
        *)
            echo "Unsupported database type: $db_type"
            return 1
            ;;
    esac
}

# Function to backup database
backup_database() {
    local db_name=$1
    
    if [ -z "$db_name" ]; then
        echo "Error: Database name required"
        return 1
    fi
    
    if ! load_config; then
        return 1
    fi
    
    mkdir -p "$BACKUP_DIR"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/${db_name}_${timestamp}.sql"
    
    echo "Backing up database: $db_name"
    echo "Backup file: $backup_file"
    
    case $DB_TYPE in
        "mysql")
            if mysqldump -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$db_name" > "$backup_file"; then
                echo "✓ MySQL backup completed"
                gzip "$backup_file"
                echo "Compressed backup: ${backup_file}.gz"
            else
                echo "✗ MySQL backup failed"
                return 1
            fi
            ;;
        "postgres")
            export PGPASSWORD="$DB_PASSWORD"
            if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$db_name" > "$backup_file"; then
                echo "✓ PostgreSQL backup completed"
                gzip "$backup_file"
                echo "Compressed backup: ${backup_file}.gz"
            else
                echo "✗ PostgreSQL backup failed"
                return 1
            fi
            ;;
    esac
}

# Function to restore database
restore_database() {
    local backup_file=$1
    
    if [ -z "$backup_file" ]; then
        echo "Error: Backup file required"
        return 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        echo "Error: Backup file not found: $backup_file"
        return 1
    fi
    
    if ! load_config; then
        return 1
    fi
    
    # Extract database name from filename
    local db_name=$(basename "$backup_file" | cut -d'_' -f1)
    
    echo "Restoring database: $db_name from $backup_file"
    echo "WARNING: This will overwrite the existing database!"
    read -p "Continue? (y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Restore cancelled"
        return 0
    fi
    
    # Handle compressed files
    local restore_cmd=""
    if [[ "$backup_file" == *.gz ]]; then
        restore_cmd="zcat $backup_file"
    else
        restore_cmd="cat $backup_file"
    fi
    
    case $DB_TYPE in
        "mysql")
            if $restore_cmd | mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$db_name"; then
                echo "✓ MySQL restore completed"
            else
                echo "✗ MySQL restore failed"
                return 1
            fi
            ;;
        "postgres")
            export PGPASSWORD="$DB_PASSWORD"
            if $restore_cmd | psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$db_name"; then
                echo "✓ PostgreSQL restore completed"
            else
                echo "✗ PostgreSQL restore failed"
                return 1
            fi
            ;;
    esac
}

# Function to list databases
list_databases() {
    if ! load_config; then
        return 1
    fi
    
    echo "Databases on $DB_HOST:"
    echo "====================="
    
    case $DB_TYPE in
        "mysql")
            mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW DATABASES;"
            ;;
        "postgres")
            export PGPASSWORD="$DB_PASSWORD"
            psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "\l"
            ;;
    esac
}

# Function to list tables
list_tables() {
    local db_name=$1
    
    if [ -z "$db_name" ]; then
        echo "Error: Database name required"
        return 1
    fi
    
    if ! load_config; then
        return 1
    fi
    
    echo "Tables in database: $db_name"
    echo "============================"
    
    case $DB_TYPE in
        "mysql")
            mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$db_name" -e "SHOW TABLES;"
            ;;
        "postgres")
            export PGPASSWORD="$DB_PASSWORD"
            psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$db_name" -c "\dt"
            ;;
    esac
}

# Function to execute query
execute_query() {
    local db_name=$1
    local query=$2
    
    if [ -z "$db_name" ] || [ -z "$query" ]; then
        echo "Error: Database name and query required"
        return 1
    fi
    
    if ! load_config; then
        return 1
    fi
    
    echo "Executing query on database: $db_name"
    echo "Query: $query"
    echo "=================================="
    
    case $DB_TYPE in
        "mysql")
            mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$db_name" -e "$query"
            ;;
        "postgres")
            export PGPASSWORD="$DB_PASSWORD"
            psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$db_name" -c "$query"
            ;;
    esac
}

# Function to monitor database
monitor_database() {
    local db_name=$1
    
    if [ -z "$db_name" ]; then
        echo "Error: Database name required"
        return 1
    fi
    
    if ! load_config; then
        return 1
    fi
    
    echo "Database Performance Monitor: $db_name"
    echo "======================================"
    
    case $DB_TYPE in
        "mysql")
            echo "MySQL Status Variables:"
            mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW STATUS LIKE 'Connections';"
            mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW STATUS LIKE 'Uptime';"
            mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW STATUS LIKE 'Queries';"
            
            echo
            echo "Active Processes:"
            mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW PROCESSLIST;"
            ;;
        "postgres")
            export PGPASSWORD="$DB_PASSWORD"
            echo "PostgreSQL Statistics:"
            psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$db_name" -c "SELECT * FROM pg_stat_database WHERE datname = '$db_name';"
            
            echo
            echo "Active Connections:"
            psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$db_name" -c "SELECT * FROM pg_stat_activity WHERE datname = '$db_name';"
            ;;
    esac
}

# Main script logic
case "${1:-}" in
    "connect")
        if [ -z "$2" ]; then
            echo "Error: Database type required (mysql|postgres)"
            usage
        fi
        test_connection "$2"
        ;;
    "backup")
        if [ -z "$2" ]; then
            echo "Error: Database name required"
            usage
        fi
        backup_database "$2"
        ;;
    "restore")
        if [ -z "$2" ]; then
            echo "Error: Backup file required"
            usage
        fi
        restore_database "$2"
        ;;
    "list-dbs")
        list_databases
        ;;
    "list-tables")
        if [ -z "$2" ]; then
            echo "Error: Database name required"
            usage
        fi
        list_tables "$2"
        ;;
    "query")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Error: Database name and query required"
            usage
        fi
        execute_query "$2" "$3"
        ;;
    "monitor")
        if [ -z "$2" ]; then
            echo "Error: Database name required"
            usage
        fi
        monitor_database "$2"
        ;;
    "setup")
        setup_config
        ;;
    *)
        usage
        ;;
esac
