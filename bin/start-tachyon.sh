#!/bin/bash

export TACHYON_HOME=/home/zc/sparkdir/tachyon-0.5.0
export TACHYON_MASTER=centos1

expect -c "
          spawn ssh root@$TACHYON_MASTER \"$TACHYON_HOME/bin/tachyon-start.sh all Mount\"
            expect {
              \"*yes/no*\" {send \"yes\r\"; exp_continue}
              \"*password:*\" {send \"123456\r\"; exp_continue}
            }
        "
sleep 1


# Add write authority
expect -c "
          spawn ssh root@centos25 \"chmod -R a+w /mnt/ramdisk/tachyonworker\"
            expect {
              \"*yes/no*\" {send \"yes\r\"; exp_continue}
              \"*password:*\" {send \"123456\r\"; exp_continue}
            }
        "


