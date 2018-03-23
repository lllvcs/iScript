#!/bin/bash
ROS_HOST="192.168.1.1"
ROS_USER="admin"
ROS_PASSWD="admin"

usage() {
cat<<EOF
Usage: 
    ./ros-get-address.sh -h "ROS_HOST" -u "USER" -p "PASSWD" -i "INTERFACE"

    -h|--host
    -u|--user
    -p|--password
    -i|--interface
    -v|--debug
    -h|--help

Output(Multiline): 
    192.168.254.10
    192.168.1.254
EOF
	exit 1; 
}

ARGS=`getopt -o h:u:p:i:vh -l host:,user:,password:,interface:,debug,help -n ros-get-address.sh -- "$@"`
if [ $? != 0 ]; then
    usage
    exit 1
fi

eval set -- "$ARGS"

while true; do
	case "$1" in
		-h|--host)
			ROS_HOST=$2
			shift
			;;
		-u|--user)
			ROS_USER=$2
			shift
			;;
		-p|--password)
			ROS_PASSWD=$2
			shift
			;;
		-i|--interface)
			INTERFACE=$2
			shift
			;;
		-v|--debug)
			DEBUG=1
			;;
		-h|--help)
			usage
			exit 1
			;;
		--)
			shift
			break
			;;
		*)
			usage
			exit 1
			;;
	esac
shift
done

RESULT=`sshpass -p $ROS_PASSWD ssh -o "StrictHostKeyChecking no" $ROS_USER@$ROS_HOST "/ip address print where interface=$INTERFACE" | grep -Po "([0-9.]+)/[0-9]+" | awk -F "/" '{print $1}'`
echo "$RESULT"