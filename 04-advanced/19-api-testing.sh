#!/bin/bash

# Script: API Testing and Monitoring
# Purpose: Test REST APIs, monitor endpoints, and validate responses
# Usage: ./19-api-testing.sh [command] [options]

echo "=== API Testing and Monitoring ==="

# Configuration
CONFIG_FILE="$HOME/.api_config"
LOG_FILE="/tmp/api_testing.log"
TIMEOUT=30

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
    echo "  get <url>                 - GET request to URL"
    echo "  post <url> <data>         - POST request with data"
    echo "  put <url> <data>          - PUT request with data"
    echo "  delete <url>              - DELETE request to URL"
    echo "  test <config_file>        - Run test suite from config"
    echo "  monitor <url> [interval]  - Monitor endpoint continuously"
    echo "  benchmark <url> [count]   - Benchmark endpoint performance"
    echo "  validate <url> <schema>   - Validate response against schema"
    echo "  setup                     - Setup API configuration"
    exit 1
}

# Function to check if curl is available
check_curl() {
    if ! command -v curl >/dev/null 2>&1; then
        echo "Error: curl is not installed"
        echo "Please install curl first"
        exit 1
    fi
}

# Function to make HTTP request
make_request() {
    local method=$1
    local url=$2
    local data=$3
    local headers=$4
    
    local curl_cmd="curl -s -w '\n\nHTTP Status: %{http_code}\nTime: %{time_total}s\nSize: %{size_download} bytes\n'"
    curl_cmd="$curl_cmd --max-time $TIMEOUT"
    
    # Add headers if provided
    if [ -n "$headers" ]; then
        curl_cmd="$curl_cmd -H '$headers'"
    fi
    
    # Add method-specific options
    case $method in
        "GET")
            curl_cmd="$curl_cmd -X GET '$url'"
            ;;
        "POST")
            curl_cmd="$curl_cmd -X POST -H 'Content-Type: application/json' -d '$data' '$url'"
            ;;
        "PUT")
            curl_cmd="$curl_cmd -X PUT -H 'Content-Type: application/json' -d '$data' '$url'"
            ;;
        "DELETE")
            curl_cmd="$curl_cmd -X DELETE '$url'"
            ;;
    esac
    
    echo "Making $method request to: $url"
    echo "=================================="
    
    # Execute curl command
    eval $curl_cmd
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log_message "INFO" "$method request to $url successful"
    else
        log_message "ERROR" "$method request to $url failed (exit code: $exit_code)"
    fi
    
    return $exit_code
}

# Function for GET request
get_request() {
    local url=$1
    if [ -z "$url" ]; then
        echo "Error: URL required"
        return 1
    fi
    
    make_request "GET" "$url"
}

# Function for POST request
post_request() {
    local url=$1
    local data=$2
    
    if [ -z "$url" ]; then
        echo "Error: URL required"
        return 1
    fi
    
    if [ -z "$data" ]; then
        echo "Error: Data required for POST request"
        return 1
    fi
    
    make_request "POST" "$url" "$data"
}

# Function for PUT request
put_request() {
    local url=$1
    local data=$2
    
    if [ -z "$url" ]; then
        echo "Error: URL required"
        return 1
    fi
    
    if [ -z "$data" ]; then
        echo "Error: Data required for PUT request"
        return 1
    fi
    
    make_request "PUT" "$url" "$data"
}

# Function for DELETE request
delete_request() {
    local url=$1
    if [ -z "$url" ]; then
        echo "Error: URL required"
        return 1
    fi
    
    make_request "DELETE" "$url"
}

