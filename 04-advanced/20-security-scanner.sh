#!/bin/bash

# Script: Security Scanner and Hardening
# Purpose: Basic security scanning and system hardening checks
# Usage: ./20-security-scanner.sh [command] [options]

echo "=== Security Scanner and Hardening ==="

# Configuration
LOG_FILE="/tmp/security_scan.log"
REPORT_FILE="/tmp/security_report_$(date +%Y%m%d_%H%M%S).txt"

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
    echo "  scan                      - Run comprehensive security scan"
    echo "  users                     - Check user accounts and permissions"
    echo "  network                   - Scan network security"
    echo "  files                     - Check file permissions and ownership"
    echo "  services                  - Audit running services"
    echo "  passwords                 - Check password policies"
    echo "  firewall                  - Check firewall status"
    echo "  updates                   - Check for security updates"
    echo "  harden                    - Apply basic hardening measures"
    echo "  report                    - Generate security report"
    exit 1
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Warning: Some checks require root privileges"
        echo "Run with sudo for complete scan"
        return 1
    fi
    return 0
}

# Function to scan user accounts
scan_users() {
    echo "User Account Security Scan:"
    echo "=========================="
    
    # Check for users with UID 0 (root privileges)
    echo "Users with root privileges (UID 0):"
    awk -F: '$3 == 0 {print $1}' /etc/passwd
    
    echo
    echo "Users with empty passwords:"
    awk -F: '$2 == "" {print $1}' /etc/shadow 2>/dev/null || echo "Cannot access /etc/shadow (need root)"
    
    echo
    echo "Users with shell access:"
    grep -E "/bin/(bash|sh|zsh|fish)" /etc/passwd | cut -d: -f1
    
    echo
    echo "Recently logged in users:"
    last -n 10 | head -10
    
    echo
    echo "Failed login attempts:"
    if [ -f /var/log/auth.log ]; then
        grep "Failed password" /var/log/auth.log | tail -5 2>/dev/null || echo "No recent failed attempts"
    elif [ -f /var/log/secure ]; then
        grep "Failed password" /var/log/secure | tail -5 2>/dev/null || echo "No recent failed attempts"
    else
        echo "Auth log not accessible"
    fi
    
    log_message "INFO" "User account scan completed"
}

# Function to scan network security
scan_network() {
    echo "Network Security Scan:"
    echo "====================="
    
    # Check open ports
    echo "Open network ports:"
    if command -v ss >/dev/null 2>&1; then
        ss -tuln | grep LISTEN
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tuln | grep LISTEN
    else
        echo "Neither ss nor netstat available"
    fi
    
    echo
    echo "Network interfaces:"
    ip addr show 2>/dev/null || ifconfig -a 2>/dev/null || echo "Cannot get network interfaces"
    
    echo
    echo "Routing table:"
    ip route show 2>/dev/null || route -n 2>/dev/null || echo "Cannot get routing table"
    
    echo
    echo "Active network connections:"
    ss -tuln 2>/dev/null | head -10 || netstat -tuln 2>/dev/null | head -10 || echo "Cannot get connections"
    
    log_message "INFO" "Network security scan completed"
}

# Function to check file permissions
scan_files() {
    echo "File Permission Security Scan:"
    echo "============================="
    
    # Check for world-writable files
    echo "World-writable files (first 10):"
    find / -type f -perm -002 2>/dev/null | head -10
    
    echo
    echo "SUID files (first 10):"
    find / -type f -perm -4000 2>/dev/null | head -10
    
    echo
    echo "SGID files (first 10):"
    find / -type f -perm -2000 2>/dev/null | head -10
    
    echo
    echo "Files without owner (first 10):"
    find / -nouser 2>/dev/null | head -10
    
    echo
    echo "Files without group (first 10):"
    find / -nogroup 2>/dev/null | head -10
    
    echo
    echo "Critical file permissions:"
    ls -l /etc/passwd /etc/shadow /etc/group 2>/dev/null || echo "Cannot access critical files"
    
    log_message "INFO" "File permission scan completed"
}

# Function to audit services
scan_services() {
    echo "Service Security Audit:"
    echo "======================"
    
    # Check running services
    echo "Running services:"
    if command -v systemctl >/dev/null 2>&1; then
        systemctl list-units --type=service --state=active --no-legend | head -15
    else
        ps aux | grep -E "(sshd|httpd|nginx|mysql|postgres)" | grep -v grep
    fi
    
    echo
    echo "Services listening on network:"
    ss -tlnp 2>/dev/null | head -10 || netstat -tlnp 2>/dev/null | head -10 || echo "Cannot get listening services"
    
    echo
    echo "Cron jobs:"
    echo "System cron:"
    ls -la /etc/cron* 2>/dev/null | head -10
    echo "User cron jobs:"
    crontab -l 2>/dev/null || echo "No user cron jobs"
    
    log_message "INFO" "Service audit completed"
}

