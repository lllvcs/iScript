ZONE_ID="ZONE_ID"
RECORDSET_ID="RECORDSET_ID"

ACCESS_KEY="ACCESS_KEY"
ACCESS_SECRET="ACCESS_SECRET"

ROS_HOST="192.168.1.1"
ROS_USER="admin"
ROS_PASSWD="admin"
INTERFACE=""
TARGET_IP="1.2.3.4"
DEBUG=0

usage() {
cat<<EOF
Usage: 
    ./ROS-HuaweiCloud-DDNS.sh -h "ROS_HOST" -u "ROS_USER" -p "ROS_PASSWD" -k "ACCESS-KEY" -s "ACCESS-SECRET" -z "ZONE-ID" -r "RECORDSET-ID" -i "INTERFACE"

    -h|--host
    -u|--user
    -p|--password
    -k|--access-key
    -s|--access-secret
    -z|--zone-id
    -r|--recordset-id
    -i|--interface
    -v|--debug
    -h|--help
EOF
	exit 1; 
}

ARGS=`getopt -o h:u:p:k:s:z:r:i:vh -l host:,user:,password:,access-key:,access-secret:,zone-id:,recordset-id:,interface:,debug,help -n ROS-HuaweiCloud-DDNS.sh -- "$@"`
if [ $? != 0 ]; then
    usage
    exit 1
fi

eval set -- "$ARGS"

while true; do
	case "$1" in
		-h|--ros-host)
			ROS_HOST=$2
			shift
			;;
		-u|--ros-user)
			ROS_USER=$2
			shift
			;;
		-p|--ros-passwd)
			ROS_PASSWD=$2
			shift
			;;
		-k|--access-key)
			ACCESS_KEY=$2
			shift
			;;
		-s|--access-secret)
			ACCESS_SECRET=$2
			shift
			;;
		-z|--zone-id)
			ZONE_ID=$2
			shift
			;;
        -r|--recordset-id)
			RECORDSET_ID=$2
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

TARGET_IP=`sshpass -p $ROS_PASSWD ssh -o "StrictHostKeyChecking no" $ROS_USER@$ROS_HOST "/ip address print where interface=$INTERFACE" | grep -Po "([0-9.]+)/[0-9]+" | awk -F "/" '{print $1}' | head -n 1`

if [ $DEBUG -eq 1 ]; then
cat<<EOF
HuaweiCloud DDNS script debug info.
      ROS Host: $ROS_HOST
      ROS User: $ROS_USER
  ROS Password: $ROS_PASSWD
     Interface: $INTERFACE
    ACCESS KEY: $ACCESS_KEY
 ACCESS SECRET: $ACCESS_SECRET
       ZONE ID: $ZONE_ID
  RECORDSET ID: $RECORDSET_ID
    Debug Mode: $DEBUG
EOF
fi


REQUEST_METHOD="PUT"
REQUEST_HOST="dns.myhuaweicloud.com"
REQUEST_PATH="/v2/zones/$ZONE_ID/recordsets/$RECORDSET_ID"
REQUEST_PARAM=""
REQUEST_DATA="{\"records\":[\"$TARGET_IP\"]}"

REQUEST_CONTENT_TYPE='application/json'
REQUEST_TIME=`date -u +%Y%m%dT%H%M%SZ`

REQUEST_DATA_HASH=`echo -ne "$REQUEST_DATA" | openssl dgst -sha256 -hex | grep -Po "([0-9a-f]{64})"`
REQUEST_HEADER="$REQUEST_METHOD\n$REQUEST_PATH/\n$REQUEST_PARAM\ncontent-type:$REQUEST_CONTENT_TYPE\nhost:$REQUEST_HOST\nx-sdk-date:$REQUEST_TIME\n\ncontent-type;host;x-sdk-date"
REQUEST_HASH=`echo -ne "$REQUEST_HEADER\n$REQUEST_DATA_HASH" | openssl dgst -sha256 -hex | grep -Po "([0-9a-f]{64})"`
HMAC=`echo -ne "SDK-HMAC-SHA256\n$REQUEST_TIME\n$REQUEST_HASH" | openssl dgst -sha256 -hmac "$ACCESS_SECRET" -hex | grep -Po "([0-9a-f]{64})"`

curl -X $REQUEST_METHOD "https://$REQUEST_HOST$REQUEST_PATH?$REQUEST_PARAM" -H "Content-Type: $REQUEST_CONTENT_TYPE" -H "X-Sdk-Date: $REQUEST_TIME" -H "host: $REQUEST_HOST" -H "Authorization: SDK-HMAC-SHA256 Access=$ACCESS_KEY, SignedHeaders=content-type;host;x-sdk-date, Signature=$HMAC" -d $REQUEST_DATA