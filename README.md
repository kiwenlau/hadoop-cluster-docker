>中文说明请拼命往下翻页... sorry:(

Quickly build arbitrary size Hadoop Cluster based on Docker
------
- Developer: KiwenLau
- Email: kiwenlau@gmail.com (feel free to contact me if you have any questions or ideas)
- [Blog](http://kiwenlau.blogspot.com/2015/05/quickly-build-arbitrary-size-hadoop.html)
[GitHub](https://github.com/kiwenlau/hadoop-cluster-docker)

You can go to the section 3 directly and build a 3 nodes Hadoop cluster following the directions.

```
1. Project Introduction
2. Hadoop-Cluster-Docker image Introduction
3. Steps to build a 3 nodes Hadoop Cluster
4. Steps to build an arbitrary size Hadoop Cluster
```

##1. Project Introduction

Building a Hadoop cluster using physical machines is very painful, especially for beginners. They will be frustrated by this problem before running wordcount. 

My objective is to run Hadoop cluster based on Docker, and help Hadoop developer to quickly build an arbitrary size Hadoop cluster on their local host. This idea already has several implementations, but in my view, they are not good enough. Their image size is too large, or they are very slow and they are not user friendly by using third party tools. Following table shows some problems of existing Hadoop on Docker projects.
```
Project                              Image Size      Problem
sequenceiq/hadoop-docker:latest      1.491GB         too large, only one node
sequenceiq/hadoop-docker:2.7.0       1.76 GB    
sequenceiq/hadoop-docker:2.60        1.624GB    

sequenceiq/ambari:latest             1.782GB         too large, too slow, using third party tool
sequenceiq/ambari:2.0.0              4.804GB    
sequenceiq/ambari:latest:1.70        4.761GB    

alvinhenrick/hadoop-mutinode         4.331GB         too large, too slow to build images, not easy to add nodes, have some bugs
```
My project is based on "alvinhenrick/hadoop-mutinode" project, however, I've reconstructed it for optimization. Following is the GitHub address and blog address of "alvinhenrick/hadoop-mutinode" project. [GitHub](https://github.com/alvinhenrick/hadoop-mutinode), [Blog](http://alvinhenrick.com/2014/07/16/hadoop-yarn-multinode-cluster-with-docker/)

Following table shows the differences between my project "kiwenlau/hadoop-cluster-docker" and "alvinhenrick/hadoop-mutinode" project
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
In summary, I did following optimizations:

- Smaller image size
- Faster build time
- Less image layers

#####Change node number quickly and conveniently

For "alvinhenrick/hadoop-mutinode" project, If you want to change node number, you have to change hadoop configuration file (slaves, which list the domain name or ip address of all nodes ), rebuild hadoop-nn-dn image, change the shell sript for starting containers! As for my "kiwenlau/hadoop-cluster-docker" project, I write a shell script (resize-cluster.sh) to automate these steps. Then you can rebuild the hadoop-master image within one minutes and run an arbitrary size Hadoop Cluster quickly! The default node number of my project is 3 and you can change is to any size you like!

In addition, building image, running container, starting Hadoop and run wordcount, all these jobs are automated by shell scripts. So you can use and develop this project more easily! Welcome to join this project.

#####Develop environment

- OS：ubuntu 14.04 and ubuntu 12.04
- kernel: 3.13.0-32-generic
- Docke：1.5.0 and1.6.2

#####Attention: old kernel version will cause failure while running my project

##2. Hadoop-Cluster-Docker image Introduction

I developed 4 docker images in this project

- serf-dnsmasq
- hadoop-base
- hadoop-master
- hadoop-slave

#####serf-dnsmasq

- based on ubuntu:15.04: It is the smallest ubuntu image
- install serf: serf is an distributed cluster membership management tool, which can recognize all nodes of the Hadoop cluster
- install dnsmasq: dnsmasq is a lightweight dns server, which can provide domain name resolution service for the Hadoop Cluster

When containers start, the IP address of master node will passed to all slaves node. Serf will start when the containers start. Serf agents on all slaves node will recognize the master node because they know the IP address of master node. Then the serf agent on master node will recognize all slave nodes. Serf agents on all nodes will communicate with each other, so everyone will know everyone after a while. When serf agent recognize new node, it will reconfigure the dnsmasq and restart it. Eventually, dnsmasq will be able to provide domain name resolution service for all nodes of the Hadoop Cluster. However, the startup jobs for serf and dnsmasq will cause more time when node number increases. Thus, when you want run more nodes, you have to verify whether serf agent have found all nodes and whether dnsmasq can resolve all nodes before you start hadoop. Using serf and dnsmasq to solve FQDN problem is proposed by SequenceIQ, which is startup company focusing on runing Hadoop on Docker. You can read this [slide](http://www.slideshare.net/JanosMatyas/docker-based-hadoop-provisioning) for more details.

#####hadoop-base 

- based on serf-dnsmasq
- install JDK(openjdk)
- install openssh-server, configure password free ssh
- install vim：happy coding inside docker container:)
- install Hadoop 2.3.0: install compiled hadoop （2.5.2， 2.6.0， 2.7.0 is bigger than 2.3.0)

You can check my blog for compiling hadoop：[Steps to compile 64-bit Hadoop 2.3.0 under Ubuntu 14.04](http://kiwenlau.blogspot.jp/2015/05/steps-to-compile-64-bit-hadoop-230.html)

If you want to rebuild hadoop-base image, you need download the compiled hadoop, and put it inside hadoop-cluster-docker/hadoop-base/files directory. Following is the address to download compiled hadoop: [hadoop-2.3.0](http://1drv.ms/1HZ1TSV)

If you want to try other version of Hadoop, you can download these compiled hadoop.
- [hadoop-2.5.2](http://1drv.ms/1AE1DJ2)
- [hadoop-2.6.0](http://1drv.ms/1AE1CoC)
- [hadoop-2.7.0](http://1drv.ms/1AE1DZN)

#####hadoop-master

- based on hadoop-base 
- configure hadoop master
- formate namenode

We need to configure slaves file during this step, and slaves file need to list the domain names and ip address of all nodes. Thus, when we change the node number of hadoop cluster, the slaves file should be different. That's why we need change slaves file and rebuild hadoop-master image when we want to change node number. I write a shell script named resize-cluster.sh to automatically rebuild hadoop-master image to support arbitrary size Hadoop cluster. You only need to give the node number as the parameter of resize-cluster.sh to change the node number of Hadoop cluster. Building the hadoop-master image only costs 1 minute since it only does some configuration jobs.

#####hadoop-slave

- based on hadoop-base
- configure hadoop slave node

#####image size analysis

following table shows the output of "sudo docker images"
```
REPOSITORY                 TAG       IMAGE ID        CREATED          VIRTUAL SIZE
kiwenlau/hadoop-slave      0.1.0     d63869855c03    17 hours ago     777.4 MB
kiwenlau/hadoop-master     0.1.0     7c9d32ede450    17 hours ago     777.4 MB
kiwenlau/hadoop-base       0.1.0     5571bd5de58e    17 hours ago     777.4 MB
kiwenlau/serf-dnsmasq      0.1.0     09ed89c24ee8    17 hours ago     206.7 MB
ubuntu                     15.04     bd94ae587483    3 weeks ago      131.3 MB
```

Thus：

- serf-dnsmasq increases 75.4MB based on ubuntu:15.04
- hadoop-base increases 570.7MB based on serf-dnsmasq
- hadoop-master and hadoop-slave increase 0 MB based on hadoop-base

following table shows the partial output of "docker history kiwenlau/hadoop-base:0.1.0"
```
IMAGE            CREATED             CREATED BY                                             SIZE
2039b9b81146     44 hours ago        /bin/sh -c #(nop) ADD multi:a93c971a49514e787          158.5 MB
cdb620312f30     44 hours ago        /bin/sh -c apt-get install -y openjdk-7-jdk            324.6 MB
da7d10c790c1     44 hours ago        /bin/sh -c apt-get install -y openssh-server           87.58 MB
c65cb568defc     44 hours ago        /bin/sh -c curl -Lso serf.zip https://dl.bint          14.46 MB
3e22b3d72e33     44 hours ago        /bin/sh -c apt-get update && apt-get install           60.89 MB
b68f8c8d2140     3 weeks ago         /bin/sh -c #(nop) ADD file:d90f7467c470bfa9a3          131.3 MB
```
Thus:

- base image ubuntu:15.04 is 131.3MB
- installing openjdk costs 324.6MB
- installing hadoop costs 158.5MB
- total size of ubuntu,openjdk and hadoop is 614.4MB

Following picture shows the image architecture of my project.



#####So, my hadoop image is near minimal size and it's hard to do more optimization

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
- hadoop-base is based on serf-dnsmasq，hadoop-slave and hadoop-master is based on hadoop-base
- so the total size of all four images is only 777.4MB

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
- start-hadoop.sh is the shell script to start hadoop
- run-wordcount.sh is the shell script to run wordcount program

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
- you need to exit slave2 node after ssh to it...

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
- you don't have to pull serf-dnsmasq but you need to pull hadoop-base, since rebuiding hadoop-master is based on hadoop-base

#####b. rebuild hadoop-master
```
./resize-cluster.sh 5
```
- It only take 1 minutes
- you can use any interger as the parameter for resize-cluster.sh: 1, 2, 3, 4, 5, 6...

#####c. start container
```
./start-container.sh 5
```
- you can use any interger as the parameter for start-container.sh: 1, 2, 3, 4, 5, 6...
- you'd better use the same parameter as the step b

#####d. run the Hadoop cluster 

- check the steps d~f of section 3：test serf and dnsmasq,  start Hadoop and run wordcount
- please test serf and dnsmasq service before start hadoop


基于Docker快速搭建多节点Hadopp集群
-----

- 开发者：KiwenLau
- 邮箱：kiwenlau@163.com
- [DockerOne](http://dockone.io/article/395), [Blogger](http://kiwenlau.blogspot.jp/2015/05/dockerhadoop_24.html), [博客园](http://www.cnblogs.com/kiwenlau/p/4524607.html)

可以直接进入第三部分，快速在本机搭建一个3个节点的Hadoop集群
```
一. 项目简介
二. 镜像简介
三. 3节点Hadoop集群搭建步骤
四. N节点Hadoop集群搭建步骤
```


##一. 项目简介

直接用机器搭建Hadoop集群是一个相当痛苦的过程，尤其对初学者来说。他们还没开始跑wordcount，可能就被这个问题折腾的体无完肤了....而且也不是每个人都有好几台机器对吧...你可以尝试用多个虚拟机搭建...前提是你有个性能杠杠的机器...

我的目标是将Hadoop集群运行在Docker容器中，使Hadoop开发者能够快速便捷地在本机搭建多节点的Hadoop集群。其实这个想法已经有了不少实现，但是都不是很理想，他们或者镜像太大，或者使用太慢，或者使用了第三方工具使得使用起来过于复杂...下表为一些已知的Hadoop on Docker项目以及其存在的问题。

```
项目	                            镜像大小	  问题
sequenceiq/hadoop-docker:latest   1.491GB     镜像太大，只支持单个节点
sequenceiq/hadoop-docker:2.7.0    1.76 GB	
sequenceiq/hadoop-docker:2.60     1.624GB	

sequenceiq/ambari:latest          1.782GB     镜像太大，使用太慢，使用第三方工具，增加了复杂度
sequenceiq/ambari:2.0.0           4.804GB	
sequenceiq/ambari:latest:1.70     4.761GB	

alvinhenrick/hadoop-mutinode      4.331GB     镜像太大，构建时间太慢，增加节点麻烦，有bug  
```


我的项目参考了alvinhenrick/hadoop-mutinode项目，不过我做了大量的优化和重构。alvinhenrick/hadoop-mutinode项目的Github主页以及作者所写的博客地址：[GitHub](https://github.com/alvinhenrick/hadoop-mutinode)， [博客](http://alvinhenrick.com/2014/07/16/hadoop-yarn-multinode-cluster-with-docker/)

下面两个表是alvinhenrick/hadoop-mutinode项目与我的kiwenlau/hadoop-cluster-docker项目的参数对比

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


可知，我主要优化了这样几点
- 更小的镜像大小
- 更快的构造时间
- 更少的镜像层数

#####更快更方便地改变Hadoop集群节点数目
另外，alvinhenrick/hadoop-mutinode项目增加节点时需要手动修改Hadoop配置文件然后重新构建hadoop-nn-dn镜像,然后修改容器启动脚本，才能实现增加节点的功能。而我通过shell脚本实现自动话，不到1分钟可以重新构建hadoop-master镜像，然后立即运行！！！本项目默认启动3个节点的Hadoop集群，支持任意节点数的hadoop集群。

另外，启动hadoop, 运行wordcount以及重新构建镜像都采用了shell脚本实现自动化。这样使得整个项目的使用以及开发都变得非常方便快捷:)

#####开发测试环境
- 操作系统：ubuntu 14.04 和 ubuntu 12.04
- 内核版本: 3.13.0-32-generic
- Docker版本：1.5.0 和1.6.2

#####小伙伴们，硬盘不够，内存不够，尤其是内核版本过低会导致运行失败...

##二. 镜像简介

######本项目一共开发了4个镜像
- serf-dnsmasq
- hadoop-base
- hadoop-master
- hadoop-slave

#####serf-dnsmasq镜像

- 基于ubuntu:15.04 (选它是因为它最小，不是因为它最新...)
- 安装serf: serf是一个分布式的机器节点管理工具。它可以动态地发现所有hadoop集群节点。
- 安装dnsmasq: dnsmasq作为轻量级的dns服务器。它可以为hadoop集群提供域名解析服务。

容器启动时，master节点的IP会传给所有slave节点。serf会在container启动后立即启动。slave节点上的serf agent会马上发现master节点（master IP它们都知道嘛），master节点就马上发现了所有slave节点。然后它们之间通过互相交换信息，所有节点就能知道其他所有节点的存在了！(Everyone will know Everyone). serf发现新的节点时，就会重新配置dnsmasq,然后重启dnsmasq. 所以dnsmasq就能够解析集群的所有节点的域名啦。这个过程随着节点的增加会耗时更久，因此，若配置的Hadoop节点比较多，则在启动容器后需要测试serf是否发现了所有节点，dns是否能够解析所有节点域名。稍等片刻才能启动Hadoop。这个解决方案是由SequenceIQ公司提出的，该公司专注于将Hadoop运行在Docker中。参考：[Docker-based Hadoop Provisioning](http://www.slideshare.net/JanosMatyas/docker-based-hadoop-provisioning)

#####hadoop-base镜像 
- 基于serf-dnsmasq镜像
- 安装JDK(openjdk)
- 安装openssh-server, 配置无密码ssh
- 安装vim：介样就可以愉快地在容器中敲代码了:)
- 安装Hadoop 2.3.0: 安装编译过的hadoop （2.5.2， 2.6.0， 2.7.0 都比2.3.0大，所以我懒得升级了）

编译Hadoop的步骤请参考我的博客：[博客园](http://www.cnblogs.com/kiwenlau/p/4227204.html)，[Blogger](http://kiwenlau.blogspot.jp/2015/01/hadoop-230-ubuntu-1404.html)

如果需要重新开发我的hadoop-base, 需要下载编译过的hadoop-2.3.0安装包，放到hadoop-cluster-docker/hadoop-base/files目录内。我编译的64位hadoop-2.3.0下载地址：

[hadoop-2.3.0](http://pan.baidu.com/s/1sjFRaFz)

另外，我还编译了64位的hadoop 2.5.2, 2.6.0, 2.7.0, 其下载地址如下：
- [hadoop-2.3.0](http://pan.baidu.com/s/1sjFRaFz) 
- [hadoop-2.5.2](http://pan.baidu.com/s/1jGw24aa)
- [hadoop-2.6.0](http://pan.baidu.com/s/1eQgvF2M)
- [hadoop-2.7.0]( http://pan.baidu.com/s/1c0HD0Nu)

#####hadoop-master镜像
- 基于hadoop-base镜像
- 配置hadoop的master节点
- 格式化namenode

这一步需要配置slaves文件，而slaves文件需要列出所有节点的域名或者IP。因此，Hadoop节点数目不同时，slaves文件自然也不一样。因此，更改Hadoop集群节点数目时，需要修改slaves文件然后重新构建hadoop-master镜像。我编写了一个resize-cluster.sh脚本自动化这一过程。仅需给定节点数目作为脚本参数就可以轻松实现Hadoop集群节点数目的更改。由于hadoop-master镜像仅仅做一些配置工作，也无需下载任何文件，整个过程非常快，1分钟就足够了。

#####hadoop-slave镜像
- 基于hadoop-base镜像
- 配置hadoop的slave节点

#####镜像大小分析

下表为sudo docker images的运行结果

```
REPOSITORY                                TAG      IMAGE ID        CREATED         VIRTUAL SIZE
index.alauda.cn/kiwenlau/hadoop-slave     0.1.0    d63869855c03    17 hours ago    777.4 MB
index.alauda.cn/kiwenlau/hadoop-master    0.1.0    7c9d32ede450    17 hours ago    777.4 MB
index.alauda.cn/kiwenlau/hadoop-base      0.1.0    5571bd5de58e    17 hours ago    777.4 MB
index.alauda.cn/kiwenlau/serf-dnsmasq     0.1.0    09ed89c24ee8    17 hours ago    206.7 MB
ubuntu                                    15.04    bd94ae587483    3 weeks ago     131.3 MB

```

易知以下几个结论：
- serf-dnsmasq镜像在ubuntu:15.04镜像的基础上增加了75.4MB
- hadoop-base镜像在serf-dnsmasq镜像的基础上增加了570.7MB
- hadoop-master和hadoop-slave镜像在hadoop-base镜像的基础上大小几乎没有增加

下表为docker history index.alauda.cn/kiwenlau/hadoop-base:0.1.0命令的部分运行结果
```
IMAGE           CREATED             CREATED BY                                      SIZE
2039b9b81146    44 hours ago        /bin/sh -c #(nop) ADD multi:a93c971a49514e787   158.5 MB
cdb620312f30    44 hours ago        /bin/sh -c apt-get install -y openjdk-7-jdk     324.6 MB
da7d10c790c1    44 hours ago        /bin/sh -c apt-get install -y openssh-server    87.58 MB
c65cb568defc    44 hours ago        /bin/sh -c curl -Lso serf.zip https://dl.bint   14.46 MB
3e22b3d72e33    44 hours ago        /bin/sh -c apt-get update && apt-get install    60.89 MB
b68f8c8d2140    3 weeks ago         /bin/sh -c #(nop) ADD file:d90f7467c470bfa9a3   131.3 MB
```

可知
- 基础镜像ubuntu:15.04为131.3MB
- 安装openjdk需要324.6MB
- 安装hadoop需要158.5MB
- ubuntu,openjdk与hadoop均为镜像所必须，三者一共占了:614.4MB
- 因此，我所开发的hadoop镜像以及接近最小，优化空间已经很小了


##三. 3节点Hadoop集群搭建步骤


#####1. 拉取镜像

```sh
sudo docker pull index.alauda.cn/kiwenlau/hadoop-master:0.1.0
sudo docker pull index.alauda.cn/kiwenlau/hadoop-slave:0.1.0
sudo docker pull index.alauda.cn/kiwenlau/hadoop-base:0.1.0
sudo docker pull index.alauda.cn/kiwenlau/serf-dnsmasq:0.1.0
```
- 3~5分钟OK~

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
- hadoop-base镜像是基于serf-dnsmasq镜像的，hadoop-slave镜像和hadoop-master镜像都是基于hadoop-base镜像
- 所以其实4个镜像一共也就777.4MB:)

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
- 若直接下载我在DockerHub中的镜像，自然就不需要修改tag...不过Alauda镜像下载速度很快的哈~

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


#####5.测试容器是否正常启动(此时已进入master容器)

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

- 上一步ssh到slave2之后，请记得回到master啊!!！
- 运行结果太多，忽略....
- hadoop的启动速度取决于机器性能....

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

- wordcount的执行速度取决于机器性能....


##四. N节点Hadoop集群搭建步骤

#####1. 准备工作
- 参考第二部分1~3：下载镜像，修改tag，下载源代码
- 注意，你可以不下载serf-dnsmasq, 但是请最好下载hadoop-base，因为hadoop-master是基于hadoop-base构建的

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
- 这个参数如果比上一步的参数大，你多启动的节点，Hadoop不认识它们..
- 这个参数如果比上一步的参数小，Hadoop觉得少启动的节点挂掉了..

#####4. 测试工作
- 参考第三部分5~7：测试容器，开启Hadoop，运行wordcount
- 请注意，若节点增加，请务必先测试容器，然后再开启Hadoop, 因为serf可能还没有发现所有节点，而dnsmasq的DNS服务器表示还没有配置好服务
- 测试等待时间取决于机器性能....
