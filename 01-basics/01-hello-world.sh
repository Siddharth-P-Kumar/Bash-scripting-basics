#!/bin/bash

# Script: Hello World - Your First Bash Script
# Purpose: Introduction to bash scripting basics
# Author: Learning Path
# Date: $(date)

# This is a comment - lines starting with # are ignored by bash
# The first line (#!/bin/bash) is called a shebang - it tells the system which interpreter to use

echo "Hello, World!"
echo "Welcome to Bash Scripting!"

# Variables in bash
name="Beginner"
echo "Hello, $name!"

# Getting user input
echo "What's your name?"
read user_name
echo "Nice to meet you, $user_name!"
