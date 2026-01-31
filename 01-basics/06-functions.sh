#!/bin/bash

# Script: Functions in Bash
# Purpose: Learn how to create and use functions
# Usage: ./06-functions.sh

echo "=== Functions Demo ==="

# Simple function
greet() {
    echo "Hello from a function!"
}

# Function with parameters
greet_user() {
    local name=$1
    local age=$2
    echo "Hello $name! You are $age years old."
}

# Function with return value
add_numbers() {
    local num1=$1
    local num2=$2
    local result=$((num1 + num2))
    echo $result  # Return value via echo
}

# Function that returns exit status
is_even() {
    local number=$1
    if [ $((number % 2)) -eq 0 ]; then
        return 0  # True (even)
    else
        return 1  # False (odd)
    fi
}

# Function with local variables
calculate_area() {
    local length=$1
    local width=$2
    local area=$((length * width))
    echo "Area of rectangle ($length x $width) = $area"
}

# Recursive function
factorial() {
    local n=$1
    if [ $n -le 1 ]; then
        echo 1
    else
        local prev=$(factorial $((n - 1)))
        echo $((n * prev))
    fi
}

# Using the functions
echo "1. Simple function call:"
greet

echo -e "\n2. Function with parameters:"
greet_user "Alice" 25

echo -e "\n3. Function with return value:"
result=$(add_numbers 15 25)
echo "15 + 25 = $result"

echo -e "\n4. Function with exit status:"
test_number=8
if is_even $test_number; then
    echo "$test_number is even"
else
    echo "$test_number is odd"
fi

echo -e "\n5. Function with local variables:"
calculate_area 5 10

echo -e "\n6. Recursive function:"
echo "Factorial of 5 = $(factorial 5)"

# Function that processes arrays
process_array() {
    local arr=("$@")  # All arguments as array
    echo "Processing array with ${#arr[@]} elements:"
    for element in "${arr[@]}"; do
        echo "  - $element"
    done
}

echo -e "\n7. Function processing array:"
my_array=("apple" "banana" "cherry")
process_array "${my_array[@]}"
