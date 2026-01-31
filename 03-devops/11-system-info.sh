#!/bin/bash

# Script: System Information Collector
# Purpose: Gather comprehensive system information for monitoring
# Usage: ./11-system-info.sh [--output file.txt]

echo "=== System Information Collector ==="

# Function to print section headers
print_header() {
    echo
    echo "==================== $1 ===================="
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Parse command line arguments
output_file=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            output_file="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--output filename]"
            exit 1
            ;;
    esac
done

# Redirect output to file if specified
if [ -n "$output_file" ]; then
    exec > "$output_file"
    echo "System information saved to: $output_file" >&2
fi

# Basic system information
print_header "BASIC SYSTEM INFO"
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo "Uptime: $(uptime)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"

# CPU information
print_header "CPU INFORMATION"
echo "CPU Model: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)"
echo "CPU Cores: $(nproc)"
echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"

# Memory information
print_header "MEMORY INFORMATION"
free -h
echo
echo "Memory Usage:"
awk '/MemTotal/ {total=$2} /MemAvailable/ {available=$2} END {used=total-available; printf "Used: %.1f%% (%.2f GB / %.2f GB)\n", used/total*100, used/1024/1024, total/1024/1024}' /proc/meminfo

# Disk information
print_header "DISK INFORMATION"
df -h
echo
echo "Disk Usage Summary:"
df -h | awk 'NR>1 {gsub(/%/, "", $5); if($5 > 80) print "WARNING: " $6 " is " $5 "% full"; else print "OK: " $6 " is " $5 "% full"}'

# Network information
print_header "NETWORK INFORMATION"
echo "Network Interfaces:"
ip addr show | grep -E '^[0-9]+:' | awk '{print $2}' | sed 's/://'
echo
echo "Active Network Connections:"
ss -tuln | head -10

# Process information
print_header "PROCESS INFORMATION"
echo "Top 10 CPU consuming processes:"
ps aux --sort=-%cpu | head -11
echo
echo "Top 10 Memory consuming processes:"
ps aux --sort=-%mem | head -11

# Service status (systemd)
print_header "SERVICE STATUS"
if command_exists systemctl; then
    echo "Failed services:"
    systemctl --failed --no-legend
    echo
    echo "Active services (first 10):"
    systemctl list-units --type=service --state=active --no-legend | head -10
fi

# Load average
print_header "SYSTEM LOAD"
echo "Load Average: $(cat /proc/loadavg)"
echo "CPU Count: $(nproc)"
load1=$(cat /proc/loadavg | awk '{print $1}')
cpu_count=$(nproc)
load_percentage=$(echo "scale=2; $load1 / $cpu_count * 100" | bc 2>/dev/null || echo "N/A")
echo "Load Percentage: ${load_percentage}%"

# Security information
print_header "SECURITY INFO"
echo "Last logins:"
last -n 5
echo
echo "Failed login attempts:"
if [ -f /var/log/auth.log ]; then
    grep "Failed password" /var/log/auth.log | tail -5 2>/dev/null || echo "No recent failed attempts"
elif [ -f /var/log/secure ]; then
    grep "Failed password" /var/log/secure | tail -5 2>/dev/null || echo "No recent failed attempts"
else
    echo "Auth log not accessible"
fi

# Docker information (if available)
if command_exists docker; then
    print_header "DOCKER INFORMATION"
    echo "Docker version: $(docker --version)"
    echo "Running containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
fi

# Summary
print_header "SUMMARY"
echo "System information collection completed at $(date)"
if [ -n "$output_file" ]; then
    echo "Report saved to: $output_file" >&2
fi
