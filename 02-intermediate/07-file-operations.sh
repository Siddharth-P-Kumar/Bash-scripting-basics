#!/bin/bash

# Script: File Operations
# Purpose: Learn file and directory operations
# Usage: ./07-file-operations.sh

echo "=== File Operations Demo ==="

# Create a test directory
test_dir="test_files"
echo "Creating test directory: $test_dir"
mkdir -p "$test_dir"

# Create test files
echo "Creating test files..."
echo "This is file 1" > "$test_dir/file1.txt"
echo "This is file 2" > "$test_dir/file2.txt"
echo "This is a log entry" > "$test_dir/app.log"

# Check if file exists
filename="$test_dir/file1.txt"
if [ -f "$filename" ]; then
    echo "✓ $filename exists"
    echo "File size: $(stat -c%s "$filename") bytes"
    echo "File permissions: $(stat -c%A "$filename")"
fi

# Read file content
echo -e "\nReading file content:"
while IFS= read -r line; do
    echo "Line: $line"
done < "$filename"

# Copy files
echo -e "\nCopying files..."
cp "$test_dir/file1.txt" "$test_dir/file1_backup.txt"
echo "✓ Created backup of file1.txt"

# Move/rename files
mv "$test_dir/file2.txt" "$test_dir/renamed_file2.txt"
echo "✓ Renamed file2.txt to renamed_file2.txt"

# Find files
echo -e "\nFinding .txt files:"
find "$test_dir" -name "*.txt" -type f

# Count lines, words, characters
echo -e "\nFile statistics:"
wc "$test_dir/file1.txt"

# Search in files
echo -e "\nSearching for 'file' in all files:"
grep -r "file" "$test_dir/"

# File permissions
echo -e "\nChanging file permissions:"
chmod 755 "$test_dir/file1.txt"
echo "✓ Changed permissions of file1.txt to 755"

# Directory operations
echo -e "\nDirectory information:"
echo "Current directory: $(pwd)"
echo "Directory size: $(du -sh "$test_dir")"
echo "Files in test directory:"
ls -la "$test_dir"

# Archive files
echo -e "\nCreating archive:"
tar -czf "$test_dir.tar.gz" "$test_dir"
echo "✓ Created archive: $test_dir.tar.gz"

# Cleanup function
cleanup() {
    echo -e "\nCleaning up test files..."
    rm -rf "$test_dir"
    rm -f "$test_dir.tar.gz"
    echo "✓ Cleanup completed"
}

# Ask user if they want to cleanup
echo -e "\nDo you want to cleanup test files? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    cleanup
else
    echo "Test files kept in $test_dir"
fi
