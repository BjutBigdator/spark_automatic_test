#!bin/bash

TACHYON_HOME=/home/zc/sparkdir/tachyon-0.5.0
TACHYON_MASTER=centos1
TOOLS_HOME=/home/zc/sparkdir/centos-SparkDeployTools

expect -c "
          spawn ssh root@$TACHYON_MASTER \"$TACHYON_HOME/bin/tachyon-stop.sh\"
            expect {
              \"*yes/no*\" {send \"yes\r\"; exp_continue}
              \"*password:*\" {send \"123456\r\"; exp_continue}
            }
        "
sleep 1
$TOOLS_HOME/multi_ops/mexec -f $TOOLS_HOME/multi_ops/user_host_passwds-root  -c "umount -f /mnt/ramdisk"
