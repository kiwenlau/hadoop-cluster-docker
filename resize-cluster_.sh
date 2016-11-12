#!/bin/bash

# N is the node number of hadoop cluster
N=$1

if [ $# = 0 ]
then
	echo "Please specify the node number of hadoop cluster!"
	exit 1
fi

# copy files
sudo rm -rf /tmp/hadoop
sudo mkdir /tmp/hadoop
sudo chmod -R 777 /tmp/hadoop
(
cat <<EOF
#!/bin/bash
N=$N
echo \$N
# change slaves file
i=1
rm /usr/local/hadoop/etc/hadoop/slaves
while [ \$i -lt \$N ]
do
	echo "hadoop-slave\$i" >> /usr/local/hadoop/etc/hadoop/slaves
	((i++))
done 
exit
EOF
) > /tmp/hadoop/resize-cluster.sh
sudo chmod -R 777 /tmp/hadoop

# start docker
echo "start hadoop-resize container..."
sudo docker run -it \
                -v /tmp/hadoop:/root/hadoop \
                --name hadoop-resize \
                hadoop6 "/root/hadoop/resize-cluster.sh"

sudo docker commit hadoop-resize hadoop6
sudo docker rm -f hadoop-resize

sudo docker run -itd --name hadoop-resize hadoop6 sh -c "service ssh start;bash"

sudo docker commit hadoop-resize hadoop6
sudo docker rm -f hadoop-resize

echo "finished"
