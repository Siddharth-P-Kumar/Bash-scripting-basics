#!/bin/bash
file="/home/sidak/Desktop/scripts/geeks.txt"
if [ -e "$file" ]; then
    while IFS= read -r line; do
        echo "Line read: $line"
    done < "$file"
else
    echo "File not found"
fi
