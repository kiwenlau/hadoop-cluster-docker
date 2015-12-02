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
slave1.kiwenlau.com  172.17.0.66:7946  alive  
slave2.kiwenlau.com  172.17.0.67:7946  alive
```
- you can wait for a while if any nodes don't show up since serf agent need time to recognize all nodes

*test ssh*

```
ssh slave2.kiwenlau.com
```

*output*

```
Warning: Permanently added 'slave2.kiwenlau.com,172.17.0.67' (ECDSA) to the list of known hosts.
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
Connection to slave2.kiwenlau.com closed.
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


基于Docker快速搭建多节点Hadopp集群
-----

可以直接进入第三部分，快速在本机搭建一个3个节点的Hadoop集群

```
一. 项目简介
二. 镜像简介
三. 3节点Hadoop集群搭建步骤
四. N节点Hadoop集群搭建步骤
```


##一. 项目简介

这个项目的目标是将Hadoop集群运行在[Docker](https://www.docker.com/)容器中，使Hadoop开发者能够快速便捷地在本机搭建多节点的Hadoop集群。

我的项目参考了[alvinhenrick/hadoop-mutinode](https://github.com/alvinhenrick/hadoop-mutinode)项目，不过我做了大量的优化和重构。请参考下面两个表:

```
镜像名称	                  构建时间	   镜像层数	    镜像大小
alvinhenrick/serf	         258.213s     21	      239.4MB
alvinhenrick/hadoop-base	 2236.055s    58	      4.328GB
alvinhenrick/hadoop-dn	     51.959s      74	      4.331GB
alvinhenrick/hadoop-nn-dn    49.548s      84          4.331GB
```

```
镜像名称	                  构建时间	   镜像层数	   镜像大小
kiwenlau/serf-dnsmasq        509.46s      8	         206.6 MB
kiwenlau/hadoop-base	     400.29s	  7	         775.4 MB
kiwenlau/hadoop-master       5.41s        9	         775.4 MB
kiwenlau/hadoop-slave	     2.41s	      8	         775.4 MB
```

#####注意：硬盘不够，内存不够，尤其是内核版本过低会导致运行失败:(

##二. 镜像简介

######本项目一共开发了4个Docker镜像: **serf-dnsmasq**, **hadoop-base**, **hadoop-master**, **hadoop-slave**.

#####serf-dnsmasq镜像
基于ubuntu:15.04镜像。安装[serf](https://www.serfdom.io/)和[dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html). serf和dnsmasq可以为Hadoop集群提供DNS服务。

#####hadoop-base镜像 
基于serf-dnsmasq镜像。安装openjdk, openssh-server, vim和Hadoop 2.3.0。

#####hadoop-master镜像
基于hadoop-base镜像，配置Hadoop的master节点。

#####hadoop-slave镜像
基于hadoop-base镜像。配置Hadoop的slave节点。

下图显示了项目的Docker镜像结构：

![alt text](https://github.com/kiwenlau/hadoop-cluster-docker/raw/master/image architecture.jpg "Image Architecture")


##三. 3节点Hadoop集群搭建步骤


#####1. 拉取镜像

```sh
sudo docker pull index.alauda.cn/kiwenlau/hadoop-master:0.1.0
sudo docker pull index.alauda.cn/kiwenlau/hadoop-slave:0.1.0
sudo docker pull index.alauda.cn/kiwenlau/hadoop-base:0.1.0
sudo docker pull index.alauda.cn/kiwenlau/serf-dnsmasq:0.1.0
```

*查看下载的镜像*

```sh
sudo docker images
```

*运行结果*

```
REPOSITORY                                TAG      IMAGE ID        CREATED         VIRTUAL SIZE
index.alauda.cn/kiwenlau/hadoop-slave     0.1.0    d63869855c03    17 hours ago    777.4 MB
index.alauda.cn/kiwenlau/hadoop-master    0.1.0    7c9d32ede450    17 hours ago    777.4 MB
index.alauda.cn/kiwenlau/hadoop-base      0.1.0    5571bd5de58e    17 hours ago    777.4 MB
index.alauda.cn/kiwenlau/serf-dnsmasq     0.1.0    09ed89c24ee8    17 hours ago    206.7 MB
```

#####2. 修改镜像tag

```sh
sudo docker tag d63869855c03 kiwenlau/hadoop-slave:0.1.0
sudo docker tag 7c9d32ede450 kiwenlau/hadoop-master:0.1.0
sudo docker tag 5571bd5de58e kiwenlau/hadoop-base:0.1.0
sudo docker tag 09ed89c24ee8 kiwenlau/serf-dnsmasq:0.1.0 
```

*查看修改tag后镜像*

```sh
sudo docker images
```

*运行结果*

```
REPOSITORY                               TAG      IMAGE ID        CREATED         VIRTUAL SIZE
index.alauda.cn/kiwenlau/hadoop-slave    0.1.0    d63869855c03    17 hours ago    777.4 MB
kiwenlau/hadoop-slave                    0.1.0    d63869855c03    17 hours ago    777.4 MB
index.alauda.cn/kiwenlau/hadoop-master   0.1.0    7c9d32ede450    17 hours ago    777.4 MB
kiwenlau/hadoop-master                   0.1.0    7c9d32ede450    17 hours ago    777.4 MB
kiwenlau/hadoop-base                     0.1.0    5571bd5de58e    17 hours ago    777.4 MB
index.alauda.cn/kiwenlau/hadoop-base     0.1.0    5571bd5de58e    17 hours ago    777.4 MB
kiwenlau/serf-dnsmasq                    0.1.0    09ed89c24ee8    17 hours ago    206.7 MB
index.alauda.cn/kiwenlau/serf-dnsmasq    0.1.0    09ed89c24ee8    17 hours ago    206.7 MB
```

- 之所以要修改镜像，是因为我默认是将镜像上传到Dockerhub, 因此Dokerfile以及shell脚本中得镜像名称都是没有alauada前缀的，sorry for this....不过改tag还是很快滴
- 若直接下载我在DockerHub中的镜像，自然就不需要修改tag...

#####3.下载源代码

```sh
git clone https://github.com/kiwenlau/hadoop-cluster-docker
```

- 为了防止Github被XX, 我把代码导入到了开源中国的git仓库

```sh
git clone http://git.oschina.net/kiwenlau/hadoop-cluster-docker
```


#####4. 运行容器

```sh
 cd hadoop-cluster-docker
./start-container.sh
```

*运行结果*

```
start master container...
start slave1 container...
start slave2 container...
root@master:~# 
```

- 一共开启了3个容器，1个master, 2个slave
- 开启容器后就进入了master容器root用户的家目录（/root）

*查看master的root用户家目录的文件*

```sh
ls
```

*运行结果*

```
hdfs  run-wordcount.sh	serf_log  start-hadoop.sh  start-ssh-serf.sh
```

- start-hadoop.sh是开启hadoop的shell脚本
- run-wordcount.sh是运行wordcount的shell脚本，可以测试镜像是否正常工作


#####5.测试serf和dnsmasq服务

*查看hadoop集群成员*

```sh
serf members
```

*运行结果*

```
master.kiwenlau.com  172.17.0.65:7946  alive  
slave1.kiwenlau.com  172.17.0.66:7946  alive  
slave2.kiwenlau.com  172.17.0.67:7946  alive
```

- 若结果缺少节点，可以稍等片刻，再执行“serf members”命令。因为serf agent需要时间发现所有节点。

*测试ssh*

```sh
ssh slave2.kiwenlau.com
```

*运行结果*

```
Warning: Permanently added 'slave2.kiwenlau.com,172.17.0.67' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 15.04 (GNU/Linux 3.13.0-53-generic x86_64)
 * Documentation:  https://help.ubuntu.com/
The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.
Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.
root@slave2:~# 
```

*退出slave2*

```sh
exit
```

*运行结果*
```
logout
Connection to slave2.kiwenlau.com closed.
```

- 若ssh失败，请稍等片刻再测试，因为dnsmasq的dns服务器启动需要时间。
- 测试成功后，就可以开启Hadoop集群了！其实你也可以不进行测试，开启容器后耐心等待一分钟即可！

#####6. 开启hadoop

```sh
./start-hadoop.sh
```

#####7. 运行wordcount

```sh
./run-wordcount.sh
```

*运行结果*

```
input file1.txt:
Hello Hadoop

input file2.txt:
Hello Docker

wordcount output:
Docker	1
Hadoop	1
Hello	2
```

##四. N节点Hadoop集群搭建步骤

#####1. 准备工作
- 参考第二部分1~3：下载镜像，修改tag，下载源代码

#####2. 重新构建hadoop-master镜像
```sh
./resize-cluster.sh 5
```
- 不要担心，1分钟就能搞定
- 你可以为resize-cluster.sh脚本设不同的正整数作为参数数1, 2, 3, 4, 5, 6...

#####3. 启动容器
```sh
./start-container.sh 5
```
- 你可以为resize-cluster.sh脚本设不同的正整数作为参数数1, 2, 3, 4, 5, 6...
- 这个参数呢，最好还是得和上一步的参数一致:)

#####4. 测试工作
- 参考第三部分5~7：测试serf和dnsmasq服务，开启Hadoop，运行wordcount
- 请注意，若节点增加，请务必先测试，然后再开启Hadoop, 因为serf可能还没有发现所有节点，而dnsmasq的DNS服务器表示还没有配置好服务
