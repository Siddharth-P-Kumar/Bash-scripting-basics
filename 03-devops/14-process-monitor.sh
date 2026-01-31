#!/bin/bash

# Script: Process Monitor and Manager
# Purpose: Monitor system processes, manage services, and track resource usage
# Usage: ./14-process-monitor.sh [command] [options]

echo "=== Process Monitor and Manager ==="

# Configuration
ALERT_CPU_THRESHOLD=80
ALERT_MEMORY_THRESHOLD=80
LOG_FILE="/tmp/process_monitor.log"

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
    echo "  monitor                    - Monitor system processes"
    echo "  top-cpu [count]           - Show top CPU consuming processes"
    echo "  top-memory [count]        - Show top memory consuming processes"
    echo "  find <name>               - Find processes by name"
    echo "  kill <pid|name>           - Kill process by PID or name"
    echo "  services                  - Show system services status"
    echo "  alerts                    - Check for resource alerts"
    echo "  watch <pid>               - Watch specific process"
    exit 1
}

# Function to get process information
get_process_info() {
    local pid=$1
    if [ -z "$pid" ]; then
        echo "Error: PID required"
        return 1
    fi
    
    if [ ! -d "/proc/$pid" ]; then
        echo "Error: Process $pid not found"
        return 1
    fi
    
    echo "Process Information for PID: $pid"
    echo "=================================="
    
    # Basic info
    local cmd=$(cat /proc/$pid/comm 2>/dev/null || echo "N/A")
    local cmdline=$(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ' || echo "N/A")
    local status=$(cat /proc/$pid/status 2>/dev/null | grep "State" | awk '{print $2, $3}' || echo "N/A")
    
    echo "Command: $cmd"
    echo "Command Line: $cmdline"
    echo "Status: $status"
    
    # Resource usage
    local cpu_usage=$(ps -p $pid -o %cpu --no-headers 2>/dev/null || echo "N/A")
    local mem_usage=$(ps -p $pid -o %mem --no-headers 2>/dev/null || echo "N/A")
    local rss=$(ps -p $pid -o rss --no-headers 2>/dev/null || echo "N/A")
    
    echo "CPU Usage: ${cpu_usage}%"
    echo "Memory Usage: ${mem_usage}%"
    echo "RSS Memory: ${rss} KB"
    
    # Process tree
    echo
    echo "Process Tree:"
    pstree -p $pid 2>/dev/null || echo "Process tree not available"
}

# Function to show top CPU processes
show_top_cpu() {
    local count=${1:-10}
    echo "Top $count CPU consuming processes:"
    echo "===================================="
    printf "%-8s %-8s %-8s %-50s\n" "PID" "CPU%" "MEM%" "COMMAND"
    echo "--------------------------------------------------------------------"
    ps aux --sort=-%cpu | head -n $((count + 1)) | tail -n $count | \
        awk '{printf "%-8s %-8s %-8s %-50s\n", $2, $3, $4, $11}'
}

# Function to show top memory processes
show_top_memory() {
    local count=${1:-10}
    echo "Top $count memory consuming processes:"
    echo "====================================="
    printf "%-8s %-8s %-8s %-50s\n" "PID" "CPU%" "MEM%" "COMMAND"
    echo "--------------------------------------------------------------------"
    ps aux --sort=-%mem | head -n $((count + 1)) | tail -n $count | \
        awk '{printf "%-8s %-8s %-8s %-50s\n", $2, $3, $4, $11}'
}

# Function to find processes by name
find_processes() {
    local name=$1
    if [ -z "$name" ]; then
        echo "Error: Process name required"
        return 1
    fi
    
    echo "Processes matching '$name':"
    echo "=========================="
    printf "%-8s %-8s %-8s %-50s\n" "PID" "CPU%" "MEM%" "COMMAND"
    echo "--------------------------------------------------------------------"
    
    ps aux | grep -i "$name" | grep -v grep | \
        awk '{printf "%-8s %-8s %-8s %-50s\n", $2, $3, $4, $11}'
}

# Function to kill process
kill_process() {
    local target=$1
    if [ -z "$target" ]; then
        echo "Error: PID or process name required"
        return 1
    fi
    
    # Check if target is a PID (numeric)
    if [[ "$target" =~ ^[0-9]+$ ]]; then
        # Kill by PID
        if kill -0 "$target" 2>/dev/null; then
            echo "Killing process PID: $target"
            if kill "$target" 2>/dev/null; then
                log_message "INFO" "Successfully killed process PID: $target"
                echo "Process killed successfully"
            else
                log_message "ERROR" "Failed to kill process PID: $target"
                echo "Failed to kill process. Try with sudo or kill -9"
            fi
        else
            echo "Process PID $target not found"
        fi
    else
        # Kill by name
        local pids=$(pgrep "$target")
        if [ -n "$pids" ]; then
            echo "Found processes matching '$target':"
            ps -p $pids -o pid,comm,cmd --no-headers
            echo
            echo "Kill all these processes? (y/n)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                for pid in $pids; do
                    if kill "$pid" 2>/dev/null; then
                        log_message "INFO" "Killed process: $target (PID: $pid)"
                        echo "Killed PID: $pid"
                    else
                        log_message "ERROR" "Failed to kill process: $target (PID: $pid)"
                        echo "Failed to kill PID: $pid"
                    fi
                done
            fi
        else
            echo "No processes found matching '$target'"
        fi
    fi
}

# Function to show system services
show_services() {
    echo "System Services Status:"
    echo "======================"
    
    if command -v systemctl >/dev/null 2>&1; then
        echo "Active services:"
        systemctl list-units --type=service --state=active --no-legend | head -10
        echo
        echo "Failed services:"
        systemctl list-units --type=service --state=failed --no-legend
    else
        echo "Systemctl not available. Showing process-based services:"
        ps aux | grep -E "(sshd|httpd|nginx|mysql|postgres)" | grep -v grep
    fi
}

# Function to check resource alerts
check_alerts() {
    echo "Resource Alerts Check:"
    echo "====================="
    
    # CPU usage alert
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    if (( $(echo "$cpu_usage > $ALERT_CPU_THRESHOLD" | bc -l) )); then
        log_message "ALERT" "High CPU usage: ${cpu_usage}%"
        echo "🚨 ALERT: High CPU usage: ${cpu_usage}%"
    else
        echo "✅ CPU usage normal: ${cpu_usage}%"
    fi
    
    # Memory usage alert
    local mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    if (( $(echo "$mem_usage > $ALERT_MEMORY_THRESHOLD" | bc -l) )); then
        log_message "ALERT" "High memory usage: ${mem_usage}%"
        echo "🚨 ALERT: High memory usage: ${mem_usage}%"
    else
        echo "✅ Memory usage normal: ${mem_usage}%"
    fi
    
    # Disk usage alert
    echo
    echo "Disk usage check:"
    df -h | awk 'NR>1 {gsub(/%/, "", $5); if($5 > 80) print "🚨 ALERT: " $6 " is " $5 "% full"; else print "✅ " $6 " usage normal: " $5 "%"}'
    
    # Load average alert
    local load1=$(cat /proc/loadavg | awk '{print $1}')
    local cpu_count=$(nproc)
    local load_threshold=$(echo "$cpu_count * 0.8" | bc)
    
    if (( $(echo "$load1 > $load_threshold" | bc -l) )); then
        log_message "ALERT" "High load average: $load1 (threshold: $load_threshold)"
        echo "🚨 ALERT: High load average: $load1"
    else
        echo "✅ Load average normal: $load1"
    fi
}

# Function to watch a specific process
watch_process() {
    local pid=$1
    if [ -z "$pid" ]; then
        echo "Error: PID required"
        return 1
    fi
    
    if [ ! -d "/proc/$pid" ]; then
        echo "Error: Process $pid not found"
        return 1
    fi
    
    echo "Watching process PID: $pid (Press Ctrl+C to stop)"
    echo "================================================"
    
    while [ -d "/proc/$pid" ]; do
        clear
        echo "Process Monitor - PID: $pid - $(date)"
        echo "====================================="
        get_process_info "$pid"
        sleep 2
    done
    
    echo "Process $pid has terminated"
}

# Function to monitor system continuously
monitor_system() {
    echo "System Process Monitor (Press Ctrl+C to stop)"
    echo "============================================="
    
    while true; do
        clear
        echo "System Process Monitor - $(date)"
        echo "================================"
        
        # System overview
        echo "System Load: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
        echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')"
        echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
        echo
        
        # Top processes
        show_top_cpu 5
        echo
        show_top_memory 5
        
        sleep 5
    done
}

# Main script logic
case "${1:-}" in
    "monitor")
        monitor_system
        ;;
    "top-cpu")
        show_top_cpu "$2"
        ;;
    "top-memory")
        show_top_memory "$2"
        ;;
    "find")
        if [ -z "$2" ]; then
            echo "Error: Process name required"
            usage
        fi
        find_processes "$2"
        ;;
    "kill")
        if [ -z "$2" ]; then
            echo "Error: PID or process name required"
            usage
        fi
        kill_process "$2"
        ;;
    "services")
        show_services
        ;;
    "alerts")
        check_alerts
        ;;
    "watch")
        if [ -z "$2" ]; then
            echo "Error: PID required"
            usage
        fi
        watch_process "$2"
        ;;
    "info")
        if [ -z "$2" ]; then
            echo "Error: PID required"
            usage
        fi
        get_process_info "$2"
        ;;
    *)
        usage
        ;;
esac
