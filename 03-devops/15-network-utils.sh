#!/bin/bash

# Script: Network Utilities and Monitoring
# Purpose: Network diagnostics, monitoring, and troubleshooting tools
# Usage: ./15-network-utils.sh [command] [options]

echo "=== Network Utilities and Monitoring ==="

# Configuration
PING_COUNT=4
TIMEOUT=5
LOG_FILE="/tmp/network_monitor.log"

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
    echo "  info                      - Show network interface information"
    echo "  ping <host>               - Ping host with detailed output"
    echo "  scan <network>            - Scan network for active hosts"
    echo "  ports <host>              - Scan common ports on host"
    echo "  connections               - Show active network connections"
    echo "  bandwidth                 - Monitor network bandwidth"
    echo "  dns <domain>              - DNS lookup and diagnostics"
    echo "  route                     - Show routing table"
    echo "  monitor                   - Continuous network monitoring"
    exit 1
}

# Function to show network interface information
show_network_info() {
    echo "Network Interface Information:"
    echo "============================="
    
    # Show all interfaces
    if command -v ip >/dev/null 2>&1; then
        echo "Network Interfaces (ip command):"
        ip addr show
        echo
        echo "Routing Table:"
        ip route show
    else
        echo "Network Interfaces (ifconfig):"
        ifconfig -a 2>/dev/null || echo "ifconfig not available"
    fi
    
    echo
    echo "Network Statistics:"
    cat /proc/net/dev | head -2
    cat /proc/net/dev | grep -E "(eth|wlan|enp|wlp)" | head -5
    
    echo
    echo "DNS Configuration:"
    if [ -f /etc/resolv.conf ]; then
        cat /etc/resolv.conf
    else
        echo "DNS configuration not found"
    fi
}

# Function to ping host with detailed analysis
ping_host() {
    local host=$1
    if [ -z "$host" ]; then
        echo "Error: Host required"
        return 1
    fi
    
    echo "Pinging $host..."
    echo "================"
    
    # Basic ping
    if ping -c $PING_COUNT -W $TIMEOUT "$host" > /tmp/ping_result.txt 2>&1; then
        cat /tmp/ping_result.txt
        
        # Extract statistics
        local avg_time=$(grep "avg" /tmp/ping_result.txt | awk -F'/' '{print $5}')
        local packet_loss=$(grep "packet loss" /tmp/ping_result.txt | awk '{print $6}')
        
        echo
        echo "Summary:"
        echo "Average response time: ${avg_time}ms"
        echo "Packet loss: $packet_loss"
        
        log_message "INFO" "Ping to $host successful - Avg: ${avg_time}ms, Loss: $packet_loss"
    else
        echo "Ping to $host failed"
        log_message "ERROR" "Ping to $host failed"
    fi
    
    rm -f /tmp/ping_result.txt
}

# Function to scan network for active hosts
scan_network() {
    local network=$1
    if [ -z "$network" ]; then
        # Try to detect local network
        network=$(ip route | grep -E "192\.168\.|10\.|172\." | head -1 | awk '{print $1}' | head -1)
        if [ -z "$network" ]; then
            echo "Error: Network required (e.g., 192.168.1.0/24)"
            return 1
        fi
        echo "Auto-detected network: $network"
    fi
    
    echo "Scanning network: $network"
    echo "========================="
    
    # Extract base IP and range
    local base_ip=$(echo $network | cut -d'/' -f1 | cut -d'.' -f1-3)
    local range_start=1
    local range_end=254
    
    echo "Active hosts:"
    local count=0
    
    for i in $(seq $range_start $range_end); do
        local ip="$base_ip.$i"
        if ping -c 1 -W 1 "$ip" >/dev/null 2>&1; then
            echo "✓ $ip is active"
            
            # Try to get hostname
            local hostname=$(nslookup "$ip" 2>/dev/null | grep "name =" | awk '{print $4}' | sed 's/\.$//')
            if [ -n "$hostname" ]; then
                echo "  Hostname: $hostname"
            fi
            
            count=$((count + 1))
        fi
    done
    
    echo
    echo "Scan completed. Found $count active hosts."
}

# Function to scan common ports
scan_ports() {
    local host=$1
    if [ -z "$host" ]; then
        echo "Error: Host required"
        return 1
    fi
    
    echo "Scanning common ports on $host..."
    echo "================================="
    
    # Common ports to scan
    local ports=(22 23 25 53 80 110 143 443 993 995 3389 5432 3306)
    
    for port in "${ports[@]}"; do
        if timeout 3 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
            echo "✓ Port $port is open"
            
            # Identify service
            case $port in
                22) echo "  Service: SSH" ;;
                23) echo "  Service: Telnet" ;;
                25) echo "  Service: SMTP" ;;
                53) echo "  Service: DNS" ;;
                80) echo "  Service: HTTP" ;;
                110) echo "  Service: POP3" ;;
                143) echo "  Service: IMAP" ;;
                443) echo "  Service: HTTPS" ;;
                993) echo "  Service: IMAPS" ;;
                995) echo "  Service: POP3S" ;;
                3389) echo "  Service: RDP" ;;
                5432) echo "  Service: PostgreSQL" ;;
                3306) echo "  Service: MySQL" ;;
            esac
        else
            echo "✗ Port $port is closed"
        fi
    done
}

