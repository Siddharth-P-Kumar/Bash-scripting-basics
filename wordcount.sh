#!/bin/bash
echo "Enter the target word"
read target_word
echo "Enter the file name"
read filename
count=$(grep -o -w "$target_word" "$filename" | wc -l)
echo "The word '$target_word' appears '$count' times in '$filename'"
