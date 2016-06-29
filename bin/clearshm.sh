#!/bin/bash

TOOLS_HOME=/home/zc/sparkdir/centos-SparkDeployTools

$TOOLS_HOME/multi_ops/mexec -f $TOOLS_HOME/multi_ops/user_host_passwds -c "for shmid in \\\$(ipcs -m | awk '\\\$6==0 {print \\\$2}');do ipcrm -m \\\$shmid; done"
