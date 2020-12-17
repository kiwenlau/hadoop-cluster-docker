FROM centos:7

MAINTAINER KiwenLau <kiwenlau@gmail.com>
MAINTAINER Sven Augustus <zeno531@outlook.com>

WORKDIR /root

RUN yum install -y \
	java-1.8.0-openjdk \
	java-1.8.0-openjdk-devel \
	openssh-server \
	openssh-clients \ 
	gnupg \
	net-tools \ 
	curl \
	wget

RUN curl -O https://dist.apache.org/repos/dist/release/hadoop/common/KEYS \
    && gpg --import KEYS

ENV HADOOP_VERSION 3.2.1
ENV HADOOP_URL https://mirror-hk.koddos.net/apache/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ENV HADOOP_ASC_URL https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz.asc

RUN set -x \
    && curl -fSL "$HADOOP_URL" -o hadoop.tar.gz \
    && curl -fSL "$HADOOP_ASC_URL" -o hadoop.tar.gz.asc \
    && gpg --verify hadoop.tar.gz.asc \
    && tar -xvf hadoop.tar.gz -C /usr/local/ \
	&& mv /usr/local/hadoop-$HADOOP_VERSION /usr/local/hadoop \
    && rm hadoop.tar.gz*

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_DATA_HOME=/var/lib/hadoop 
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 

# docker support '/usr/sbin/sshd' for centos
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config \
    && ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' \
    && ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N ''

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ''  \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p $HADOOP_DATA_HOME/dfs/name \ 
    && mkdir -p $HADOOP_DATA_HOME/dfs/data  \
    && mkdir -p $HADOOP_DATA_HOME/yarn/timeline  \
    && mkdir $HADOOP_HOME/logs

COPY config/etc-hadoop/* /tmp/etc-hadoop/
COPY config/quick-script/* /tmp/quick-script/

RUN mv /tmp/quick-script/ssh_config ~/.ssh/config \
    && mv /tmp/quick-script/*.sh ~/  \
    && chmod +x ~/*.sh \
    && mv /tmp/etc-hadoop/* $HADOOP_HOME/etc/hadoop/ \
    && chmod +x $HADOOP_HOME/sbin/*.sh

# format namenode
RUN $HADOOP_HOME/bin/hdfs namenode -format

CMD [ "sh", "-c", "/usr/sbin/sshd; bash"]
