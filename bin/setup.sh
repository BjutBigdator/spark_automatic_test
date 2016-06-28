#!/bin/bash
THIS=`dirname "$0"`
THIS=`cd "$THIS"; pwd`
THIS=`readlink -f $THIS`
rootdir=`cd "$THIS";cd ../; pwd`
CUR_NAME=`whoami`

#user setting
HADOOP_HOME=/hadoop_dir
SPARK_HOME=/home/zc/sparkdir/spark-hadoop2.3
TACHYON_HOME=$SPARK_HOME/tachyon-0.5.0
SPARK_MASTER=centos1
SPARK_BENCH_HOME=/home/zc/sparkdir/spark-bench
SPARK_WORKER_MEMORY=22g
SPARK_WORKER_MEMORY_TACHYON=16g
tools_dir=$rootdir/tools
faction_file=$rootdir/config/experiment_config/factions.conf

function usage() {
	echo "usage: $0 spark_version log_path if_use_faction_conf faction_conf_file"
}

if [[ $# -lt 3 ]]; then
	usage
	exit
fi

spark_version=$1
log_path=$2



# echo "start to set up the $spark_version" >> $log_path 2>&1

# echo "stop spark" >> $log_path 2>&1
# ssh $CUR_NAME@$SPARK_MASTER sh $SPARK_HOME/sbin/stop-all.sh >> $log_path 2>&1
# echo "stop tachyon" >> $log_path 2>&1
# # ssh $CUR_NAME@$SPARK_MASTER sh $TACHYON_HOME/bin/tachyon-stop.sh
# echo "modify spark_default" >> $log_path 2>&1
# sed -i "/spark.eventLog.enabled/ c spark.eventLog.enabled \t\t true" $SPARK_HOME/conf/spark-defaults.conf

declare -a name
declare -a path

faction_no=$3

for p in $(sed 's/ //g' $faction_file) 
do
	if [[ "${p:0:1}" = "#" ]]; then
		continue;
	elif [[ "${p:0:4}" == "name" ]]; then
		param_count=$(echo "$p"|cut -f2 -d":")
		param_names=$(echo "$p"|cut -f3 -d":")
		for (( i = 1; i <= $param_count; i++ )); do
			name[$i]=$(echo $param_names|cut -d ";" -f$i)
		done
	elif [[ "${p:0:4}" == "path" ]]; then
		param_paths=$(echo "$p"|cut -f3 -d":")
		for (( i = 1; i <= $param_count; i++ )); do
			path[$i]=$(echo $param_paths|cut -d ";" -f$i)
		done
	else
		faction_no_in_file=$(echo "$p"|cut -f1 -d":")
		if [[ $faction_no -ne $faction_no_in_file ]]; then
			continue
		else
			factions=$(echo "$p"|cut -f2 -d":")
			for (( i = 1; i <= $param_count; i++ )); do
				faction=$(echo "$factions"|cut -f$i -d";")
				echo "sed -i \"/${name[$i]}=/ c export ${name[$i]}=$faction\" ${path[$i]}"
			done
		fi
	fi
done






# if [[ $spark_version == "spark" ]]; then
# 	sed -i "/spark.smspark.enable/ c spark.smspark.enable \t\t false" $SPARK_HOME/conf/spark-defaults.conf
# 	sed -i "/STORAGE_LEVEL=/ c STORAGE_LEVEL=MEMORY_ONLY" $SPARK_BENCH_HOME/conf/env.sh
# 	sed -i "/SPARK_WORKER_MEMORY=/ c export SPARK_WORKER_MEMORY=$SPARK_WORKER_MEMORY" $SPARK_HOME/conf/spark-env.sh
# 	sh $tools_dir/linux_tools/mscp.sh $tools_dir/linux_tools/passwd_config file $SPARK_HOME/conf/spark-env.sh $SPARK_HOME/conf/

# elif [[ $spark_version == "smspark" ]]; then
# 	sed -i "/spark.smspark.enable/ c spark.smspark.enable \t\t true" $SPARK_HOME/conf/spark-defaults.conf
# 	sed -i "/STORAGE_LEVEL=/ c STORAGE_LEVEL=OFF_HEAP" $SPARK_BENCH_HOME/conf/env.sh
# 	sed -i "/SPARK_WORKER_MEMORY=/ c export SPARK_WORKER_MEMORY=$SPARK_WORKER_MEMORY" $SPARK_HOME/conf/spark-env.sh
# 	sh $tools_dir/linux_tools/mscp.sh $tools_dir/linux_tools/passwd_config file $SPARK_HOME/conf/spark-env.sh $SPARK_HOME/conf/

# elif [[ $spark_version == "tachyon" ]]; then
# 	sed -i "/spark.smspark.enable/ c spark.smspark.enable \t\t false" $SPARK_HOME/conf/spark-defaults.conf
# 	sed -i "/STORAGE_LEVEL=/ c STORAGE_LEVEL=OFF_HEAP" $SPARK_BENCH_HOME/conf/env.sh
# 	sed -i "/SPARK_WORKER_MEMORY=/ c export SPARK_WORKER_MEMORY=$SPARK_WORKER_MEMORY_TACHYON" $SPARK_HOME/conf/spark-env.sh
# 	echo "now restart tachyon"
# 	ssh $CUR_NAME@$SPARK_MASTER sh $TACHYON_HOME/bin/tachyon-start.sh all SudoMount 
# 	sh $tools_dir/linux_tools/mscp.sh $tools_dir/linux_tools/passwd_config file $SPARK_HOME/conf/spark-env.sh $SPARK_HOME/conf/
# fi
# echo "now start spark"
# ssh $CUR_NAME@$SPARK_MASTER sh $SPARK_HOME/sbin/start-all.sh >> $log_path 2>&1
# sleep 2



