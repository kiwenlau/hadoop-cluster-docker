FROM kiwenlau/hadoop-base:1.0

MAINTAINER KiwenLau <kiwenlau@gmail.com>

# move all confugration /tmp into container
ADD files/* /tmp/

ENV HADOOP_INSTALL /usr/local/hadoop

RUN mkdir $HADOOP_INSTALL/logs

RUN mv /tmp/hdfs-site.xml $HADOOP_INSTALL/etc/hadoop/hdfs-site.xml && \
    mv /tmp/core-site.xml $HADOOP_INSTALL/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_INSTALL/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_INSTALL/etc/hadoop/yarn-site.xml

CMD [ "sh", "-c", "service ssh start; bash"]
