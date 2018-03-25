#!/bin/bash
mv /etc/apt/sources.list /etc/apt/sources.list.bak
cat>/etc/apt/sources.list<<EOF
deb http://hk.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse
deb http://hk.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse
deb http://hk.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse
deb http://hk.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse
# deb http://hk.archive.ubuntu.com/ubuntu/ xenial-proposed main restricted universe multiverse

# deb-src http://hk.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse
# deb-src http://hk.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse
# deb-src http://hk.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse
# deb-src http://hk.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse
# deb-src http://hk.archive.ubuntu.com/ubuntu/ xenial-proposed main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse

# deb http://archive.canonical.com/ubuntu xenial partner
# deb-src http://archive.canonical.com/ubuntu xenial partner

# deb http://extras.ubuntu.com/ubuntu xenial main
# deb-src http://extras.ubuntu.com/ubuntu xenial main
EOF