#!/bin/bash
#install API to get instance name
sudo apt-get install bonnie++
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
chmod u+x ec2-metadata
#get instance name
ID="`./ec2-metadata -t |grep "instance-type:" | cut -d ":" -f2`"


FILE=/home/ubuntu/Bonnie.txt
#FILE=/home/dmhum/Advanced_cloud/Bonnie_r.txt
if test -f "$FILE";then # if we repeat the test, the results are renewed each time
rm Bonnie.txt 
rm Bonnie_r.txt
fi

touch Bonnie.txt
touch Bonnie_r.txt

#warming up the machine
for run in 1 2 3 4 5;do

        echo "Performing bonnie warm up test Mem_${ID}_${run}"
        bonnie++ -u ubuntu -r 1500 -s 3300 -b  #>> /home/ubuntu/Bonnie.txt
        #echo "Bonnie_test_${ID}_${run}:" >> Bonnie_r.txt
        #grep -A 1 "K/sec" Bonnie.txt >> Bonnie_r.txt
        #> Bonnie.txt
done


#perform the test
#-s - file size should be twice as big as RAM, but maximum file size can be 3.3G, so taking 1.5G RAM
for run in 1 2 3 4 5;do

        echo "Performing bonnie test Mem_${ID}_${run}"
        bonnie++ -u ubuntu -r 1500 -s 3300 -b  >> /home/ubuntu/Bonnie.txt
        echo "Bonnie_test_${ID}_${run}:" >> Bonnie_r.txt
        grep -A 1 "K/sec" Bonnie.txt >> Bonnie_r.txt
        > Bonnie.txt
done
sed 's/ \+/,/g' Bonnie_r.txt > Bonnie.csv

