#!/bin/bash

# start master container
sudo docker run -d -t --dns 127.0.0.1 -P --name master -h master.kiwenlau.com -w /root kiwenlau/hadoop-master:0.1.0

# get the IP address of master container
FIRST_IP=$(docker inspect --format="{{.NetworkSettings.IPAddress}}" master)

# start slave1 container
sudo docker run -d -t --dns 127.0.0.1 -P --name slave1 -h slave1.kiwenlau.com -e JOIN_IP=$FIRST_IP kiwenlau/hadoop-slave:0.1.0

# start slave2 container
sudo docker run -d -t --dns 127.0.0.1 -P --name slave2 -h slave2.kiwenlau.com -e JOIN_IP=$FIRST_IP kiwenlau/hadoop-slave:0.1.0

# create a new Bash session in the master container
sudo docker exec -it master bash
