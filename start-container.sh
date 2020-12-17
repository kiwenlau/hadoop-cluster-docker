#!/bin/bash

# the default node number is 3
N=${1:-3}

# start hadoop master container
echo "start hadoop-master container..."
sudo docker rm -f hadoop-master &> /dev/null
sudo docker run -itd \
                --net=hadoop \
                --name hadoop-master \
                --hostname hadoop-master \
				        -p 9870:9870 \
                -p 8088:8088 \
                kiwenlau/hadoop:2.0

# start hadoop worker container
echo "start "$N" hadoop-workers container..."
i=1
while [ $i -lt $N ]
do
	echo "start hadoop-worker$i container..."
	sudo docker rm -f hadoop-worker$i &> /dev/null
	sudo docker run -itd \
				--net=hadoop \
				--name hadoop-worker$i \
				--hostname hadoop-worker$i \
        kiwenlau/hadoop:2.0
	i=$(( $i + 1 ))
done

# get into hadoop master container
sudo docker exec -it hadoop-master bash
