#!/bin/bash

# Установка MongoDB

sudo apt update
sudo apt install mongodb -y

sudo systemctl start mongodb
sudo systemctl enable mongodb

systemctl status mongodb
