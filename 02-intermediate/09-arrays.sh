#!/bin/bash

# Script: Arrays and Data Structures
# Purpose: Learn array operations and basic data structures
# Usage: ./09-arrays.sh

echo "=== Arrays and Data Structures Demo ==="

# Indexed arrays
echo "1. Indexed Arrays:"
fruits=("apple" "banana" "orange" "grape")
echo "All fruits: ${fruits[@]}"
echo "First fruit: ${fruits[0]}"
echo "Last fruit: ${fruits[-1]}"
echo "Array length: ${#fruits[@]}"

# Adding elements
fruits+=("mango")
echo "After adding mango: ${fruits[@]}"

# Removing elements
unset fruits[1]  # Remove banana
echo "After removing banana: ${fruits[@]}"

# Array slicing
echo "Fruits 1-2: ${fruits[@]:1:2}"

# Looping through arrays
echo -e "\nLooping through fruits:"
for i in "${!fruits[@]}"; do
    echo "Index $i: ${fruits[i]}"
done

# Associative arrays (like dictionaries/hash maps)
echo -e "\n2. Associative Arrays:"
declare -A person
person["name"]="John Doe"
person["age"]=30
person["city"]="New York"
person["job"]="Developer"

echo "Person details:"
for key in "${!person[@]}"; do
    echo "$key: ${person[$key]}"
done

# Multi-dimensional array simulation
echo -e "\n3. Multi-dimensional Arrays (simulated):"
declare -A matrix
matrix["0,0"]=1
matrix["0,1"]=2
matrix["1,0"]=3
matrix["1,1"]=4

echo "2x2 Matrix:"
for i in {0..1}; do
    for j in {0..1}; do
        echo -n "${matrix[$i,$j]} "
    done
    echo
done

# Array operations
echo -e "\n4. Array Operations:"
numbers=(5 2 8 1 9 3)
echo "Original numbers: ${numbers[@]}"

# Find maximum
max=${numbers[0]}
for num in "${numbers[@]}"; do
    if [ $num -gt $max ]; then
        max=$num
    fi
done
echo "Maximum: $max"

# Sort array (using external sort)
IFS=$'\n' sorted=($(sort -n <<<"${numbers[*]}"))
echo "Sorted numbers: ${sorted[@]}"

# Array as function parameter
process_array() {
    local arr=("$@")
    local sum=0
    echo "Processing array: ${arr[@]}"
    for num in "${arr[@]}"; do
        sum=$((sum + num))
    done
    echo "Sum: $sum"
    echo "Average: $((sum / ${#arr[@]}))"
}

echo -e "\n5. Array Processing:"
process_array "${numbers[@]}"

# Reading array from file
echo -e "\n6. Reading Array from Input:"
echo "Enter 3 colors (press Enter after each):"
colors=()
for i in {1..3}; do
    echo -n "Color $i: "
    read color
    colors+=("$color")
done
echo "Your colors: ${colors[@]}"

# Stack implementation
echo -e "\n7. Stack Implementation:"
stack=()

push() {
    stack+=("$1")
    echo "Pushed: $1"
}

pop() {
    if [ ${#stack[@]} -eq 0 ]; then
        echo "Stack is empty"
        return 1
    fi
    local item=${stack[-1]}
    unset stack[-1]
    echo "Popped: $item"
}

push "first"
push "second"
push "third"
echo "Stack: ${stack[@]}"
pop
pop
echo "Stack after pops: ${stack[@]}"
