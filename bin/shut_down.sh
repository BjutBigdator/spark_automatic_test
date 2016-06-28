#!/bin/bash
THIS=`dirname "$0"`
THIS=`cd "$THIS"; pwd`
THIS=`readlink -f $THIS`
rootdir=`cd "$THIS";cd ../; pwd`
cur_usr=`whoami`

function usage() {
	echo "$0 running_script"
}

running_script=$1
sh $rootdir/tools/spark_tools/spark_opts.sh -op killall
kill -9 $(ps -aux | grep $running_script)