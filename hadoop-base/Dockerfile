FROM ubuntu:14.04

MAINTAINER KiwenLau <kiwenlau@gmail.com>

# install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server openjdk-7-jdk wget

#install hadoop 2.30
RUN wget https://github.com/kiwenlau/compile-hadoop/releases/download/2.7.2/hadoop-2.7.2.tar.gz && \
    tar  -xzvf hadoop-2.7.2.tar.gz && \
    mv hadoop-2.7.2 /usr/local/hadoop && \
    rm hadoop-2.7.2.tar.gz

# set jave environment variable 
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64 
ENV PATH $PATH:$JAVA_HOME/bin

# copy hadoop configuration files
COPY files/* /usr/local/ 

#configure ssh free key access
RUN mkdir /var/run/sshd && \
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    mv /usr/local/ssh_config ~/.ssh/config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN mv /usr/local/bashrc ~/.bashrc && \
    mv /usr/local/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh 
