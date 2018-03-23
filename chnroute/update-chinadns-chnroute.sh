#!/bin/bash
if [ ! -f /etc/chnroute.txt ]; then
	curl 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /etc/chnroute.txt
	supervisorctl restart chinadns-53
else
	curl 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /etc/chnroute-tmp.txt
	COUNT=`wc -l /etc/chnroute-tmp.txt | grep -oE "([0-9]+)"`

	if [ $COUNT -gt 10 ]; then
		mv /etc/chnroute-tmp.txt /etc/chnroute.txt
		supervisorctl restart chinadns-53
	fi
fi