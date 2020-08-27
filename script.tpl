#!/bin/bash
sleep 1m
sudo su - root
apt-get update
wget -qO- https://ubuntu.bigbluebutton.org/bbb-install.sh | bash -s -- -v xenial-22 -s ${url} -e ${email} -w -g
echo "${elasticip} ${url}" >> /etc/hosts
bbb-conf --setsecret {$shared_secret}