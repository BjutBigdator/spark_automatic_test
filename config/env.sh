#!/bin/bash

# Configures for generate submit script.

##################
## DON'T MODIFY ##
##################

HADOOP_HOME=/hadoop_dir
SPARK_HOME=/home/zc/sparkdir
TACHYON_HOME=$SPARK_HOME/tachyon-0.5.0
SPARK_BENCH_HOME=/home/zc/sparkdir/spark-bench
DATA_HDFS_BASE=hdfs://centos1:9000/SparkBench
LAB_CONFIG_DIR=/home/zc/sparkdir/workload_gen/config/experiment_config
#################KMeans#######################
kmeans_executable_basedir=KMeans/bin
kmeans_config_basedir=KMeans/conf

#################PageRank#####################
pagerank_executable_basedir=PageRank/bin
pagerank_config_basedir=PageRank/conf

#################Sort##########################
sort_executable_basedir=KMeans/bin
sort_config_basedir=/KMeans/conf

#################Tpcds#########################
tpcds_executable_basedir=SQL/bin
tpcds_config_basedir=SQL/conf
tpcds_input_hdfs0=tpcds_bin_partitioned_textfile_2
tpcds_input_hdfs1=tpcds_bin_partitioned_textfile_8
tpcds_input_hdfs4=tpcds_bin_partitioned_textfile_30

##################LogisticRegression##############
lr_executable_basedir=LogisticRegression/bin
lr_config_basedir=LogisticRegression/conf

#################WordCount######################
wordcount_executable_basedir=KMeans/bin
wordcount_config_basedir=/KMeans/conf











