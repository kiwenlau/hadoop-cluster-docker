#!/bin/bash

# run N slave containers
N=$1

# the defaut node number is 3
if [ $# = 0 ]
then
	N=3
fi
	

# delete old master container and start new master container
sudo docker rm -f master &> /dev/null
echo "start master container..."
sudo docker run -d -t --dns 127.0.0.1 -P --name master -h master.kiwenlau.com -w /root kiwenlau/hadoop-master:0.1.0 &> /dev/null

# get the IP address of master container
FIRST_IP=$(sudo docker inspect --format="{{.NetworkSettings.IPAddress}}" master)

# delete old slave containers and start new slave containers
i=1
while [ $i -lt $N ]
do
	sudo docker rm -f slave$i &> /dev/null
	echo "start slave$i container..."
	sudo docker run -d -t --dns 127.0.0.1 -P --name slave$i -h slave$i.kiwenlau.com -e JOIN_IP=$FIRST_IP kiwenlau/hadoop-slave:0.1.0 &> /dev/null
	i=$(( $i + 1 ))
done 


# create a new Bash session in the master container
sudo docker exec -it master bash
