#!/bin/bash

# Script: Error Handling and Debugging
# Purpose: Learn error handling, debugging techniques, and best practices
# Usage: ./10-error-handling.sh

echo "=== Error Handling and Debugging Demo ==="

# Enable strict mode for better error handling
set -euo pipefail  # Exit on error, undefined variables, pipe failures

# Trap for cleanup on exit
cleanup() {
    echo "Cleaning up before exit..."
    # Add cleanup code here
}
trap cleanup EXIT

# Function to demonstrate error handling
divide_numbers() {
    local num1=$1
    local num2=$2
    
    # Check for division by zero
    if [ "$num2" -eq 0 ]; then
        echo "Error: Division by zero!" >&2
        return 1
    fi
    
    local result=$((num1 / num2))
    echo "Result: $num1 / $num2 = $result"
    return 0
}

# Function with error checking
safe_file_operation() {
    local filename=$1
    
    # Check if file exists
    if [ ! -f "$filename" ]; then
        echo "Error: File '$filename' does not exist!" >&2
        return 1
    fi
    
    # Check if file is readable
    if [ ! -r "$filename" ]; then
        echo "Error: File '$filename' is not readable!" >&2
        return 1
    fi
    
    echo "File '$filename' is accessible"
    return 0
}

# Demonstrate error handling
echo "1. Error Handling Examples:"

# Safe division
if divide_numbers 10 2; then
    echo "✓ Division successful"
else
    echo "✗ Division failed"
fi

# This will fail
if divide_numbers 10 0; then
    echo "✓ Division successful"
else
    echo "✗ Division failed with error code: $?"
fi

# File operation with error checking
echo -e "\n2. File Operation Error Handling:"
if safe_file_operation "/etc/passwd"; then
    echo "✓ File operation successful"
else
    echo "✗ File operation failed"
fi

if safe_file_operation "nonexistent_file.txt"; then
    echo "✓ File operation successful"
else
    echo "✗ File operation failed"
fi

# Debugging techniques
echo -e "\n3. Debugging Techniques:"

# Debug mode (uncomment to enable)
# set -x  # Enable debug mode

debug_function() {
    local var1="hello"
    local var2="world"
    echo "Debug: var1=$var1, var2=$var2"
    local result="$var1 $var2"
    echo "Debug: result=$result"
}

debug_function

# set +x  # Disable debug mode

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >&2
}

echo -e "\n4. Logging Examples:"
log "INFO" "This is an info message"
log "WARNING" "This is a warning message"
log "ERROR" "This is an error message"

# Error handling with custom exit codes
validate_input() {
    local input=$1
    
    if [ -z "$input" ]; then
        log "ERROR" "Input cannot be empty"
        return 10
    fi
    
    if [ ${#input} -lt 3 ]; then
        log "ERROR" "Input must be at least 3 characters"
        return 11
    fi
    
    if [[ ! "$input" =~ ^[a-zA-Z]+$ ]]; then
        log "ERROR" "Input must contain only letters"
        return 12
    fi
    
    log "INFO" "Input validation successful"
    return 0
}

echo -e "\n5. Input Validation:"
test_inputs=("" "ab" "123" "hello" "valid_input")

for input in "${test_inputs[@]}"; do
    echo "Testing input: '$input'"
    if validate_input "$input"; then
        echo "✓ Valid input"
    else
        case $? in
            10) echo "✗ Empty input error" ;;
            11) echo "✗ Too short error" ;;
            12) echo "✗ Invalid characters error" ;;
            *) echo "✗ Unknown error" ;;
        esac
    fi
    echo
done

# Temporary disable strict mode for demonstration
set +e

# Command that might fail
echo -e "\n6. Handling Command Failures:"
ls /nonexistent_directory 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Command failed, but script continues"
fi

# Re-enable strict mode
set -e

echo "Script completed successfully!"
