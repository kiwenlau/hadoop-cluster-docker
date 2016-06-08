>中文说明请拼命往下翻页... sorry:(

Quickly build arbitrary size Hadoop Cluster based on Docker
------

```
1. Project Introduction
2. Hadoop-Cluster-Docker image Introduction
3. Steps to build a 3 nodes Hadoop Cluster
4. Steps to build an arbitrary size Hadoop Cluster
```

##1. Project Introduction

The objective of this project is to help Hadoop developer to quickly build an arbitrary size Hadoop cluster on their local host. This is achieved by using [Docker](https://www.docker.com/). 

My project is based on [alvinhenrick/hadoop-mutinode](https://github.com/alvinhenrick/hadoop-mutinode) project, however, I've reconstructed it for optimization. Following table shows the differences.

```
Image Name                    Build time      Layer number     Image Size
alvinhenrick/serf             258.213s        21               239.4MB
alvinhenrick/hadoop-base      2236.055s       58               4.328GB
alvinhenrick/hadoop-dn        51.959s         74               4.331GB
alvinhenrick/hadoop-nn-dn     49.548s         84               4.331GB
```

```
Image Name                    Build time     Layer number       Image Size
kiwenlau/serf-dnsmasq         509.46s        8                  206.6 MB
kiwenlau/hadoop-base          400.29s        7                  775.4 MB
kiwenlau/hadoop-master        5.41s          9                  775.4 MB
kiwenlau/hadoop-slave         2.41s          8                  775.4 MB
```

#####Attention: old kernel version will cause failure while running my project

##2. Hadoop-Cluster-Docker image Introduction

In this project, I developed 4 docker images: **serf-dnsmasq**, **hadoop-base**, **hadoop-master** and **hadoop-slave**.

#####serf-dnsmasq

Based on ubuntu:15.04. [serf](https://www.serfdom.io/) and [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) are installed for providing DNS service for the Hadoop Cluster.

#####hadoop-base 

Based on serf-dnsmasq, openjdk, openssh-server, vim and Hadoop 2.3.0 are installed.

#####hadoop-master

Based on hadoop-base. Configure the Hadoop master node. 

#####hadoop-slave

Based on hadoop-base. Configure the Hadoop slave node.

Following picture shows the image architecture of my project:

![alt text](https://github.com/kiwenlau/hadoop-cluster-docker/raw/master/image architecture.jpg "Image Architecture")

##3. steps to build a 3 nodes Hadoop cluster

#####a. pull image
```
sudo docker pull kiwenlau/hadoop-master:0.1.0
sudo docker pull kiwenlau/hadoop-slave:0.1.0
sudo docker pull kiwenlau/hadoop-base:0.1.0
sudo docker pull kiwenlau/serf-dnsmasq:0.1.0
```
*check downloaded images*

```
sudo docker images
```

*output*

```
REPOSITORY                TAG       IMAGE ID        CREATED         VIRTUAL SIZE
kiwenlau/hadoop-slave     0.1.0     d63869855c03    17 hours ago    777.4 MB
kiwenlau/hadoop-master    0.1.0     7c9d32ede450    17 hours ago    777.4 MB
kiwenlau/hadoop-base      0.1.0     5571bd5de58e    17 hours ago    777.4 MB
kiwenlau/serf-dnsmasq     0.1.0     09ed89c24ee8    17 hours ago    206.7 MB
```


#####b. clone source code
```
git clone https://github.com/kiwenlau/hadoop-cluster-docker
```
#####c. run container
```
 cd hadoop-cluster-docker
./start-container.sh
```

*output*

```
start master container...
start slave1 container...
start slave2 container...
root@master:~#
```
- start 3 containers，1 master and 2 slaves
- you will go to the /root directory of master container after start all containers

*list the files inside /root directory of master container*

```
ls
```

*output*

```
hdfs  run-wordcount.sh    serf_log  start-hadoop.sh  start-ssh-serf.sh
```

#####d. test serf and dnsmasq service

- In fact, you can skip this step and just wait for about 1 minute. Serf and dnsmasq need some time to start service.

*list all nodes of hadoop cluster*

```
serf members
```

*output*

```
master.kiwenlau.com  172.17.0.65:7946  alive  
hadoop-slave1  172.17.0.66:7946  alive  
hadoop-slave2  172.17.0.67:7946  alive
```
- you can wait for a while if any nodes don't show up since serf agent need time to recognize all nodes

*test ssh*

```
ssh hadoop-slave2
```

*output*

```
Warning: Permanently added 'hadoop-slave2,172.17.0.67' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 15.04 (GNU/Linux 3.13.0-53-generic x86_64)
 * Documentation:  https://help.ubuntu.com/
The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.
Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.
root@slave2:~#
```

*exit slave2 nodes*

```
exit
```

*output*

```
logout
Connection to hadoop-slave2 closed.
```
- Please wait for a whil if ssh fails, dnsmasq need time to configure domain name resolution service
- You can start hadoop after these tests!

#####e. start hadoop
```
./start-hadoop.sh
```


#####f. run wordcount
```
./run-wordcount.sh
```

*output*

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

##4. Steps to build arbitrary size Hadoop cluster

#####a. Preparation

- check the steps a~b of section 3：pull images and clone source code

#####b. rebuild hadoop-master

```
./resize-cluster.sh 5
```

- you can use any interger as the parameter for resize-cluster.sh: 1, 2, 3, 4, 5, 6...


#####c. start container
```
./start-container.sh 5
```
- you'd better use the same parameter as the step b

#####d. run the Hadoop cluster 

- check the steps d~f of section 3：test serf and dnsmasq,  start Hadoop and run wordcount
- please test serf and dnsmasq service before start hadoop
