#!/bin/bash

# Script: Conditional Statements
# Purpose: Learn if-else, case statements, and comparison operators
# Usage: ./04-conditionals.sh

echo "=== Conditional Statements Demo ==="

# Get user input
echo -n "Enter a number: "
read number

# Numeric comparisons
if [ $number -gt 10 ]; then
    echo "$number is greater than 10"
elif [ $number -eq 10 ]; then
    echo "$number is equal to 10"
else
    echo "$number is less than 10"
fi

# Check if number is even or odd
if [ $((number % 2)) -eq 0 ]; then
    echo "$number is even"
else
    echo "$number is odd"
fi

# String comparisons
echo -n "Enter your favorite programming language: "
read language

if [ "$language" = "bash" ] || [ "$language" = "Bash" ]; then
    echo "Great choice! Bash is powerful for automation."
elif [ "$language" = "python" ] || [ "$language" = "Python" ]; then
    echo "Python is excellent for many tasks!"
else
    echo "$language is a good choice too!"
fi

# Case statement
echo -n "Enter a day of the week: "
read day

case $day in
    "Monday"|"monday")
        echo "Start of the work week!"
        ;;
    "Tuesday"|"tuesday")
        echo "Tuesday blues..."
        ;;
    "Wednesday"|"wednesday")
        echo "Hump day!"
        ;;
    "Thursday"|"thursday")
        echo "Almost there!"
        ;;
    "Friday"|"friday")
        echo "TGIF!"
        ;;
    "Saturday"|"saturday"|"Sunday"|"sunday")
        echo "Weekend time!"
        ;;
    *)
        echo "That doesn't look like a valid day."
        ;;
esac

# File tests
filename="test.txt"
if [ -f "$filename" ]; then
    echo "$filename exists and is a regular file"
else
    echo "$filename does not exist"
fi

# Check if directory exists
if [ -d "/tmp" ]; then
    echo "/tmp directory exists"
fi
