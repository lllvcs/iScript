#!/bin/bash

ROS_HOST="192.168.1.1"
ROS_USER="admin"
ROS_PASSWD="admin"
LIST_NAME="chnroutes"
TMP_SCRIPT="/var/run/ros-update-chnroutes.sh"

DEBUG=0

usage() {
cat<<EOF
Usage: 
    ./ros-update-chnroutes.sh -h "host" -u "user" -p "password" -l "list-name"

    -h RouterOS host ip
    -u RouterOS login user
    -p RouterOS login password
    -l Firewall address-list name
    -t Temporary script path
    -d Debug mode
EOF
	exit 1; 
}

while getopts "h:u:p:l:t:" OPTITEM; do
	case "${OPTITEM}" in
		h)
			ROS_HOST=${OPTARG}
			;;
		u)
			ROS_USER=${OPTARG}
			;;
		p)
			ROS_PASSWD=${OPTARG}
			;;
		l)
			LIST_NAME=${OPTARG}
			;;
		t)
			TMP_SCRIPT=${OPTARG}
			;;
		d)
			DEBUG=1
			;;
		*)
			usage
			;;
	esac
done

if [ $DEBUG -eq 1 ]; then
cat<<EOF
Start update RouterOS address list.
    Host: $ROS_HOST
    Login User: $ROS_USER
    Login Password: $ROS_PASSWD
    List Name: $LIST_NAME
    Temporary script: $TMP_SCRIPT

    Downloading IP list, please wait.
EOF
fi

cat>$TMP_SCRIPT<<EOF
/ip firewall address-list remove [/ip firewall address-list find list="$LIST_NAME"]
EOF

curl -s 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | awk -v list_name=$LIST_NAME -F\| '{ printf("/ip firewall address-list add list=%s address=%s/%d\n", list_name, $4, 32-log($5)/log(2)) }' >> $TMP_SCRIPT

COUNT=`wc -l $TMP_SCRIPT | grep -oE "([0-9]+)"`
COUNT=`expr $COUNT - 1`

if [ $DEBUG -eq 1 ]; then
cat<<EOF
    Download success, Rules count: $COUNT
EOF
fi

if [ $COUNT -gt 10 ]; then
	if [ $DEBUG -eq 1 ]; then
		echo "    Insert rules, please wait."
		sshpass -p $ROS_PASSWD ssh -o "StrictHostKeyChecking no" $ROS_USER@$ROS_HOST < $TMP_SCRIPT
		echo "    Insert success."
	else
		sshpass -p $ROS_PASSWD ssh -o "StrictHostKeyChecking no" $ROS_USER@$ROS_HOST < $TMP_SCRIPT
	fi
	logger -t NOTICE "ROS update chnroutes success Count: $COUNT"
else
	if [ $DEBUG -eq 1 ]; then
		echo "    Download fail, count rules too less."
	fi
	logger -t NOTICE "ROS update chnroutes fail Count: $COUNT"
fi

if [ $DEBUG -eq 1 ]; then
	echo "    Remove temporary file: $TMP_SCRIPT"
	rm $TMP_SCRIPT
	echo "Done."
else
	rm $TMP_SCRIPT
fi