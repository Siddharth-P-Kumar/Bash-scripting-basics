#!/bin/bash

# Script: Variables and Data Types
# Purpose: Learn about bash variables and basic data types
# Usage: ./02-variables.sh

echo "=== Bash Variables Demo ==="

# String variables
first_name="John"
last_name="Doe"
full_name="$first_name $last_name"

echo "First Name: $first_name"
echo "Last Name: $last_name"
echo "Full Name: $full_name"

# Numeric variables (bash treats everything as strings, but can do arithmetic)
age=25
birth_year=$((2024 - age))

echo "Age: $age"
echo "Birth Year: $birth_year"

# Environment variables
echo "Current User: $USER"
echo "Home Directory: $HOME"
echo "Current Path: $PWD"

# Command substitution
current_date=$(date)
file_count=$(ls | wc -l)

echo "Current Date: $current_date"
echo "Files in current directory: $file_count"

# Read-only variables
readonly PI=3.14159
echo "Value of PI: $PI"

# Arrays (basic)
fruits=("apple" "banana" "orange")
echo "First fruit: ${fruits[0]}"
echo "All fruits: ${fruits[@]}"
