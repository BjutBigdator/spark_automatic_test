#!/bin/bash 

# total group instance(job) number is 1

sed -i "/INPUT_HDFS=/ c INPUT_HDFS=hdfs://centos1:9000/SparkBench/KMeans/Input0" /usr/home/BryantChang/spark-bench/KMeans/conf/env.sh
sed -i "/OUTPUT_HDFS=/ c INPUT_HDFS=hdfs://centos1:9000/SparkBench/KMeans/Output0" /usr/home/BryantChang/spark-bench/KMeans/conf/env.sh
sed -i "/SPARK_EXECUTOR_MEMORY=/ c SPARK_EXECUTOR_MEMORY=1g" /usr/home/BryantChang/spark-bench/KMeans/conf/env.sh
sed -i "/SPARK_WORKER_CORES=/ c SPARK_WORKER_CORES=1" /usr/home/BryantChang/spark-bench/KMeans/conf/env.sh
sed -i "/SPARK_STORAGE_MEMORYFRACTION=/ c SPARK_STORAGE_MEMORYFRACTION=0.15" /usr/home/BryantChang/spark-bench/KMeans/conf/env.sh
sed -i 's///g' /usr/home/BryantChang/spark-bench/KMeans/conf/env.sh
sh /usr/home/BryantChang/spark-bench/KMeans/bin/run.sh &
sleep 14

# average arrival time in workload is 14.0
