# Bash Scripts Collection

A collection of useful bash scripts for learning and automation tasks.

## Scripts Overview

### Mathematical Operations
- **factorial.sh** - Calculates factorial of a given number
- **sumofnumbers.sh** - Calculates sum of integers from 1 to N

### File Operations
- **readlines.sh** - Reads and displays lines from geeks.txt file
- **wordcount.sh** - Counts occurrences of a specific word in a file

### Control Flow Examples
- **loop.sh** - Demonstrates iteration through an array of fruits

### Sample Data
- **geeks.txt** - Sample text file used by readlines.sh

## Usage

Make scripts executable:
```bash
chmod +x *.sh
```

Run any script:
```bash
./script_name.sh
```

## Examples

```bash
# Calculate factorial
./factorial.sh
# Enter: 5
# Output: The factorial of the number is 120

# Count word occurrences
./wordcount.sh
# Enter target word: geeks
# Enter filename: geeks.txt
# Output: The word 'geeks' appears '4' times in 'geeks.txt'

# Sum numbers 1 to N
./sumofnumbers.sh
# Enter: 10
# Output: Sum of integers from 1 to 10 is 55
```

## Additional Scripts

The `1/` directory contains basic bash scripting examples covering fundamentals like variables, comments, file operations, and command-line arguments.
