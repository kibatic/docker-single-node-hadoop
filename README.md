Docker for a single node hadoop installation
============================================

This repository is used to create an hadoop single instance following the documentation on this page :
http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html

State of this dockerfile
------------------------

* HDFS and local map reducer are up and running.
* I still don't manage to make yarn work...

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

Run a basic map reduce example
------------------------------

When we are inside the container

```bash
cd /example
hdfs dfs -mkdir /input
hdfs dfs -put fichier.txt /input
hadoop jar /usr/local/hadoop/share/hadoop/tools/lib/hadoop-streaming-2.7.1.jar -input /input -output /output -mapper /example/mapper.py -reducer /example/reducer.py
hdfs dfs -cat /output/part-00000
```
