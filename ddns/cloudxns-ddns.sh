#!/bin/bash
API_KEY=""
SECRET_KEY=""
DOMAIN=""
INTERFACE=""
REMOTE_RESOLVE=0
TARGET_IP=""
DEBUG=0

usage() {
cat<<EOF
Usage: 
    ./cloudxns-ddns.sh --api-key "API_KEY" --secret-key "SECRET_KEY" -d "DOMAIN" -i "INTERFACE" -r

    -k|--api-key
    -s|--secret-key
    -d|--domain
    -i|--interface
    -r|--remote-resolve
    --address <ip address>
    -v|--debug
    -h|--help
EOF
	exit 1; 
}

ARGS=`getopt -o k:s:d:i:rvh -l api-key:,secret-key:,domain:,interface:,remote-resolve,debug,help,address: -n cloudxns-ddns.sh -- "$@"`
if [ $? != 0 ]; then
    usage
    exit 1
fi

eval set -- "$ARGS"

while true; do
	case "$1" in
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
		-r|--remote-resolve)
			REMOTE_RESOLVE=1
			;;
		--address)
			TARGET_IP=$2
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

if [ -z $TARGET_IP ]; then
	if [ $REMOTE_RESOLVE -eq 1 ]; then
		if [ $DEBUG -eq 1 ]; then
			if [ $INTERFACE ]; then
				TARGET_IP=$(curl --interface $INTERFACE http://members.3322.org/dyndns/getip)
			else
				TARGET_IP=$(curl http://members.3322.org/dyndns/getip)
			fi
		else
			if [ $INTERFACE ]; then
				TARGET_IP=$(curl -s --interface $INTERFACE http://members.3322.org/dyndns/getip)
			else
				TARGET_IP=$(curl -s http://members.3322.org/dyndns/getip)
			fi
		fi	
	else
		if [ $INTERFACE ]; then
			TARGET_IP=$(ifconfig $INTERFACE | grep 'inet addr' | awk -F ":" '{print $2}' | awk '{print $1}')
		else
			TARGET_IP=$(ifconfig | grep 'inet addr' | awk -F ":" '{print $2}' | awk '{print $1}' | head -n 1)
		fi
	fi
fi

if [ $DEBUG -eq 1 ]; then
cat<<EOF
CloudXNS DDNS script debug info.
       API KEY: $API_KEY
    SECRET KEY: $SECRET_KEY
        DOMAIN: $DOMAIN
     Interface: $INTERFACE
Remote Resolve: $REMOTE_RESOLVE
    Debug Mode: $DEBUG
EOF
fi

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