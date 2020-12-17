#!/bin/bash

# N is the node number of hadoop cluster
N=$1

if [ $# = 0 ]
then
	echo "Please specify the node number of hadoop cluster!"
	exit 1
fi

# change workers file
i=1
rm config/etc-hadoop/workers
while [ $i -lt $N ]
do
	echo "hadoop-worker$i" >> config/etc-hadoop/workers
	((i++))
done 

echo ""

echo -e "\nbuild docker hadoop image\n"

# rebuild kiwenlau/hadoop image
sudo docker build -t kiwenlau/hadoop:2.0 .

echo ""
