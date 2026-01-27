#!/bin/bash

file="greetings.sh"

if [ -e "$file" ]; then
    echo "File exists"
else
    echo "File does not exist"
fi

