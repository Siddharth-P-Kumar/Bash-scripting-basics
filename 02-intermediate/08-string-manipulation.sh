#!/bin/bash

# Script: String Manipulation
# Purpose: Learn string operations and text processing
# Usage: ./08-string-manipulation.sh

echo "=== String Manipulation Demo ==="

# Basic string operations
text="Hello World from Bash Scripting"
echo "Original text: $text"

# String length
echo "Length: ${#text}"

# Substring extraction
echo "First 5 characters: ${text:0:5}"
echo "Characters 6-10: ${text:6:5}"
echo "Last 10 characters: ${text: -10}"

# String replacement
echo "Replace 'World' with 'Universe': ${text/World/Universe}"
echo "Replace all 'a' with 'A': ${text//a/A}"

# Case conversion
echo "Uppercase: ${text^^}"
echo "Lowercase: ${text,,}"
echo "First letter uppercase: ${text^}"

# String concatenation
first_name="John"
last_name="Doe"
full_name="$first_name $last_name"
echo "Full name: $full_name"

# String comparison
string1="apple"
string2="banana"
if [[ "$string1" < "$string2" ]]; then
    echo "$string1 comes before $string2 alphabetically"
fi

# Check if string contains substring
email="user@example.com"
if [[ "$email" == *"@"* ]]; then
    echo "$email contains @ symbol"
fi

# String splitting
IFS=',' read -ra ADDR <<< "apple,banana,orange,grape"
echo "Fruits array:"
for fruit in "${ADDR[@]}"; do
    echo "  - $fruit"
done

# Remove leading/trailing whitespace
messy_string="   Hello World   "
clean_string=$(echo "$messy_string" | xargs)
echo "Original: '$messy_string'"
echo "Cleaned: '$clean_string'"

# Pattern matching
filename="document.pdf"
if [[ "$filename" == *.pdf ]]; then
    echo "$filename is a PDF file"
fi

# Extract file extension
extension="${filename##*.}"
echo "File extension: $extension"

# Extract filename without extension
basename="${filename%.*}"
echo "Filename without extension: $basename"

# Regular expressions with grep
echo -e "\nTesting email validation:"
emails=("valid@email.com" "invalid.email" "another@valid.org")
for email in "${emails[@]}"; do
    if echo "$email" | grep -qE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'; then
        echo "✓ $email is valid"
    else
        echo "✗ $email is invalid"
    fi
done

# String formatting
printf "Formatted output: %s is %d years old\n" "Alice" 25
printf "Decimal: %.2f\n" 3.14159
