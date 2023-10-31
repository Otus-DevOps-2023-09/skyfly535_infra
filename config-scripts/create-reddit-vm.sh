#!/bin/bash

folder_id=$(yc config list | grep folder-id | awk '{print $2}') # считываем идентификатор рабочего каталога

yc compute instance create \
  --name reddit-app \
  --zone=ru-central1-c \
  --hostname reddit-app \
  --memory 2 \
  --cores 2 \
  --core-fraction 50 \
  --preemptible \
  --create-boot-disk image-folder-id=${folder_id},image-family=reddit-full,size=10GB \
  --network-interface subnet-name=default-ru-central1-c,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --ssh-key ~/.ssh/appuser.pub
