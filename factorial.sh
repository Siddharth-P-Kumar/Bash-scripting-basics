#Bash script that calculated the factorial of a given number

#!/bin/bash
calculate_factorial()
{
    num=$1
    fact=1

    for((i=1;i<=num;i++));do
    fact=$((fact*i))
    done
    echo $fact
}

#prompt the user for input
echo "Enter the number"
read input_num

factorial_result=$(calculate_factorial $input_num)
echo "The factorial of the number is $factorial_result"
