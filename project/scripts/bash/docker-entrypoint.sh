#!/usr/bin/env bash -x
apt update
echo -e "Fetching python3, pip & modules"
apt install -y python3.8
apt install -y python3-pip
pip3 install -r requirements.txt
echo -e "DONE"
