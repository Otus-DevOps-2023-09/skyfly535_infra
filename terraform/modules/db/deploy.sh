#!/bin/bash


sudo sed -i -E 's/^(\s*bindIp:).*$/\1 0.0.0.0/;' /etc/mongod.conf
sudo systemctl restart mongod
