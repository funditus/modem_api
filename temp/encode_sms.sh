#!/bin/bash

## vnet

## Script encodes input string to UTF-16 (f.e. to send SMS)
## Works in BASH only

# File to read
INPUT=input.txt
 
# while loop
while IFS= read -r -N1 char
do
        # display one character at a time
        printf "%04X" \'"$char"
## if read from stdin
#done

## If taken from file
done < "$INPUT"
