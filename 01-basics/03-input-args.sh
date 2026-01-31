#!/bin/bash

# Script: User Input and Command Line Arguments
# Purpose: Learn how to handle user input and command line parameters
# Usage: ./03-input-args.sh arg1 arg2 arg3

echo "=== User Input and Arguments Demo ==="

# Command line arguments
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"

# Check if arguments were provided
if [ $# -eq 0 ]; then
    echo "No arguments provided!"
    echo "Usage: $0 <arg1> <arg2> ..."
else
    echo "You provided $# arguments"
fi

# Interactive input
echo -n "Enter your name: "
read name

echo -n "Enter your age: "
read age

echo -n "Enter your favorite color: "
read color

echo "Hello $name! You are $age years old and your favorite color is $color."

# Silent input (for passwords)
echo -n "Enter a password (won't be displayed): "
read -s password
echo
echo "Password entered (length: ${#password} characters)"

# Input with timeout
echo "You have 5 seconds to enter something:"
if read -t 5 response; then
    echo "You entered: $response"
else
    echo "Time's up! No input received."
fi
