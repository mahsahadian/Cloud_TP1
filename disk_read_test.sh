#!/bin/bash

INSTANCE_NAME=$1

#Get disk name
echo "***********Getting disk partition name*********"
echo
RESULT=$(lsblk -io KNAME,TYPE,SIZE,MODEL | grep disk)
DISK_PARTITION=$(echo $RESULT | cut -d ' ' -f 1)
echo "Disk partition name is : $DISK_PARTITION"
echo

#File to register results
FILE_NAME="./results/disk_read_results_$INSTANCE_NAME.csv"
echo "instance","benchmarkNumber","DiskPartition","cachedReadingSpeed","regularReadingSpeed" > $FILE_NAME

#Warming the machine first
for x in {1..5}; do
  echo "************************ Warming the machine first: $x *****************"
  echo
  sudo hdparm -Tt /dev/$DISK_PARTITION
  sleep 2
done

for iteration in {1..5}; do
  echo "************************ Executing Disk benchark number $iteration *****************"
  echo
  #Checking if instance name is empty
  if [[ "$INSTANCE_NAME" == "" ]]; then
    echo "The First parameter should be the INSTANCE_NAME"
    echo
    exit 1
  fi
  
  #Executing the benchmark
  res=$(sudo hdparm -Tt /dev/$DISK_PARTITION  | grep -oP "=.*MB/sec$" | grep -oP "\d+\.*\d+")
  regularSpeed=$(echo $res | cut -d ' ' -f 2)
  cachedSpeed=$(echo $res | cut -d ' ' -f 1)
  
  #Writing RESULT to file
  echo $INSTANCE_NAME,$iteration,$DISK_PARTITION,$cachedSpeed,$regularSpeed >> $FILE_NAME

done
