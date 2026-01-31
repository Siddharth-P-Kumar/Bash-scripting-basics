#!/bin/bash

# Script: Loops in Bash
# Purpose: Learn for, while, and until loops
# Usage: ./05-loops.sh

echo "=== Loops Demo ==="

# For loop with range
echo "Counting from 1 to 5:"
for i in {1..5}; do
    echo "Count: $i"
done

# For loop with array
echo -e "\nFruits in my basket:"
fruits=("apple" "banana" "orange" "grape")
for fruit in "${fruits[@]}"; do
    echo "- $fruit"
done

# For loop with command output
echo -e "\nFiles in current directory:"
for file in *; do
    if [ -f "$file" ]; then
        echo "File: $file"
    fi
done

# C-style for loop
echo -e "\nC-style loop (0 to 4):"
for ((i=0; i<5; i++)); do
    echo "Index: $i"
done

# While loop
echo -e "\nWhile loop countdown:"
counter=5
while [ $counter -gt 0 ]; do
    echo "Countdown: $counter"
    counter=$((counter - 1))
    sleep 1
done
echo "Blast off!"

# Until loop
echo -e "\nUntil loop (count up to 3):"
num=1
until [ $num -gt 3 ]; do
    echo "Number: $num"
    num=$((num + 1))
done

# Reading file line by line
echo -e "\nReading /etc/passwd (first 5 lines):"
line_count=0
while IFS= read -r line && [ $line_count -lt 5 ]; do
    echo "Line $((line_count + 1)): $line"
    line_count=$((line_count + 1))
done < /etc/passwd

# Infinite loop with break
echo -e "\nInfinite loop with break:"
counter=1
while true; do
    echo "Loop iteration: $counter"
    if [ $counter -eq 3 ]; then
        echo "Breaking out of loop"
        break
    fi
    counter=$((counter + 1))
done
