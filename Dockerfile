FROM debian:jessie

MAINTAINER Philippe Le Van <philippe.levan [at] kibatic.com>

# install base
RUN apt-get update && apt-get -y install \
    apt-utils \
    curl \
    wget \
    git \
    htop \
    vim \
    rsync

# install python
RUN apt-get install -y python

# Install Java.
RUN \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    apt-get update && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes oracle-java7-installer oracle-java7-set-default

# download hadoop
RUN \
    echo "load hadoop (200MB)" && wget -q -O /root/hadoop.tar.gz http://apache.crihan.fr/dist/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz && \
    echo "untar file" && cd /root && tar zxf hadoop.tar.gz && \
    mv hadoop-2.7.1 /usr/local/hadoop
# download spark
RUN \
    echo "load spark (184MB)" && \
    wget -q -O /root/spark-bin-without-hadoop.tgz http://wwwftp.ciril.fr/pub/apache/spark/spark-1.5.1/spark-1.5.1-bin-without-hadoop.tgz
RUN cd /root && tar zxf spark-bin-without-hadoop.tgz
RUN mv /root/spark-1.5.1-bin-without-hadoop /usr/local/spark


# install ssh and run through supervisor
RUN apt-get install -y ssh supervisor
RUN mkdir /var/run/sshd
RUN ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
RUN cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
RUN /usr/sbin/sshd && ssh-keyscan -H localhost >> /root/.ssh/known_hosts && ssh-keyscan -H 127.0.0.1 >> /root/.ssh/known_hosts

# copy hadoop configs
ADD config/root_bashrc_hadoop.source /root/.bashrc
RUN mkdir /etc/hadoop
ADD config/etc_hadoop_core-site.xml /etc/hadoop/core-site.xml
ADD config/etc_hadoop_yarn-site.xml /etc/hadoop/yarn-site.xml
ADD config/etc_hadoop_mapred-site.xml /etc/hadoop/mapred-site.xml
ADD config/etc_hadoop_hdfs-site.xml /etc/hadoop/hdfs-site.xml
ADD config/etc_hadoop_capacity-scheduler.xml /etc/hadoop/capacity-scheduler.xml
RUN mkdir -p /data/yarn/nodemanager/log /data/yarn/nodemanager/data /data/hdfs/datanode /data/hdfs/namenode
RUN mkdir -p /data/transfert

# slave management
ADD config/etc_hadoop_slaves /etc/hadoop/slaves

# copy example files
RUN mkdir /example
ADD example/fichier.txt /example/fichier.txt
ADD example/mapper.py /example/mapper.py
ADD example/reducer.py /example/reducer.py
RUN chmod a+x /example/*.py

# install spark
ADD config/SPARK_HOME_conf_spark-env.sh /usr/local/spark/conf/spark-env.sh

# install hive
RUN \
    echo "load hive (90MB)" && wget -q -O /root/hive-bin.tar.gz http://apache.mirrors.ovh.net/ftp.apache.org/dist/hive/hive-1.2.1/apache-hive-1.2.1-bin.tar.gz && \
    echo "untar file" && cd /root && tar zxf hive-bin.tar.gz && \
    mv apache-hive-1.2.1-bin /usr/local/hive

# install zeppelin
RUN apt-get -y install \
    build-essential \
    libfontconfig

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash
RUN apt-get install -y nodejs
RUN \
    echo "load maven (8 MB)" && wget -q -O /root/maven-bin.tar.gz http://www.eu.apache.org/dist/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz && \
    echo "untar file" && cd /root && tar zxf maven-bin.tar.gz  -C /usr/local/ && \
    ln -s /usr/local/apache-maven-3.3.3/bin/mvn /usr/local/bin/mvn
RUN \
    echo "load zepplin (447 MB)" && wget -q -O /root/zeppelin-bin.tar.gz http://apache.crihan.fr/dist/incubator/zeppelin/0.5.5-incubating/zeppelin-0.5.5-incubating-bin-all.tgz && \
    echo "untar file" && cd /root && tar zxf zeppelin-bin.tar.gz  -C /usr/local/ && \
    ln -s /usr/local/zeppelin-0.5.5-incubating-bin-all /usr/local/zeppelin

RUN apt-get install -y telnet net-tools

ADD config/zeppelin-env.sh /usr/local/zeppelin/conf/zeppelin-env.sh

# configuration of supervisord
ADD config/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# add start script
ADD docker/start.sh /root/start.sh
RUN chmod u+x /root/start.sh

# install data
VOLUME ["/data"]

# Expose ports
# hdfs port
EXPOSE 9000
EXPOSE 8020
# namenode port
EXPOSE 50070
# Resouce Manager
EXPOSE 8032
EXPOSE 8088
# MapReduce JobHistory Server Web UI
EXPOSE 19888
# MapReduce JobHistory Server
EXPOSE 10020
# Zeppelin
EXPOSE 8080

# Cleanup of installation files
#RUN \
#  apt-get clean && \
#  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
#  rm -rf /var/cache/oracle-jdk7-installer

CMD [ "/root/start.sh" ]
#CMD [ "/bin/bash" ]
