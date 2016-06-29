#!/bin/bash

if [ $# -lt 1 ]; then
  echo "usage: logDownloader.sh [downloadMetrics|clearAllLogs|clearYarnLogs|clearHdfsLogs|clearAppLogs|clearZCLogs|clearHDFS|downloadWorkFiles]"
  exit
fi

THIS=`dirname "$0"`
THIS=`cd "$THIS"; pwd`
THIS=`readlink -f $THIS`
rootdir=`cd "$THIS";cd ../; pwd`

CONF_FILE="logHostsInfo-spark"

LOG_DIR_BASENAME=$rootdir/result/sparkMetrics

SPARK_BASE=/home/zc/sparkdir
SPARK_DIR_NAME=${SPARK_BASE}/spark-hadoop-2.3.0
SPARK_METRICS_DIR=${SPARK_BASE}/monitor

now=$(date "+%Y-%m-%d-%H-%M-%S")

OPTION=$1

case $OPTION in

"clearAllMetrics" )

for p in $(sed 's/ //g' "$rootdir/config/$CONF_FILE")
do
     
    if [[ "${p:0:1}" == "#" ]]; then
      continue;
    fi

      USERNAME=$(echo "$p"|cut -f1 -d":")
      HOSTNAME=$(echo "$p"|cut -f2 -d":")
      PASSWORD=$(echo "$p"|cut -f3 -d":")
      
      expect -c "
        spawn ssh $USERNAME@$HOSTNAME \"rm -rf $SPARK_METRICS_DIR/*;\"
          expect {
	      \"*yes/no*\" {send \"yes\r\"; exp_continue}
	      \"*password*\" {send \"$PASSWORD\r\"; exp_continue}
          }
      "
done

;;


"downloadMetrics" )

CONF_DOWNLOADED=false
FORMER_USERBASE_REMOVED=false

for p in $(sed 's/ //g' "$rootdir/config/$CONF_FILE")
  do
    
    if [ "${p:0:1}" = "#" ]; then
      continue;
    fi
  

    USERNAME=$(echo "$p"|cut -f1 -d":")
    HOSTNAME=$(echo "$p"|cut -f2 -d":")
    PASSWORD=$(echo "$p"|cut -f3 -d":")
    SPARKROLE=$(echo "$p"|cut -f4 -d":")
    # HDFSROLE=$(echo "$p"|cut -f5 -d":")

    if [ ${p:0:1} == "#" ]; then
      continue;
    fi
    
    USER_BASE=${LOG_DIR_BASENAME}_${USERNAME}
    # echo "\$USER_BASE=$USER_BASE"
    
    if [[ ${FORMER_USERBASE_REMOVED} == false ]]; then
		  if [ -d $USER_BASE ]; then
		  	mv ${USER_BASE} ${USER_BASE}_$now
		  fi
		  FORMER_USERBASE_REMOVED=true
		fi

    if [ ! -d $USER_BASE ]; then
      mkdir $USER_BASE  
    fi

    if [ ! -d $USER_BASE/worker ]; then
      mkdir $USER_BASE/worker
    fi

    if [ ! -d $USER_BASE/executor ]; then
      mkdir $USER_BASE/executor
    fi

    if [ ! -d $USER_BASE/shm ]; then
      mkdir $USER_BASE/shm
    fi
    
    if [[ ${CONF_DOWNLOADED} == false ]]; then
  		# copy configures to local
			if [ ! -d $USER_BASE/etc ]; then
		  	mkdir $USER_BASE/etc
		  fi
      expect -c "
        set timeout 36000
        spawn scp -r $USERNAME@$HOSTNAME:$SPARK_HOME/conf/ $USER_BASE/etc/
        expect {
      		\"*yes/no*\" {send \"yes\r\"; exp_continue}
       	  \"*password*\" {send \"$PASSWORD\r\"; exp_continue}
        }
      "
  		CONF_DOWNLOADED=true
  	fi

    # download master
    if [ $SPARKROLE == "master" ]; then
      sleep 1
    elif [ $SPARKROLE == "worker" ]; then
      # copy executor metrics to local
      expect -c "
        set timeout 36000
        spawn scp $USERNAME@$HOSTNAME:$SPARK_METRICS_DIR/app-*.executor.memory.memoryUsedRate.csv $USER_BASE/executor
        expect {
      		\"*yes/no*\" {send \"yes\r\"; exp_continue}
      		\"*password*\" {send \"$PASSWORD\r\"; exp_continue}
        }
      "
      # copy executor metrics to local
      expect -c "
        set worker 36000
        spawn scp $USERNAME@$HOSTNAME:$SPARK_METRICS_DIR/worker.memNodeFree_MB.csv $USER_BASE/worker/$HOSTNAME.memNodeFree_MB.csv
        expect {
          \"*yes/no*\" {send \"yes\r\"; exp_continue}
          \"*password*\" {send \"$PASSWORD\r\"; exp_continue}
        }
      "
      ssh $USERNAME@$HOSTNAME "ipcs -m | awk '\$6==0 && \$3=\"zc\" {print \$2,\$5}' OFS=," > $USER_BASE/shm/$HOSTNAME.csv


    fi
  
done

;;

"downloadWorkFiles")

	for p in $(sed 's/ //g' "$rootdir/config/$CONF_FILE")
    do
    
		  if [ "${p:0:1}" = "#" ]; then
		    continue;
		  fi

      USERNAME=$(echo "$p"|cut -f1 -d":")
      HOSTNAME=$(echo "$p"|cut -f2 -d":")
      PASSWORD=$(echo "$p"|cut -f3 -d":")
      # YARNROLE=$(echo "$p"|cut -f4 -d":")
      # HDFSROLE=$(echo "$p"|cut -f5 -d":")
      
      
      if [ -z "$HADOOP_HOME" ]; then HADOOP_HOME="/home/$USERNAME/$HADOOP_DIR_NAME"; fi
      if [ -z "$HADOOP_LOG_DIR" ]; then HADOOP_LOG_DIR="$HADOOP_HOME/logs"; fi
      if [ -z "$APP_LOCAL_DIR" ]; then APP_LOCAL_DIR="/home/$USERNAME/data/yarn/local"; fi

      if [ ${p:0:1} == "#" ]; then
        continue;
      fi
      
      USER_BASE=${LOG_DIR_BASENAME}_${USERNAME}
      # echo "\$USER_BASE=$USER_BASE"
      
      if [ ! -d $USER_BASE ]; then
      	mkdir $USER_BASE
      fi
    
      if [ ! -d $USER_BASE/$HOSTNAME ]; then
        mkdir $USER_BASE/$HOSTNAME
      fi

      if [ ! -d $USER_BASE/$HOSTNAME/app_local_dir ]; then
        mkdir $USER_BASE/$HOSTNAME/app_local_dir
      fi

      #copy ApplicationMasterLogs if possible
      expect -c "
        set timeout 3600
        spawn scp -r $USERNAME@$HOSTNAME:$APP_LOCAL_DIR/* $USER_BASE/$HOSTNAME/app_local_dir
        expect {
          \"*yes/no*\" {send \"yes\r\"; exp_continue}
          \"*password*\" {send \"$PASSWORD\r\"; exp_continue}
        }
      "
done
esac



