#!/bin/bash
THIS=`dirname "$0"`
THIS=`cd "$THIS"; pwd`
THIS=`readlink -f $THIS`
rootdir=`cd "$THIS";cd ../; pwd`

function usage() {
	echo "usage: $0 workload_source_conf_path dest_path env_path lib_path cpu_mem_no faction1 faction2 prediction_step log_path"
}

if [[ $# -lt 9 ]]; then
	usage
	exit
fi

#assign the parameters
workload_source_conf=$1
dest_shell_name=$2
env_path=$3
lib_path=$4
cpu_mem_no=$5
faction1=$6
faction2=$7
prediction_step=$8
log_path=$9

echo "----------generating the script-------------------" >> $log_path 2>&1 

OPTS="--conf $env_path --source $workload_source_conf --dest $dest_shell_name --lambda 10 --genRandInterval 500 --useHistory false --history 111 --cpu_mem $cpu_mem_no --useExtendParams false"
touch $dest_shell_name

echo "The opts of java is:$OPTS" >> $log_path 2>&1
java -classpath $lib_path bryantchang.workload.generator.GenWorkload $OPTS >> $log_path 2>&1
if [[ $? -eq 0 ]]; then
	echo "script generate complete" >>  $log_path 2>&1
fi

