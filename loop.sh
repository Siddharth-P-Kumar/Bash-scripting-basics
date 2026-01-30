#Loop to iterate through a list of values
#!/bin/bash

fruits=("apple" "banana" "cherry" "date")
for fruit in "${fruits[@]}";do
echo "Current fruit:$fruit"
done