#!/bin/bash
add-apt-repository -y ppa:webupd8team/java
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3E5C1192
apt-get update
apt-get install -y oracle-java8-installer