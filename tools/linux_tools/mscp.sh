#!/bin/bash
export CUR_NAME=`whoami`

function usage(){
    echo "Usage:$0 ip_config_file dir/file local_path remote_dir"
}

function file_not_found(){
    echo "the node config file not found"
}
#Check if the count of params is leagle
if [ $# -lt 4 ] || [ "$1" = "-help" ]
then
    usage
    exit
fi

ip_list_file=$1
scp_type=$2
local_path=$3
remote_dir=$4

#check if the passwd config file is leagle
if [ ! -f $ip_list_file ]; then
    file_not_found
    exit
fi

#generate ssh keys on all nodes in config file
for config_line in $(sed 's/ //g' $ip_list_file)
do
    #ignore the '#'
    if [ ${config_line:0:1} == "#" ] 
    then
        continue;
    fi
    ip=`echo "$config_line" | cut -f1 -d "="`
    echo "on ip $ip execute the cp the $local_path to $remote_dir"
    ssh $CUR_NAME@$ip mkdir -p $remote_dir
    if [[ $scp_type = "dir" ]]; then
        scp -r $local_path $CUR_NAME@$ip:$remote_dir/
    else
        scp $local_path $CUR_NAME@$ip:$remote_dir/
    fi
    echo "finish"

done
echo "all finish"