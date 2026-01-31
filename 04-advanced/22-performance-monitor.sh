#!/bin/bash

# Script: System Performance Monitor
# Purpose: Monitor system performance metrics and generate reports
# Usage: ./22-performance-monitor.sh [command] [options]

echo "=== System Performance Monitor ==="

# Function to display usage
usage() {
    echo "Usage: $0 [command] [options]"
    echo "Commands:"
    echo "  cpu                       - Monitor CPU usage"
    echo "  memory                    - Monitor memory usage"
    echo "  disk                      - Monitor disk I/O"
    echo "  network                   - Monitor network traffic"
    echo "  all                       - Monitor all metrics"
    echo "  report                    - Generate performance report"
    exit 1
}

# Function to monitor CPU
monitor_cpu() {
    echo "CPU Performance Monitor:"
    echo "======================="
    
    echo "CPU Information:"
    lscpu | grep -E "(Model name|CPU\(s\)|Thread|Core)"
    
    echo
    echo "Current CPU usage:"
    top -bn1 | grep "Cpu(s)" | awk '{print "CPU Usage: " $2}'
    
    echo
    echo "Load averages:"
    uptime
    
    echo
    echo "Top CPU consuming processes:"
    ps aux --sort=-%cpu | head -6
}

# Function to monitor memory
monitor_memory() {
    echo "Memory Performance Monitor:"
    echo "=========================="
    
    echo "Memory usage:"
    free -h
    
    echo
    echo "Memory usage percentage:"
    free | awk 'NR==2{printf "Memory Usage: %.2f%%\n", $3*100/$2}'
    
    echo
    echo "Top memory consuming processes:"
    ps aux --sort=-%mem | head -6
}

# Function to monitor disk
monitor_disk() {
    echo "Disk Performance Monitor:"
    echo "========================"
    
    echo "Disk usage:"
    df -h
    
    echo
    echo "Disk I/O statistics:"
    if command -v iostat >/dev/null 2>&1; then
        iostat -x 1 1
    else
        echo "iostat not available. Install sysstat package."
    fi
}

# Function to monitor network
monitor_network() {
    echo "Network Performance Monitor:"
    echo "==========================="
    
    echo "Network interfaces:"
    ip -s link
    
    echo
    echo "Network connections:"
    ss -tuln | head -10
}

# Function to monitor all metrics
monitor_all() {
    echo "Complete System Performance Monitor"
    echo "=================================="
    echo "Timestamp: $(date)"
    echo
    
    monitor_cpu
    echo
    monitor_memory
    echo
    monitor_disk
    echo
    monitor_network
}

# Function to generate performance report
generate_report() {
    local report_file="performance_report_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "Generating performance report: $report_file"
    
    {
        echo "System Performance Report"
        echo "========================"
        echo "Generated: $(date)"
        echo "Hostname: $(hostname)"
        echo "Uptime: $(uptime)"
        echo
        
        monitor_all
        
    } > "$report_file"
    
    echo "Report saved: $report_file"
}

# Main logic
case "${1:-}" in
    "cpu")
        monitor_cpu
        ;;
    "memory")
        monitor_memory
        ;;
    "disk")
        monitor_disk
        ;;
    "network")
        monitor_network
        ;;
    "all")
        monitor_all
        ;;
    "report")
        generate_report
        ;;
    *)
        usage
        ;;
esac
