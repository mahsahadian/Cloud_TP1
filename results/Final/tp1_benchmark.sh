#!/bin/bash

#***********Install the benchmarks and the tools needed***************

#install API to get instance name
sudo apt-get install bonnie++
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
chmod u+x ec2-metadata
#get instance name
ID="`./ec2-metadata -t |grep "instance-type:" | cut -d ":" -f2`"

sudo apt install bonnie++
sudo apt install iozone3
sudo apt install hdparm
sudo apt install stress-ng
sudo apt install ramspeed
sudo apt install unixbench
sudo apt intall sysbench
sudo apt install speedtest

#--------------------------------------------------------------
#--------------------------TESTING DISK------------------------
#--------------------------------------------------------------

#************Testing disk i/o with Bonnie++***************
FILE=/home/ubuntu/Bonnie.txt

if test -f "$FILE";then # if we repeat the test, the results are renewed each time
rm Bonnie.txt 
rm Bonnie_r.txt
fi

touch Bonnie.txt
touch Bonnie_r.txt

#warming up the machine
for run in 1 2 3 4 5;do

        echo "Performing bonnie warm up test Mem_${ID}_${run}"
        bonnie++ -u ubuntu -r 1500 -s 3300 -b 
done


#perform the test
#-s - file size should be twice as big as RAM, but maximum file size can be 3.3G, so taking 1.5G RAM
for chunk in 512 4k 8k 16k 64k 256k;do

	for run in 1 2 3 4 5;do 

        echo "Performing bonnie test Mem_${ID}_${run}_${chunk}"
        bonnie++ -u ubuntu -r 1500 -s 3300:${chunk} -b  >> /home/ubuntu/Bonnie.txt
        echo "Bonnie_test_${ID}_${run}_${chunk}:" >> Bonnie_r.txt
        grep -A 1 -B 2 "K/sec" Bonnie.txt >> Bonnie_r.txt
        > Bonnie.txt
    done
done
sed 's/ \+/,/g' Bonnie_r.txt > Bonnie.csv  # convert data to csv file


#********************Testing disk with iozone****************
FILE=/home/ubuntu/iozone.txt

if test -f "$FILE";then # if we repeat the test, the results are renewed each time
    rm iozone.txt 
fi

touch iozone.txt
for run in 1 2 3 4 5;do 

    echo "Performing iozone test Mem_${ID}_${run}" >> /home/ubuntu/iozone.txt
    iozone -R -az -b -g 1 G -i 0 -i 1 -i 2 -I -n 512m -p -q 1024 -O  >> /home/ubuntu/iozone.txt  # perform the test 5 times

done
sed 's/ \+/,/g' iozone.txt > iozone.csv 

#******************Testing disk with dd**************
FILE=/home/ubuntu/dd.txt

if test -f "$FILE";then # if we repeat the test, the results are renewed each time
    rm dd.txt 
fi

touch dd.txt

# test for different file and cound sizes  
for bs in 1 2 3;do
    for count in 100000 150000 200000;do
        for run in 1 2 3 4 5;do 

        echo "Performing bonnie test Mem_${ID}_run${run}_count${count}_bs${bs}" >> /home/ubuntu/dd.txt
        dd if=/dev/zero of=sb-io-test bs=${bs} count=${count} conv=fdatasync >> /home/ubuntu/dd.txt
        done

    done

done

sed 's/ \+/,/g' dd.txt > dd.csv 

#*************************Running tests with hdparm************************************

#Get disk name
echo "***********Getting disk partition name*********"
echo
RESULT=$(lsblk -io KNAME,TYPE,SIZE,MODEL | grep disk)
DISK_PARTITION=$(echo $RESULT | cut -d ' ' -f 1)
echo "Disk partition name is : $DISK_PARTITION"
echo

#File to register results
FILE_NAME="home/ubuntu/disk_read_results_${ID}.csv"
echo "instance","benchmarkNumber","DiskPartition","cachedReadingSpeed","regularReadingSpeed" > $FILE_NAME

