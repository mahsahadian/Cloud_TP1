#!/bin/bash
#This filei not finished yet, please do not execute

INSTANCE=$1
nStressors=$2
RESULTS_FILE_NAME="./results/stress-ng_test_results_$INSTANCE.csv"

if [[ "$INSTANCE" == "" || "$nStressors" == "" ]]; then
  echo "First parameter is The instance name and second parameter is The number of stressors"
  exit 1
fi

if [ ! -f $RESULTS_FILE_NAME ]; then
	echo "instance,brk,stack,bigheap" > $RESULTS_FILE_NAME
fi


re="$(stress-ng --brk $nStressors --stack $nStressors --bigheap $nStressors --metrics-brief --timeout 120s 2>&1)"
# The results we want are the value of bogo ops/s  real time
res2="${res#*] brk }"
brk=$(echo $res2 | cut -d ' ' -f 5)
stack=$(echo $res2 | cut -d ' ' -f 15)
bigheap=$(echo $res2 | cut -d ' ' -f 25)
echo $INSTANCE,$brk,$stack,$bigheap >> $RESULTS_FILE_NAME
