#!/bin/bash
ROS_HOST="192.168.1.1"
ROS_USER="admin"
ROS_PASSWD="admin"
INTERFACE=""

API_KEY=""
SECRET_KEY=""
DOMAIN=""
DEBUG=0

usage() {
cat<<EOF
Usage: 
    ./ros-update-cloudxns-ddns.sh -h "ROS_HOST" -u "USER" -p "PASSWD" -k "APP-KEY" -s "SECRET-KEY" -d "DOMAIN" -i "INTERFACE"

    -h|--host
    -u|--user
    -p|--password
    -k|--api-key
    -s|--secret-key
    -d|--domain
    -i|--interface
    -v|--debug
    -h|--help
EOF
	exit 1; 
}

ARGS=`getopt -o h:u:p:k:s:d:i:vh -l host:,user:,password:,api-key:,secret-key:,domain:,interface:,debug,help -n ros-update-cloudxns-ddns.sh -- "$@"`
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
		-k|--api-key)
			API_KEY=$2
			shift
			;;
		-s|--secret-key)
			SECRET_KEY=$2
			shift
			;;
		-d|--domain)
			DOMAIN=$2
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

if [ $DEBUG -eq 1 ]; then
cat<<EOF
CloudXNS DDNS script debug info.
      ROS Host: $ROS_HOST
      ROS User: $ROS_USER
  ROS Password: $ROS_PASSWD
     Interface: $INTERFACE
       API KEY: $API_KEY
    SECRET KEY: $SECRET_KEY
        DOMAIN: $DOMAIN
    Debug Mode: $DEBUG
EOF
fi

TARGET_IP=`sshpass -p $ROS_PASSWD ssh -o "StrictHostKeyChecking no" $ROS_USER@$ROS_HOST "/ip address print where interface=$INTERFACE" | grep -Po "([0-9.]+)/[0-9]+" | awk -F "/" '{print $1}' | head -n 1`

URL="https://www.cloudxns.net/api2/ddns"
CURRENT_TIME=$(date -R)
POST_DATA="{\"domain\":\"${DOMAIN}\",\"ip\":\"${TARGET_IP}\",\"line_id\":\"1\"}"

API_HMAC_RAW="$API_KEY$URL$POST_DATA$CURRENT_TIME$SECRET_KEY"
API_HMAC=$(echo -n $API_HMAC_RAW | md5sum | awk '{print $1}')

HEADER_1="API-KEY:"$API_KEY
HEADER_2="API-REQUEST-DATE:"$CURRENT_TIME
HEADER_3="API-HMAC:"$API_HMAC
HEADER_4="API-FORMAT:json"

if [ $DEBUG -eq 1 ]; then
	RESULT=$(curl -k -X POST -H $HEADER_1 -H "$HEADER_2" -H $HEADER_3 -H $HEADER_4 -d "$POST_DATA" $URL)
else
	RESULT=$(curl -s -k -X POST -H $HEADER_1 -H "$HEADER_2" -H $HEADER_3 -H $HEADER_4 -d "$POST_DATA" $URL)
fi

if  [[ $(echo $RESULT | grep "success") != "" ]] ;then
	if [ $DEBUG -eq 1 ]; then
		echo "CloudXNS DDNS update success Domain: $DOMAIN  IP: $TARGET_IP"
	else
		logger -t NOTICE "CloudXNS DDNS update success Domain: $DOMAIN  IP: $TARGET_IP"
	fi
else
	if [ $DEBUG -eq 1 ]; then
		echo "CloudXNS DDNS update fail Domain: $DOMAIN  IP: $TARGET_IP"
	else
		logger -t NOTICE "CloudXNS DDNS update fail Domain: $DOMAIN  IP: $TARGET_IP"
	fi
fi