# Function to show active connections
show_connections() {
    echo "Active Network Connections:"
    echo "=========================="
    
    echo "TCP Connections:"
    ss -tuln | grep tcp
    
    echo
    echo "UDP Connections:"
    ss -tuln | grep udp
    
    echo
    echo "Established Connections:"
    ss -tu | grep ESTAB | head -10
    
    echo
    echo "Listening Services:"
    ss -tlnp | head -10
}

# Function to monitor bandwidth
monitor_bandwidth() {
    local interface=${1:-$(ip route | grep default | awk '{print $5}' | head -1)}
    
    if [ -z "$interface" ]; then
        echo "Error: No network interface specified or detected"
        return 1
    fi
    
    echo "Monitoring bandwidth on interface: $interface"
    echo "Press Ctrl+C to stop"
    echo "============================================="
    
    # Get initial values
    local rx_bytes_old=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
    local tx_bytes_old=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)
    
    while true; do
        sleep 1
        
        local rx_bytes_new=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
        local tx_bytes_new=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)
        
        local rx_rate=$((rx_bytes_new - rx_bytes_old))
        local tx_rate=$((tx_bytes_new - tx_bytes_old))
        
        # Convert to human readable
        local rx_rate_mb=$(echo "scale=2; $rx_rate / 1024 / 1024" | bc 2>/dev/null || echo "0")
        local tx_rate_mb=$(echo "scale=2; $tx_rate / 1024 / 1024" | bc 2>/dev/null || echo "0")
        
        printf "\r[%s] RX: %8.2f MB/s  TX: %8.2f MB/s" "$(date '+%H:%M:%S')" "$rx_rate_mb" "$tx_rate_mb"
        
        rx_bytes_old=$rx_bytes_new
        tx_bytes_old=$tx_bytes_new
    done
}

# Function for DNS diagnostics
dns_lookup() {
    local domain=$1
    if [ -z "$domain" ]; then
        echo "Error: Domain required"
        return 1
    fi
    
    echo "DNS Diagnostics for: $domain"
    echo "============================"
    
    # Basic DNS lookup
    echo "A Record:"
    nslookup "$domain" 2>/dev/null | grep -A2 "Name:" || echo "No A record found"
    
    echo
    echo "MX Records:"
    nslookup -type=MX "$domain" 2>/dev/null | grep "mail exchanger" || echo "No MX records found"
    
    echo
    echo "NS Records:"
    nslookup -type=NS "$domain" 2>/dev/null | grep "nameserver" || echo "No NS records found"
    
    # Test DNS resolution time
    echo
    echo "DNS Resolution Time:"
    time nslookup "$domain" >/dev/null 2>&1
}

# Function to show routing information
show_routing() {
    echo "Routing Information:"
    echo "==================="
    
    if command -v ip >/dev/null 2>&1; then
        echo "Routing Table (ip route):"
        ip route show
        
        echo
        echo "Default Gateway:"
        ip route | grep default
    else
        echo "Routing Table (route):"
        route -n 2>/dev/null || echo "Route command not available"
    fi
    
    echo
    echo "ARP Table:"
    arp -a 2>/dev/null | head -10 || echo "ARP table not available"
}

# Function for continuous network monitoring
monitor_network() {
    echo "Continuous Network Monitor (Press Ctrl+C to stop)"
    echo "================================================"
    
    while true; do
        clear
        echo "Network Monitor - $(date)"
        echo "========================"
        
        # Interface status
        echo "Interface Status:"
        ip link show | grep -E "^[0-9]+" | awk '{print $2, $9}'
        
        echo
        # Active connections count
        echo "Connection Summary:"
        echo "TCP Established: $(ss -t | grep ESTAB | wc -l)"
        echo "TCP Listening: $(ss -tl | wc -l)"
        echo "UDP Sockets: $(ss -u | wc -l)"
        
        echo
        # Quick connectivity test
        echo "Connectivity Test:"
        if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
            echo "✓ Internet connectivity: OK"
        else
            echo "✗ Internet connectivity: FAILED"
        fi
        
        if ping -c 1 -W 2 $(ip route | grep default | awk '{print $3}' | head -1) >/dev/null 2>&1; then
            echo "✓ Gateway connectivity: OK"
        else
            echo "✗ Gateway connectivity: FAILED"
        fi
        
        sleep 5
    done
}

# Main script logic
case "${1:-}" in
    "info")
        show_network_info
        ;;
    "ping")
        if [ -z "$2" ]; then
            echo "Error: Host required"
            usage
        fi
        ping_host "$2"
        ;;
    "scan")
        scan_network "$2"
        ;;
    "ports")
        if [ -z "$2" ]; then
            echo "Error: Host required"
            usage
        fi
        scan_ports "$2"
        ;;
    "connections")
        show_connections
        ;;
    "bandwidth")
        monitor_bandwidth "$2"
        ;;
    "dns")
        if [ -z "$2" ]; then
            echo "Error: Domain required"
            usage
        fi
        dns_lookup "$2"
        ;;
    "route")
        show_routing
        ;;
    "monitor")
        monitor_network
        ;;
    *)
        usage
        ;;
esac
