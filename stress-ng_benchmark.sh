#!/bin/bash
#This filei not finished yet, please do not execute

INSTANCE=$1
nStressors=$2
RESULTS_FILE_NAME="stress-ng_test_results_$INSTANCE.csv"

if [[ "$INSTANCE" == "" || "$nStressors" == "" ]]; then
  echo "First parameter is The instance name and second parameter is The number of stressors"
  exit 1
fi

if [ ! -f $RESULTS_FILE_NAME ]; then
	echo "instance,brk,stack,bigheap" > $RESULTS_FILE_NAME
fi


result="$(stress-ng --brk $nStressors --stack $nStressors --bigheap $nStressors --metrics-brief --timeout 60s 2>&1)"
subresult="${result#*] brk }"
brk=$(echo $subresult | cut -d ' ' -f 5)
stack=$(echo $subresult | cut -d ' ' -f 15)
bigheap=$(echo $subresult | cut -d ' ' -f 25)
echo $INSTANCE,$brk,$stack,$bigheap >> $RESULTS_FILE_NAME

echo "pushing the result to github"
git pull
git add stress-ng_test_results_$INSTANCE.csv
git commit -m "stress-ng benchmarking results for instance : $INSTANCE"
git push 
