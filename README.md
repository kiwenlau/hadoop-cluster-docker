# Run Hadoop Custer within Docker Containers

```
sudo docker network create --driver=bridge hadoop
```

##A. 3 Nodes Hadoop Cluster

#####1. pull docker image

```
sudo docker pull kiwenlau/hadoop:1.0
```

#####2. clone github repository

```
git clone https://github.com/kiwenlau/hadoop-cluster-docker
```

#####3. run container
```
cd hadoop-cluster-docker
sudo ./start-container.sh
```

**output:**

```
start hadoop-master container...
start hadoop-slave1 container...
start hadoop-slave2 container...
root@hadoop-master:~# 
```
- start 3 containers with 1 master and 2 slaves
- you will get into the /root directory of hadoop-master container

#####4. start hadoop

```
./start-hadoop.sh
```


#####5. run wordcount

```
./run-wordcount.sh
```

**output**

```
input file1.txt:
Hello Hadoop

input file2.txt:
Hello Docker

wordcount output:
Docker    1
Hadoop    1
Hello    2
```

##B. Arbitrary size Hadoop cluster

#####1. pull docker images and clone github repository

do 4~5 like section A

#####2. rebuild docker image

```
./resize-cluster.sh 5
```

- specify parameter > 1: 2, 3..


#####3. start container

```
./start-container.sh 5
```
- use the same parameter as the step 2

#####4. run hadoop cluster 

do 4~5 like section A

