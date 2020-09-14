#!/bin/bash

#while true; do sleep 1000; done

export JAVA_HOME=/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64
export HADOOP_HOME=/opt/hadoop
export HIVE_HOME=/opt/hive
export SPARK_HOME=/opt/spark
export HADOOP=/opt/hadoop/bin/hadoop

${SPARK_HOME}/bin/spark-class org.apache.spark.deploy.worker.Worker spark://master:7077
