#!/bin/bash
SPARK_HOME=/home/zc/sparkdir/hadoop2.3
SPARK_MASTER=centos1
SPARK_CLIENT=centos25

THIS=`dirname "$0"`
THIS=`cd "$THIS"; pwd`
THIS=`readlink -f $THIS`
rootdir=`cd "$THIS";cd ../; pwd`
cur_usr=`whoami`

function usage() {
	echo "usage:$0 -op start/stop/restart/killall\n"
	echo "-h for help"
}
OPTION=$1

if [[ "$OPTION" == "-h" || "$OPTION" == "--help" || "$OPTION" == "-help" ]]; then
	usage
	exit
fi

if [[ "$OPTION" != "" && "$OPTION" != "-op" ]]; then
	usage
	exit
fi

if [[ "$OPTION" == "-op" ]]; then
	case $TARGET in
		"start" )
			ssh $cur_usr@$SPARK_MASTER sh $SPARK_HOME/sbin/start-all.sh
		;;
		"stop" )
			ssh $cur_usr@$SPARK_MASTER sh $SPARK_HOME/sbin/stop-all.sh
		;;
		"restart" )
			ssh $cur_usr@$SPARK_MASTER sh $SPARK_HOME/sbin/stop-all.sh
			ssh $cur_usr@$SPARK_MASTER sh $SPARK_HOME/sbin/start-all.sh
		;;
		"killall" )
			for pid in `jps | awk -F ' ' '$2!="Jps" {print $1}'`; do kill -9 $pid; done
		;;
		* )
			usage
			exit
		;;
	esac
	shift
	shift
fi