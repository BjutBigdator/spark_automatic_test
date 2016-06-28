#!/bin/bash
PLANCONF_NAME=plan.conf
THIS=`dirname "$0"`
THIS=`cd "$THIS"; pwd`
THIS=`readlink -f $THIS`
rootdir=`cd "$THIS";cd ../; pwd`


PLANCONF=$rootdir/config/$PLANCONF_NAME
CONFIG_DIR="$rootdir/config"
LOG_DIR="$rootdir/logs"
SCRIPT_TO_RUN_DIR="$rootdir/scripts_to_run"
now=$(date "+%Y-%m-%d-%H_%M_%S")
now_log="$LOG_DIR/$now.log"
touch $now_log

echo "--------The plan begins at $(date "+%Y-%m-%d %H:%M:%S")---------" >> $now_log 2>&1
echo "The config of plan is:$PLANCONF" >> $now_log 2>&1
echo "parse the plan" >> $now_log 2>&1
for p in $(sed 's/ //g' $PLANCONF)
do
	if [ "${p:0:1}" = "#" ]; then  #split the string from the most left
		continue
	fi
	workload_type=$(echo "$p"|cut -f1 -d"_")
	spark_version=$(echo "$p"|cut -f2 -d"_")
	cpu_mem_no=$(echo "$p"|cut -f3 -d"_")
	faction1=$(echo "$p"|cut -f4 -d"_")
	faction2=$(echo "$p"|cut -f5 -d"_")
	prediction_step=$(echo "$p"|cut -f6 -d"_")
	echo "now executing the $workload_type lab on cpu_mem group no $cpu_mem_no" >> $now_log 2>&1
	echo "now prepare the platform" >> $now_log 2>&1

	##prepare environment
	setup_ops="$spark_version $now_log"
	sh $rootdir/bin/setup.sh $setup_ops

	##generate the workloads
	workload_source_conf="$CONFIG_DIR/workload_$workload_type.conf"
	dest_shell_name="$SCRIPT_TO_RUN_DIR/workload_run_$workload_type_$cpu_mem_no.sh"
	lib_dir=$rootdir/lib/bryantchang-program.jar
	workload_gen_opts="$workload_source_conf $dest_shell_name $CONFIG_DIR/env.sh $lib_dir $cpu_mem_no $faction1 $faction2 $prediction_step $now_log"
	sh $rootdir/bin/workload_gen.sh $workload_gen_opts
done