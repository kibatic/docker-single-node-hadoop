#!/usr/bin/env bash

# constants
IS_HDFS_FORMATED_FILE=/data/hdfs/is_hdfs_formatted.txt

# defines env, path,...
source /root/.bashrc

# format hdfs node
if [ ! -f "$IS_HDFS_FORMATED_FILE" ]; then
    echo "try to format"
    $HADOOP_PREFIX/bin/hdfs namenode -format -nonInteractive
    echo "hdfs formated" > $IS_HDFS_FORMATED_FILE
    echo `date` >> $IS_HDFS_FORMATED_FILE
fi

# create directories for hive
hdfs dfs -ls /tmp
rc=$?; if [[ $rc != 0 ]]; then hdfs dfs -mkdir -p /tmp ; fi
hdfs dfs -ls /user/hive/warehouse
rc=$?; if [[ $rc != 0 ]]; then hdfs dfs -mkdir -p /user/hive/warehouse ; fi


# start ssh
/usr/sbin/sshd
# start hdfs
$HADOOP_PREFIX/sbin/start-dfs.sh
# start yarn
$HADOOP_PREFIX/sbin/start-yarn.sh

# start supervisord for sshd
/usr/bin/supervisord
