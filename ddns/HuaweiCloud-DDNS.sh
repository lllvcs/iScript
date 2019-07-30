ZONE_ID="ZONE_ID"
RECORDSET_ID="RECORDSET_ID"
IP="1.2.3.4"

ACCESS_KEY="ACCESS_KEY"
ACCESS_SECRET="ACCESS_SECRET"

REQUEST_METHOD="PUT"
REQUEST_HOST="dns.myhuaweicloud.com"
REQUEST_PATH="/v2/zones/$ZONE_ID/recordsets/$RECORDSET_ID"
REQUEST_PARAM=""
REQUEST_DATA="{\"records\":[\"$IP\"]}"

REQUEST_CONTENT_TYPE='application/json'
REQUEST_TIME=`date -u +%Y%m%dT%H%M%SZ`

REQUEST_DATA_HASH=`echo -ne "$REQUEST_DATA" | openssl dgst -sha256 -hex | grep -Po "([0-9a-f]{64})"`
REQUEST_HEADER="$REQUEST_METHOD\n$REQUEST_PATH/\n$REQUEST_PARAM\ncontent-type:$REQUEST_CONTENT_TYPE\nhost:$REQUEST_HOST\nx-sdk-date:$REQUEST_TIME\n\ncontent-type;host;x-sdk-date"
REQUEST_HASH=`echo -ne "$REQUEST_HEADER\n$REQUEST_DATA_HASH" | openssl dgst -sha256 -hex | grep -Po "([0-9a-f]{64})"`
HMAC=`echo -ne "SDK-HMAC-SHA256\n$REQUEST_TIME\n$REQUEST_HASH" | openssl dgst -sha256 -hmac "$ACCESS_SECRET" -hex | grep -Po "([0-9a-f]{64})"`

curl -X $REQUEST_METHOD "https://$REQUEST_HOST$REQUEST_PATH?$REQUEST_PARAM" -H "Content-Type: $REQUEST_CONTENT_TYPE" -H "X-Sdk-Date: $REQUEST_TIME" -H "host: $REQUEST_HOST" -H "Authorization: SDK-HMAC-SHA256 Access=$ACCESS_KEY, SignedHeaders=content-type;host;x-sdk-date, Signature=$HMAC" -d $REQUEST_DATA