# Function to run test suite
run_test_suite() {
    local config_file=$1
    
    if [ -z "$config_file" ]; then
        echo "Error: Configuration file required"
        return 1
    fi
    
    if [ ! -f "$config_file" ]; then
        echo "Error: Configuration file not found: $config_file"
        return 1
    fi
    
    echo "Running API test suite from: $config_file"
    echo "=========================================="
    
    local test_count=0
    local passed_count=0
    local failed_count=0
    
    while IFS='|' read -r name method url expected_status data; do
        # Skip comments and empty lines
        [[ "$name" =~ ^#.*$ ]] && continue
        [[ -z "$name" ]] && continue
        
        test_count=$((test_count + 1))
        echo
        echo "Test $test_count: $name"
        echo "Method: $method, URL: $url, Expected: $expected_status"
        
        # Make request and capture status
        local response=$(make_request "$method" "$url" "$data" 2>&1)
        local actual_status=$(echo "$response" | grep "HTTP Status:" | awk '{print $3}')
        
        if [ "$actual_status" = "$expected_status" ]; then
            echo "✓ PASSED"
            passed_count=$((passed_count + 1))
            log_message "INFO" "Test '$name' PASSED"
        else
            echo "✗ FAILED (Expected: $expected_status, Got: $actual_status)"
            failed_count=$((failed_count + 1))
            log_message "ERROR" "Test '$name' FAILED"
        fi
    done < "$config_file"
    
    echo
    echo "Test Results:"
    echo "============="
    echo "Total tests: $test_count"
    echo "Passed: $passed_count"
    echo "Failed: $failed_count"
    echo "Success rate: $(( passed_count * 100 / test_count ))%"
}

# Function to monitor endpoint
monitor_endpoint() {
    local url=$1
    local interval=${2:-60}
    
    if [ -z "$url" ]; then
        echo "Error: URL required"
        return 1
    fi
    
    echo "Monitoring endpoint: $url (interval: ${interval}s)"
    echo "Press Ctrl+C to stop monitoring"
    echo "================================================"
    
    while true; do
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        local response=$(curl -s -w '%{http_code}|%{time_total}' --max-time $TIMEOUT "$url" -o /dev/null)
        local status_code=$(echo "$response" | cut -d'|' -f1)
        local response_time=$(echo "$response" | cut -d'|' -f2)
        
        if [ "$status_code" = "200" ]; then
            printf "[%s] ✓ Status: %s, Time: %ss\n" "$timestamp" "$status_code" "$response_time"
            log_message "INFO" "Monitor $url - Status: $status_code, Time: ${response_time}s"
        else
            printf "[%s] ✗ Status: %s, Time: %ss\n" "$timestamp" "$status_code" "$response_time"
            log_message "ERROR" "Monitor $url - Status: $status_code, Time: ${response_time}s"
        fi
        
        sleep "$interval"
    done
}

# Function to benchmark endpoint
benchmark_endpoint() {
    local url=$1
    local count=${2:-10}
    
    if [ -z "$url" ]; then
        echo "Error: URL required"
        return 1
    fi
    
    echo "Benchmarking endpoint: $url ($count requests)"
    echo "============================================="
    
    local total_time=0
    local success_count=0
    local min_time=999999
    local max_time=0
    
    for i in $(seq 1 $count); do
        echo -n "Request $i/$count... "
        
        local response=$(curl -s -w '%{http_code}|%{time_total}' --max-time $TIMEOUT "$url" -o /dev/null)
        local status_code=$(echo "$response" | cut -d'|' -f1)
        local response_time=$(echo "$response" | cut -d'|' -f2)
        
        if [ "$status_code" = "200" ]; then
            echo "✓ ${response_time}s"
            success_count=$((success_count + 1))
            total_time=$(echo "$total_time + $response_time" | bc)
            
            # Update min/max times
            if (( $(echo "$response_time < $min_time" | bc -l) )); then
                min_time=$response_time
            fi
            if (( $(echo "$response_time > $max_time" | bc -l) )); then
                max_time=$response_time
            fi
        else
            echo "✗ Status: $status_code"
        fi
    done
    
    echo
    echo "Benchmark Results:"
    echo "=================="
    echo "Total requests: $count"
    echo "Successful: $success_count"
    echo "Failed: $((count - success_count))"
    echo "Success rate: $(( success_count * 100 / count ))%"
    
    if [ $success_count -gt 0 ]; then
        local avg_time=$(echo "scale=3; $total_time / $success_count" | bc)
        echo "Average response time: ${avg_time}s"
        echo "Min response time: ${min_time}s"
        echo "Max response time: ${max_time}s"
    fi
}

# Function to validate response
validate_response() {
    local url=$1
    local schema_file=$2
    
    if [ -z "$url" ] || [ -z "$schema_file" ]; then
        echo "Error: URL and schema file required"
        return 1
    fi
    
    if [ ! -f "$schema_file" ]; then
        echo "Error: Schema file not found: $schema_file"
        return 1
    fi
    
    echo "Validating response from: $url"
    echo "Schema file: $schema_file"
    echo "=============================="
    
    # Get response
    local response=$(curl -s "$url")
    local status_code=$(curl -s -w '%{http_code}' -o /dev/null "$url")
    
    echo "HTTP Status: $status_code"
    echo "Response preview:"
    echo "$response" | head -10
    
    # Basic JSON validation
    if echo "$response" | python3 -m json.tool >/dev/null 2>&1; then
        echo "✓ Valid JSON response"
    else
        echo "✗ Invalid JSON response"
    fi
    
    # TODO: Add proper schema validation with tools like ajv-cli
    echo "Note: Full schema validation requires additional tools"
}

# Function to setup configuration
setup_config() {
    echo "API Testing Configuration Setup:"
    echo "================================"
    
    cat > "$CONFIG_FILE" << 'EOF'
# API Test Configuration
# Format: test_name|method|url|expected_status|data
# Lines starting with # are comments

# Example tests
Health Check|GET|https://httpbin.org/status/200|200|
Get User|GET|https://jsonplaceholder.typicode.com/users/1|200|
Create Post|POST|https://jsonplaceholder.typicode.com/posts|201|{"title":"Test","body":"Test body","userId":1}
Update Post|PUT|https://jsonplaceholder.typicode.com/posts/1|200|{"id":1,"title":"Updated","body":"Updated body","userId":1}
Delete Post|DELETE|https://jsonplaceholder.typicode.com/posts/1|200|
EOF
    
    echo "Configuration file created: $CONFIG_FILE"
    echo "Edit this file to add your own API tests"
}

# Function to create sample schema
create_sample_schema() {
    cat > "user_schema.json" << 'EOF'
{
  "type": "object",
  "properties": {
    "id": {"type": "integer"},
    "name": {"type": "string"},
    "email": {"type": "string", "format": "email"},
    "phone": {"type": "string"}
  },
  "required": ["id", "name", "email"]
}
EOF
    
    echo "Sample schema created: user_schema.json"
}

# Main script logic
check_curl

case "${1:-}" in
    "get")
        if [ -z "$2" ]; then
            echo "Error: URL required"
            usage
        fi
        get_request "$2"
        ;;
    "post")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Error: URL and data required"
            usage
        fi
        post_request "$2" "$3"
        ;;
    "put")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Error: URL and data required"
            usage
        fi
        put_request "$2" "$3"
        ;;
    "delete")
        if [ -z "$2" ]; then
            echo "Error: URL required"
            usage
        fi
        delete_request "$2"
        ;;
    "test")
        if [ -z "$2" ]; then
            echo "Error: Configuration file required"
            usage
        fi
        run_test_suite "$2"
        ;;
    "monitor")
        if [ -z "$2" ]; then
            echo "Error: URL required"
            usage
        fi
        monitor_endpoint "$2" "$3"
        ;;
    "benchmark")
        if [ -z "$2" ]; then
            echo "Error: URL required"
            usage
        fi
        benchmark_endpoint "$2" "$3"
        ;;
    "validate")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Error: URL and schema file required"
            usage
        fi
        validate_response "$2" "$3"
        ;;
    "setup")
        setup_config
        ;;
    "sample-schema")
        create_sample_schema
        ;;
    *)
        usage
        ;;
esac
