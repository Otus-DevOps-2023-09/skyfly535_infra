#!/bin/bash

if [[ $1 == "--list" ]]; then

    # apphost_ip=$(terraform output external_ip_address_app | sed -n 2p | sed 's/"//g' | sed 's/,//g') # еще один вариант получения IP инстансов
    # dbhost_ip=$(terraform output external_ip_address_db | sed -n 2p | sed 's/"//g' | sed 's/,//g')
    apphost_ip=$(yc compute instance get --name reddit-app-0 --format=json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')
    dbhost_ip=$(yc compute instance get --name reddit-db-0 --format=json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')
    # Для прохождения тестов
    # apphost_ip='130.193.51.190'
    # dbhost_ip='158.160.49.229'

    cat <<EOT
{
    "_meta": {
        "hostvars": {}
    },
    "app": {
        "hosts": ["${apphost_ip}"],
        "vars": {
            "ansible_user": "ubuntu",
            "ansible_private_key_file": "~/.ssh/yc"
        }
    },
    "db": {
        "hosts": ["${dbhost_ip}"],
        "vars": {
            "ansible_user": "ubuntu",
            "ansible_private_key_file": "~/.ssh/yc"
        }
    }
}
EOT
elif [[ $1 == "--host" ]]; then
    echo '{"_meta": {"hostvars": {}}}' | jq -M
else
    echo '{}'
fi
