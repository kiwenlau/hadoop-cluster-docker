FROM ubuntu:14.04

MAINTAINER KiwenLau <kiwenlau@gmail.com>

# install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server openjdk-7-jdk wget

# install hadoop 2.7.2
RUN wget https://github.com/kiwenlau/compile-hadoop/releases/download/2.7.2/hadoop-2.7.2.tar.gz && \
    tar  -xzvf hadoop-2.7.2.tar.gz && \
    mv hadoop-2.7.2 /usr/local/hadoop && \
    rm hadoop-2.7.2.tar.gz

# copy hadoop configuration files
COPY config/* /tmp/ 

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    mv /tmp/ssh_config ~/.ssh/config

ENV HADOOP_INSTALL /usr/local/hadoop

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_INSTALL/logs

RUN mv /tmp/.bashrc ~/.bashrc && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \ 
    mv /tmp/hdfs-site.xml $HADOOP_INSTALL/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_INSTALL/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_INSTALL/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_INSTALL/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_INSTALL/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_INSTALL/sbin/start-dfs.sh && \
    chmod +x $HADOOP_INSTALL/sbin/start-yarn.sh && \
    chmod 1777 /tmp

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

WORKDIR /root

# EXPOSE 8030 8031 8032 8033 8040 8042 8060 8088 9000 50010 50020 50060 50070 50075 50090 50475

CMD [ "sh", "-c", "service ssh start; bash"]

