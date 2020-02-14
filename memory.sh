#!/bin/bash

# Source: https://wiki.ubuntu.com/Kernel/Reference/stress-ng

instance_name=$1
memory_err="memory_err.csv"

if [[ "$instance_name" == "" ]]; then
  echo "First parameter is instance_name"
  exit 1
fi

if [ ! -f $memory_err ]; then
	echo "instance,nb_stressors,mem_err" > $memory_err
fi

# Run and increase stressors until we get the first memory error.
mem_err=0
nb_stressors=1
while [[ "$mem_err" -lt 15 ]]; do
  echo "Testing with $nb_stressors number of stressors"
	result="$(stress-ng --brk $nb_stressors --stack $nb_stressors --bigheap $nb_stressors --metrics-brief --timeout 120s 2>&1)"
echo $result
	mem_err=$(echo "$result" | grep -o "Cannot allocate memory" | wc -l)
	echo "memoryErrors: "$mem_err
    echo $instance_name,$nb_stressors,$mem_err >> $memory_err
    ((nb_stressors++))
done
echo "FInding the max input parameter test over"