# Function to check password policies
scan_passwords() {
    echo "Password Policy Check:"
    echo "====================="
    
    # Check password aging
    echo "Password aging settings:"
    grep -E "^(PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE)" /etc/login.defs 2>/dev/null || echo "Cannot access login.defs"
    
    echo
    echo "Account lockout settings:"
    if [ -f /etc/pam.d/common-auth ]; then
        grep "pam_tally" /etc/pam.d/common-auth 2>/dev/null || echo "No account lockout configured"
    fi
    
    echo
    echo "Password complexity requirements:"
    if [ -f /etc/pam.d/common-password ]; then
        grep "pam_pwquality\|pam_cracklib" /etc/pam.d/common-password 2>/dev/null || echo "No password complexity rules found"
    fi
    
    log_message "INFO" "Password policy check completed"
}

# Function to check firewall status
scan_firewall() {
    echo "Firewall Security Check:"
    echo "======================="
    
    # Check iptables
    if command -v iptables >/dev/null 2>&1; then
        echo "iptables rules:"
        iptables -L -n 2>/dev/null || echo "Cannot access iptables (need root)"
    fi
    
    echo
    # Check ufw
    if command -v ufw >/dev/null 2>&1; then
        echo "UFW status:"
        ufw status 2>/dev/null || echo "Cannot access UFW status"
    fi
    
    echo
    # Check firewalld
    if command -v firewall-cmd >/dev/null 2>&1; then
        echo "firewalld status:"
        firewall-cmd --state 2>/dev/null || echo "firewalld not running"
    fi
    
    log_message "INFO" "Firewall check completed"
}

# Function to check for updates
scan_updates() {
    echo "Security Updates Check:"
    echo "======================"
    
    # Check for available updates
    if command -v apt >/dev/null 2>&1; then
        echo "Debian/Ubuntu updates:"
        apt list --upgradable 2>/dev/null | head -10 || echo "Cannot check updates (need root)"
    elif command -v yum >/dev/null 2>&1; then
        echo "RedHat/CentOS updates:"
        yum check-update 2>/dev/null | head -10 || echo "Cannot check updates (need root)"
    elif command -v dnf >/dev/null 2>&1; then
        echo "Fedora updates:"
        dnf check-update 2>/dev/null | head -10 || echo "Cannot check updates (need root)"
    else
        echo "Package manager not recognized"
    fi
    
    echo
    echo "Kernel version:"
    uname -r
    echo "Latest available kernel:"
    if command -v apt >/dev/null 2>&1; then
        apt list linux-image-* 2>/dev/null | grep -E "linux-image-[0-9]" | head -3 || echo "Cannot check kernel versions"
    fi
    
    log_message "INFO" "Updates check completed"
}

# Function to apply basic hardening
apply_hardening() {
    echo "Basic System Hardening:"
    echo "======================"
    
    if ! check_root; then
        echo "Root privileges required for hardening"
        return 1
    fi
    
    echo "Applying basic hardening measures..."
    
    # Disable unused network services
    echo "Checking for unused services..."
    services_to_disable=("telnet" "rsh" "rlogin")
    for service in "${services_to_disable[@]}"; do
        if systemctl is-enabled "$service" 2>/dev/null | grep -q enabled; then
            echo "Disabling $service..."
            systemctl disable "$service"
        fi
    done
    
    # Set secure permissions on critical files
    echo "Setting secure permissions..."
    chmod 644 /etc/passwd
    chmod 600 /etc/shadow
    chmod 644 /etc/group
    
    # Configure automatic updates (Ubuntu/Debian)
    if command -v apt >/dev/null 2>&1; then
        echo "Configuring automatic security updates..."
        apt update && apt install -y unattended-upgrades
        dpkg-reconfigure -plow unattended-upgrades
    fi
    
    # Basic firewall setup
    if command -v ufw >/dev/null 2>&1; then
        echo "Configuring basic firewall..."
        ufw --force enable
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow ssh
    fi
    
    log_message "INFO" "Basic hardening applied"
    echo "Hardening completed. Review changes and test system functionality."
}

# Function to run comprehensive scan
run_comprehensive_scan() {
    echo "Comprehensive Security Scan:"
    echo "==========================="
    echo "Scan started at: $(date)"
    echo
    
    scan_users
    echo
    scan_network
    echo
    scan_files
    echo
    scan_services
    echo
    scan_passwords
    echo
    scan_firewall
    echo
    scan_updates
    
    echo
    echo "Comprehensive scan completed at: $(date)"
    log_message "INFO" "Comprehensive security scan completed"
}

# Function to generate security report
generate_report() {
    echo "Generating Security Report..."
    echo "============================="
    
    {
        echo "Security Scan Report"
        echo "==================="
        echo "Generated: $(date)"
        echo "Hostname: $(hostname)"
        echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || uname -s)"
        echo
        
        run_comprehensive_scan
        
    } > "$REPORT_FILE"
    
    echo "Security report generated: $REPORT_FILE"
    echo "Report size: $(du -h "$REPORT_FILE" | cut -f1)"
}

# Main script logic
case "${1:-}" in
    "scan")
        run_comprehensive_scan
        ;;
    "users")
        scan_users
        ;;
    "network")
        scan_network
        ;;
    "files")
        scan_files
        ;;
    "services")
        scan_services
        ;;
    "passwords")
        scan_passwords
        ;;
    "firewall")
        scan_firewall
        ;;
    "updates")
        scan_updates
        ;;
    "harden")
        apply_hardening
        ;;
    "report")
        generate_report
        ;;
    *)
        usage
        ;;
esac
