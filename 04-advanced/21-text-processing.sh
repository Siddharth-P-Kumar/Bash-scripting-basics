#!/bin/bash

# Script: Text Processing and Parsing
# Purpose: Advanced text processing, parsing, and data extraction
# Usage: ./21-text-processing.sh [command] [options]

echo "=== Text Processing and Parsing ==="

# Function to display usage
usage() {
    echo "Usage: $0 [command] [options]"
    echo "Commands:"
    echo "  csv <file>                - Parse CSV file"
    echo "  json <file>               - Parse JSON file"
    echo "  log <file> <pattern>      - Extract log patterns"
    echo "  extract <file> <regex>    - Extract using regex"
    echo "  format <file>             - Format and clean text"
    echo "  stats <file>              - Text statistics"
    exit 1
}

# Function to parse CSV
parse_csv() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file"
        return 1
    fi
    
    echo "CSV Analysis for: $file"
    echo "======================="
    
    # Show first few lines
    echo "First 5 rows:"
    head -5 "$file"
    
    echo
    echo "Column count: $(head -1 "$file" | tr ',' '\n' | wc -l)"
    echo "Row count: $(wc -l < "$file")"
    
    # Extract specific columns
    echo
    echo "First column values (first 10):"
    cut -d',' -f1 "$file" | head -10
}

# Function to parse JSON (basic)
parse_json() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file"
        return 1
    fi
    
    echo "JSON Analysis for: $file"
    echo "========================"
    
    # Validate JSON
    if python3 -m json.tool "$file" >/dev/null 2>&1; then
        echo "✓ Valid JSON"
        echo "Formatted JSON (first 20 lines):"
        python3 -m json.tool "$file" | head -20
    else
        echo "✗ Invalid JSON"
    fi
}

# Function to extract log patterns
extract_log_patterns() {
    local file=$1
    local pattern=$2
    
    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file"
        return 1
    fi
    
    echo "Log Pattern Extraction:"
    echo "======================"
    echo "File: $file"
    echo "Pattern: $pattern"
    echo
    
    # Extract matching lines
    grep -E "$pattern" "$file" | head -20
    
    echo
    echo "Pattern count: $(grep -cE "$pattern" "$file")"
}

# Function to show text statistics
show_text_stats() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file"
        return 1
    fi
    
    echo "Text Statistics for: $file"
    echo "=========================="
    
    echo "Lines: $(wc -l < "$file")"
    echo "Words: $(wc -w < "$file")"
    echo "Characters: $(wc -c < "$file")"
    echo "File size: $(du -h "$file" | cut -f1)"
    
    echo
    echo "Most common words (top 10):"
    tr '[:space:]' '\n' < "$file" | tr '[:upper:]' '[:lower:]' | grep -v '^$' | sort | uniq -c | sort -nr | head -10
}

# Main logic
case "${1:-}" in
    "csv")
        if [ -z "$2" ]; then
            echo "Error: CSV file required"
            usage
        fi
        parse_csv "$2"
        ;;
    "json")
        if [ -z "$2" ]; then
            echo "Error: JSON file required"
            usage
        fi
        parse_json "$2"
        ;;
    "log")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Error: Log file and pattern required"
            usage
        fi
        extract_log_patterns "$2" "$3"
        ;;
    "stats")
        if [ -z "$2" ]; then
            echo "Error: Text file required"
            usage
        fi
        show_text_stats "$2"
        ;;
    *)
        usage
        ;;
esac
