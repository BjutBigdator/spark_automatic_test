## 混合负载自动生成脚本

### 1、目录结构

```
-scripts
 -bin       ###执行脚本（可单独使用）
    -plan.sh            ###脚本执行主流程
    -setup.sh           ###环境切换，平台环境变量设置
    -workload_gen.sh    ###调用脚本生成模块
    -shutdown.sh        ###停止所有提交任务
 -config  ###配置文件
    -experiment_config  ###实验具体参数设置及变动(例如CPU和MEM的变化等)
        -cpu-mem
        -extra_param.conf
    -env.sh             ###相关环境变量（包括负载主目录，负载配置文件路径等）
    -plan.conf          ###实验计划配置，后续脚本将按此计划依次执行
    -workload_cpumem.conf ###应用配比文件（根据不同性质进行配置）
-lib    ###负载执行脚本jar包
-script_to_run  ###最终生成执行的脚本位置
-logs   ###生成过程中的行为日志
-tools  ###其余相关工具
    -linux_tools  ###系统相关工具（多为批量命令相关）
    -spark_tools  ###spark系统相关操作
```

### 2、配置文件使用及配置

#### 2.1 env.sh

主要作用：设置和负载生成脚本相关的参数如spark目录，tachyon目录本次实验主要使用spark-bench所以需要设置各个应用的可执行文件以及配置文件的路径，以方便脚本生成 ,文件的主要内容如下：

```bash
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
```
### 2.2 experiment_config

#### 2.2.1 cpu_mem
 
主要作用：该文件主要用于设置各个实验组的常规实验参数，如CPU，内存等，文件内容及格式如下：
 
```
##cpu&memory:
1 1,1g,0.15 3,1g,0.15 46,2g,0.15 46,4g,0.15 46,4g,0.15 92,12g,0.15 69,6g,0.15
```

#### 2.2.2 extra_param.conf

主要作用：除CPU，MEM外其余参数设置，主要需要设置名称，修改位置，以及具体的取值等，具体格式如下：

```
###statment
name:2:SPARK_WORKER_OPTS;SPARK_STORAGE_MEMORYFRACTION
path:2:$SPARK_HOME/conf/spark-env.sh;$SPARK_BENCH_HOME/conf/env.sh
1:"-Djava.library.path=/home/zc/sparkdir/spark-hadoop2.3/lib/native -Dspark.smspark.enable=true -Dspark.smspark.evict.factor1=0.5,0.5,0.2,0.2 -Dspark.smspark.evict.factor2=0.5,0.5,0.2,0.2 -Dspark.smspark.da.step=2";0.5
```
注意事项：name行和path行必须存在，用来表示所有需要修改的配置文件的变量名称和相关路径


### 2.3 plan.conf
 
主要作用：该文件是实验的主要计划配置，用户可以将所有需要进行的进行的实验按指定格式写入该文件，脚本将自动根据该计划执行相应的实验，该文件内容如下：

```
#format workloadType;platformversion;useHistory;historyfile;cpu-mem-config;extra_param_no

cpumem;spark;true;history_cpumem_1_1;1;1

#cpu：代表负载类型，有cpumem、IO、MIX。如果是cpu密集型
#spark_version spark版本--包括原生，对比对象等
#是否使用历史脚本 true/false
#若true则该字段为脚本名称 若为false则写0占位
#cpu-mem配置
#影响因子组号

```
 
### 2.4 workload_cpumem.conf

主要作用：该文件的主要作用是对应用进行配比，在总数量一定的应用中可以指定每一个区间应用的种类及个数，脚本将根据这些
配置生成最终需要执行的脚本，该文件内容如下：

```
# CPU--MEM Intensive
# format:jobid script_writer jobAmount
0 bryantchang.workload.generator.Tpcds1Script 36
1 bryantchang.workload.generator.Tpcds1Script 3
2 bryantchang.workload.generator.KMeansScript 5
3 bryantchang.workload.generator.PageRankScript 6
4 bryantchang.workload.generator.KMeansScript 2
5 bryantchang.workload.generator.Tpcds1Script 2
6 bryantchang.workload.generator.PageRankScript 6
```

## 3、 bin目录中各个脚本的使用方法
 
### 3.1 plan.sh

> * 参数  无参数
> * 预处理 将2中配置文件写全
> * 使用方法 sh bin/plan.sh

### 3.2 setup.sh

> * 参数  
>> * spark_version
>> * extra_param_no
>> * log_dir
> * 预处理 将该脚本开始处环境变量配好
> * 使用方法 sh bin/setup.sh spark extra_param_no log_dir

### 3.3 workload_gen.sh

> * 参数  
>> * workload_source_conf=$1
>> * dest_shell_name=$2
>> * env_path=$3
>> * lib_path=$4
>> * cpu_mem_no=$5
>> * use_history=$6
>> * history_file=$7
>> * log_path=$8
> * 预处理 将该脚本开始处环境变量配好
> * 使用方法 sh bin/workload_gen.sh workload_source_conf dest_shell_name env_path lib_path cpu_mem_no use_history history_file log_path

### 3.4 shut_down.sh

> * 参数  
>> * running_script  ##脚本自动生成的文件
> * 预处理 将该脚本开始处环境变量配好
> * 使用方法 sh bin/shutdown.sh running_script

## 4、 tools中脚本的使用方法

参见 [Linux系统小工具](https://github.com/BryantChang/linux-and-spark-tools)