for iteration in {1..5}; do
  echo "************************ Executing Disk benchark number $iteration *****************"

  #Executing the benchmark
  res=$(sudo hdparm -Tt /dev/$DISK_PARTITION  | grep -oP "=.*MB/sec$" | grep -oP "\d+\.*\d+")
  regularSpeed=$(echo $res | cut -d ' ' -f 2)
  cachedSpeed=$(echo $res | cut -d ' ' -f 1)
  
  #Writing RESULT to file
  echo ${ID},$iteration,$DISK_PARTITION,$cachedSpeed,$regularSpeed >> $FILE_NAME

done

#--------------------------------------------------------------
#--------------------------TESTING MEMORY------------------------
#--------------------------------------------------------------


#****************************Testing memory with stress-ng***************************

memory_err="memory_err.csv"

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

#*****************************Testing memory with ram speed************

FILE=/home/ubuntu/ramspeed.txt

if test -f "$FILE";then # if we repeat the test, the results are renewed each time
    rm ramspeed.txt 
fi

touch ramspeed.txt
for run in 1 2 3 4 5;do 

    echo "Performing ramspeed test ${ID}_${run}" >> /home/ubuntu/ramspeed.txt
    #iozone -R -az -b -g 1 G -i 0 -i 1 -i 2 -I -n 512m -p -q 1024 -O  >> /home/ubuntu/iozone.txt  # perform the test 5 times
    phoronix-test-suite run ramspeed
    echo y  # save the results
    encho 4  # choose the Triad test
    echo 1  >> /home/ubuntu/ramspeed.txt; # choose integer test
    echo n

done
sed 's/ \+/,/g' ramspeed.txt > ramspeed.csv 


#--------------------------------------------------------------
#--------------------------TESTING CPU------------------------
#--------------------------------------------------------------

#***********************************Running tests with  Unixbench*******************************

FILE=/home/ubuntu/unixbench.txt

if test -f "$FILE";then # if we repeat the test, the results are renewed each time
    rm unixbench.txt 
fi

touch unixbench.txt
for run in 1 2 3 4 5;do 

    echo "Performing unixbench test ${ID}_${run}" >> /home/ubuntu/unixbench.txt
    unixbench >> /home/ubuntu/unixbench.txt  # perform the test 5 times

done
sed 's/ \+/,/g' unixbench.txt > unixbench.csv


#*****************************Running tests with sysbench*********************************** 

FILE=/home/ubuntu/sysbench.txt

if test -f "$FILE";then # if we repeat the test, the results are renewed each time
    rm sysbench.txt 
fi

touch sysbench.txt

# test for different prime numbers

    for prime in 10000 100000 1000000 10000000;do
        for run in 1 2 3 4 5;do 

        echo "Performing sysbench test ${ID}_run${run}_prime${count}"
        sysbench --test=cpu --cpu-max-prime=${prime} >> /home/ubuntu/sysbench.txt
        done

    done

sed 's/ \+/,/g' sysbench.txt > sysbench.csv 

#--------------------------------------------------------------
#--------------------------TESTING NETWORK-----------------------
#--------------------------------------------------------------

FILE=/home/ubuntu/Speed.txt

if test -f "$FILE";then
rm Speed.txt
rm Speed_r.txt
fi

touch Speed.txt
touch Speed_r.txt

#warm up 
for run in 1 2 3 4 5 6;do

    echo "Performing test Speed_${run}"
    #sysbench --test=fileio --file-total-size=32G --file-test-mode=rndrw --max-time=300 --max-requests=0 run > /home/dmhum/Advanced_cloud/RW-${thread}T-${run}.txt
    speedtest 

done

#wtest the speed
for run in 1 2 3 4 5 6;do

    echo "Performing test Speed_${run}"
    #sysbench --test=fileio --file-total-size=32G --file-test-mode=rndrw --max-time=300 --max-requests=0 run > /home/dmhum/Advanced_cloud/RW-${thread}T-${run}.txt
    speedtest >> /home/ubuntu/Speed.txt
    echo "Speed_result_${ID}_${run}:" >> Speed_r.txt
    grep -i "Download:" Speed.txt >> Speed_r.txt
    grep -i "Upload:" Speed.txt >> Speed_r.txt

    #total number of events:

done

sed 's/ \+/,/g' Speed_r.txt > network_speed.csv 