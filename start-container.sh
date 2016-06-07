#!/bin/bash

# run N slave containers, the default valume is 3
N=${1:-3}

# start hadoop master container
sudo docker rm -f hadoop-master > /dev/null
echo "start hadoop-master container..."
sudo docker run -d -t -P --name hadoop-master -h master.kiwenlau.com -w /root --net=hadoop kiwenlau/hadoop-master:1.0.0 &> /dev/null

# get the IP address of master container
FIRST_IP=$(sudo docker inspect --format="{{.NetworkSettings.IPAddress}}" hadoop-master)

# start hadoop slave container
i=1
while [ $i -lt $N ]
do
	sudo docker rm -f hadoop-slave$i > /dev/null
	echo "start hadoop-slave$i container..."
	sudo docker run -d -t -P --name hadoop-slave$i -h slave$i.kiwenlau.com --net=hadoop kiwenlau/hadoop-slave:1.0.0 &> /dev/null
	i=$(( $i + 1 ))
done 

# sudo docker exec -it hadoop-master bash
