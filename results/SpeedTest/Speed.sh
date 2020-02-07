#!/bin/bash
#ID="`wget -q -O http://172.31.80.190/latest/meta-data/instance-id`"
#TYPE="`wget -q -O http://172.31.80.190/latest/meta-data/instance-type`"

apt-get install speedtest-cli 

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
	echo "Speed_result_${run}:" >> Speed_r.txt
	grep -i "Download:" Speed.txt >> Speed_r.txt
	grep -i "Upload:" Speed.txt >> Speed_r.txt

	#total number of events:

done



