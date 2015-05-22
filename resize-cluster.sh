#!/bin/bash

tag="0.1.0"

# N is the node number of the cluster
N=$1

if [ $# = 0 ]
then
	echo "Please use the node number of the cluster as the argument!"
	exit 1
fi

cd hadoop-master

# change the slaves file
echo "master.kiwenlau.com" > files/slaves
i=1
while [ $i -lt $N ]
do
	echo "slave$i.kiwenlau.com" >> files/slaves
	((i++))
done 

# delete master container
sudo docker rm -f master 

# delete hadoop-master image
sudo docker rmi kiwenlau/hadoop-master:$tag 

# rebuild hadoop-master image
pwd
sudo docker build -t kiwenlau/hadoop-master:$tag .