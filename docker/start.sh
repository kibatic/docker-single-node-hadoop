#!/usr/bin/env bash

# constants
IS_HDFS_FORMATED_FILE=/root/is_hdfs_formatted.txt

# defines env, path,...
source /root/.bashrc

# format hdfs node
if [ ! -f "$IS_HDFS_FORMATED_FILE" ]; then
    $HADOOP_PREFIX/bin/hdfs namenode -format
    echo "hdfs formated" > $IS_HDFS_FORMATED_FILE
    echo `date` >> $IS_HDFS_FORMATED_FILE
fi

# start ssh
/usr/sbin/sshd
# start hdfs
$HADOOP_PREFIX/sbin/start-dfs.sh
# start yarn
$HADOOP_PREFIX/sbin/start-yarn.sh

# start supervisord for sshd
/usr/bin/supervisord
