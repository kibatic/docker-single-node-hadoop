FROM debian:jessie

MAINTAINER Philippe Le Van <philippe.levan [at] kitpages.fr>

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

# install ssh and run through supervisor
RUN apt-get install -y ssh supervisor
RUN mkdir /var/run/sshd
RUN ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
RUN cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
RUN /usr/sbin/sshd && ssh-keyscan -H localhost >> /root/.ssh/known_hosts && ssh-keyscan -H 127.0.0.1 >> /root/.ssh/known_hosts
ADD config/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# copy hadoop configs
ADD config/root_bashrc_hadoop.source /root/.bashrc
ADD docker/start.sh /root/start.sh
RUN mkdir /etc/hadoop
ADD config/etc_hadoop_core-site.xml /etc/hadoop/core-site.xml
ADD config/etc_hadoop_yarn-site.xml /etc/hadoop/yarn-site.xml
ADD config/etc_hadoop_mapred-site.xml /etc/hadoop/mapred-site.xml
ADD config/etc_hadoop_hdfs-site.xml /etc/hadoop/hdfs-site.xml
RUN chmod u+x /root/start.sh


# slave management
ADD config/etc_hadoop_slaves /etc/hadoop/slaves

# copy example files
RUN mkdir /example
ADD example/fichier.txt /example/fichier.txt
ADD example/mapper.py /example/mapper.py
ADD example/reducer.py /example/reducer.py
RUN chmod a+x /example/*.py

# Cleanup of installation files
#RUN \
#  apt-get clean && \
#  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
#  rm -rf /var/cache/oracle-jdk7-installer

CMD [ "/root/start.sh" ]
#CMD [ "/bin/bash" ]
