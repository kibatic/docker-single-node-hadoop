#!/usr/bin/env bash

# constants
IS_HDFS_FORMATED_FILE=/data/hdfs/is_hdfs_formatted.txt
ZEPPELIN_NOTEBOOK_DIR=/data/zeppelin/notebook

# defines env, path,...
source /root/.bashrc

# format hdfs node
if [ ! -f "$IS_HDFS_FORMATED_FILE" ]; then
    echo "try to format"
    $HADOOP_PREFIX/bin/hdfs namenode -format -nonInteractive
    echo "hdfs formated" > $IS_HDFS_FORMATED_FILE
    echo `date` >> $IS_HDFS_FORMATED_FILE
fi

# create Zeppelin notebook dir
if [ ! -d $ZEPPELIN_NOTEBOOK_DIR ]; then
    echo "create zeppelin notebook dir : $ZEPPELIN_NOTEBOOK_DIR"
    mkdir -p $ZEPPELIN_NOTEBOOK_DIR
    cp -rp /usr/local/zeppelin/notebook/* $ZEPPELIN_NOTEBOOK_DIR
fi


# start ssh
/usr/sbin/sshd
# start hdfs
$HADOOP_PREFIX/sbin/start-dfs.sh
# start yarn
$HADOOP_PREFIX/sbin/start-yarn.sh
# start Zeppelin
# hack warning : the pid detection is not ok in the zeppelin-daemon.sh start script. Then we prefer to use restart instead of start.
$ZEPPELIN_HOME/bin/zeppelin-daemon.sh restart

# create directories for hive
hdfs dfs -ls /tmp
rc=$?; if [[ $rc != 0 ]]; then hdfs dfs -mkdir -p /tmp ; fi
hdfs dfs -ls /user/hive/warehouse
rc=$?; if [[ $rc != 0 ]]; then hdfs dfs -mkdir -p /user/hive/warehouse ; fi

# start supervisord for sshd
/usr/bin/supervisord
