#!/bin/bash

# start hadoop master container
sudo docker rm -f hadoop-master &> /dev/null
echo "start hadoop-master container..."
sudo docker run -itd \
                --net=hadoop \
                -p 50070:50070 \
                -p 8088:8088 \
                --name hadoop-master \
                --hostname hadoop-master \
                kiwenlau/hadoop:1.0 &> /dev/null


# start hadoop slave container
for x in $(cat config/slaves);
do
	sudo docker rm -f $x &> /dev/null
	echo "start $x container..."
	sudo docker run -itd \
	                --net=hadoop \
	                --name $x \
	                --hostname $x \
	                kiwenlau/hadoop:1.0 &> /dev/null
done 

# get into hadoop master container
sudo docker exec -it hadoop-master bash
