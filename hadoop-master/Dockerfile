FROM kiwenlau/hadoop-base:1.0.0

MAINTAINER KiwenLau <kiwenlau@gmail.com>

# move all confugration files into container
COPY files/* /tmp/

ENV HADOOP_INSTALL /usr/local/hadoop

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_INSTALL/logs

RUN mv /tmp/hdfs-site.xml $HADOOP_INSTALL/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_INSTALL/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_INSTALL/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_INSTALL/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_INSTALL/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh && \ 
    mv /tmp/start-ssh.sh ~/start-ssh.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x ~/start-ssh.sh && \
    chmod +x $HADOOP_INSTALL/sbin/start-dfs.sh && \
    chmod +x $HADOOP_INSTALL/sbin/start-yarn.sh && \
    chmod 1777 tmp

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD '/root/start-ssh.sh'; 'bash'
