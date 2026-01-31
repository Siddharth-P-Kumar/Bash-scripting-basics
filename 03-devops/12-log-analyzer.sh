#!/bin/bash

# Script: Log Analyzer and Monitor
# Purpose: Analyze system logs and monitor for specific patterns
# Usage: ./12-log-analyzer.sh [log_file] [pattern]

echo "=== Log Analyzer and Monitor ==="

# Default values
DEFAULT_LOG="/var/log/syslog"
DEFAULT_PATTERN="error|warning|fail"

# Function to display usage
usage() {
    echo "Usage: $0 [log_file] [pattern]"
    echo "  log_file: Path to log file (default: $DEFAULT_LOG)"
    echo "  pattern: Pattern to search for (default: $DEFAULT_PATTERN)"
    echo "Examples:"
    echo "  $0"
    echo "  $0 /var/log/apache2/error.log"
    echo "  $0 /var/log/syslog 'ssh|login'"
    exit 1
}

# Parse arguments
log_file=${1:-$DEFAULT_LOG}
search_pattern=${2:-$DEFAULT_PATTERN}

# Check if log file exists and is readable
if [ ! -f "$log_file" ]; then
    echo "Error: Log file '$log_file' not found!"
    echo "Trying alternative log files..."
    
    # Try alternative log files
    alternatives=("/var/log/messages" "/var/log/system.log" "/var/log/auth.log")
    found=false
    
    for alt in "${alternatives[@]}"; do
        if [ -f "$alt" ] && [ -r "$alt" ]; then
            log_file="$alt"
            echo "Using alternative log file: $log_file"
            found=true
            break
        fi
    done
    
    if [ "$found" = false ]; then
        echo "No accessible log files found. Creating demo log..."
        log_file="demo.log"
        cat > "$log_file" << EOF
$(date) INFO: System started successfully
$(date) WARNING: High memory usage detected
$(date) ERROR: Failed to connect to database
$(date) INFO: User login successful
$(date) ERROR: Permission denied for file access
$(date) WARNING: Disk space running low
EOF
    fi
fi

if [ ! -r "$log_file" ]; then
    echo "Error: Cannot read log file '$log_file'"
    exit 1
fi

echo "Analyzing log file: $log_file"
echo "Search pattern: $search_pattern"
echo "File size: $(du -h "$log_file" | cut -f1)"
echo "Total lines: $(wc -l < "$log_file")"
echo

# Basic log statistics
echo "=== LOG STATISTICS ==="
echo "First entry: $(head -1 "$log_file" | cut -c1-50)..."
echo "Last entry: $(tail -1 "$log_file" | cut -c1-50)..."
echo

# Search for patterns
echo "=== PATTERN MATCHES ==="
matches=$(grep -i -c "$search_pattern" "$log_file" 2>/dev/null || echo "0")
echo "Found $matches matches for pattern: $search_pattern"

if [ "$matches" -gt 0 ]; then
    echo
    echo "Recent matches (last 10):"
    grep -i "$search_pattern" "$log_file" | tail -10
fi

# Error analysis
echo
echo "=== ERROR ANALYSIS ==="
error_count=$(grep -i -c "error" "$log_file" 2>/dev/null || echo "0")
warning_count=$(grep -i -c "warning" "$log_file" 2>/dev/null || echo "0")
info_count=$(grep -i -c "info" "$log_file" 2>/dev/null || echo "0")

echo "Error count: $error_count"
echo "Warning count: $warning_count"
echo "Info count: $info_count"

# Top error messages
if [ "$error_count" -gt 0 ]; then
    echo
    echo "Most common error patterns:"
    grep -i "error" "$log_file" | awk '{for(i=4;i<=NF;i++) printf "%s ", $i; print ""}' | sort | uniq -c | sort -nr | head -5
fi

# Time-based analysis
echo
echo "=== TIME-BASED ANALYSIS ==="
echo "Log entries by hour (last 24 hours):"

# Extract timestamps and count by hour
if grep -q "$(date '+%Y-%m-%d')" "$log_file" 2>/dev/null; then
    for hour in {00..23}; do
        count=$(grep "$(date '+%Y-%m-%d') $hour:" "$log_file" 2>/dev/null | wc -l)
        if [ "$count" -gt 0 ]; then
            printf "%s:00 - %d entries\n" "$hour" "$count"
        fi
    done
else
    echo "No entries found for today's date"
fi

# IP address analysis (if log contains IPs)
echo
echo "=== IP ADDRESS ANALYSIS ==="
ip_pattern='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
ip_count=$(grep -oE "$ip_pattern" "$log_file" 2>/dev/null | wc -l)

if [ "$ip_count" -gt 0 ]; then
    echo "Found $ip_count IP addresses"
    echo "Top 5 IP addresses:"
    grep -oE "$ip_pattern" "$log_file" | sort | uniq -c | sort -nr | head -5
else
    echo "No IP addresses found in log"
fi

# Log monitoring function
monitor_log() {
    echo
    echo "=== REAL-TIME MONITORING ==="
    echo "Monitoring $log_file for pattern: $search_pattern"
    echo "Press Ctrl+C to stop monitoring"
    echo
    
    tail -f "$log_file" | grep --line-buffered -i "$search_pattern" | while read line; do
        echo "[$(date '+%H:%M:%S')] MATCH: $line"
    done
}

# Ask user if they want to monitor in real-time
echo
echo "Do you want to monitor the log file in real-time? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    monitor_log
fi

# Generate report
generate_report() {
    local report_file="log_analysis_$(date '+%Y%m%d_%H%M%S').txt"
    echo "Generating detailed report: $report_file"
    
    {
        echo "Log Analysis Report"
        echo "Generated: $(date)"
        echo "Log file: $log_file"
        echo "Search pattern: $search_pattern"
        echo
        echo "=== SUMMARY ==="
        echo "Total lines: $(wc -l < "$log_file")"
        echo "Errors: $error_count"
        echo "Warnings: $warning_count"
        echo "Pattern matches: $matches"
        echo
        echo "=== RECENT MATCHES ==="
        grep -i "$search_pattern" "$log_file" | tail -20
    } > "$report_file"
    
    echo "Report saved to: $report_file"
}

echo
echo "Generate detailed report? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    generate_report
fi

# Cleanup demo log if created
if [ "$log_file" = "demo.log" ]; then
    echo
    echo "Cleaning up demo log file..."
    rm -f "demo.log"
fi

echo "Log analysis completed!"
