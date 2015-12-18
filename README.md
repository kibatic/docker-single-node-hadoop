Docker for a single node hadoop installation
============================================

This repository is used to create an hadoop single instance following the documentation on this page :
http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html and the doc
of spark.

Features :

* hadoop / hdfs
* yarn
* spark
* hive
* zeppelin

State of the project :

* Hadoop, yarn, spark, hive, zeppelin : running, not optimized. I'm interested by any feedback.

Quickstart
----------

### clone the project

```bash
git clone https://github.com/kibatic/docker-single-node-hadoop.git
```

### create the container

```
docker-compose build
docker-compose up -d
```

### Zeppelin notebook

You can access to Zeppelin at http://localhost:8002

### Run a basic map reduce example

We put some python map reduce examples in the /example dir inside the container

```bash
docker exec -ti dockersinglenodehadoop_hsn_1 bash

cd /example
hdfs dfs -mkdir /input
hdfs dfs -put fichier.txt /input
hadoop jar /usr/local/hadoop/share/hadoop/tools/lib/hadoop-streaming-2.7.1.jar -input /input -output /output -mapper /example/mapper.py -reducer /example/reducer.py
hdfs dfs -cat /output/part-00000
```

### run the same basic map reduce with spark

```bash
docker exec -ti dockersinglenodehadoop_hsn_1 bash

cd /example
hdfs dfs -mkdir /input
hdfs dfs -put fichier.txt /input

# run pyspark
pyspark
```

```python
# load file
file = sc.textFile("/input/fichier.txt")
file.collect()

# mapping
def split_words(line):
    return line.split()
def create_pair(word):
    return (word,1)
pairs=file.flatMap(split_words).map(create_pair)

# reducing
def sum_counts(a,b):
    return a+b
wordcount = pairs.reduceByKey(sum_counts)

# display result
wordcount.collect()
```

Features
--------

### Lancer, arrêter le container

```
docker-compose start
docker-compose stop
```

### volume /data in the ./data_docker directory

This directory is a shared volume with the /data of the container.

In this directory we have :

* /data/hdfs for hdfs files
* /data/yarn for yarn files
* /data/transfert just for easy tranfert between the host and the container.

Run container manually from dockerfile
--------------------------------------

Lancer le container et entrer dedans

```bash
docker build -t hsn .
docker run --rm --name hsn hsn
# entrer dans le docker
docker exec -ti hsn bash
```

Arrêter le container

```bash
docker stop hsn
```
