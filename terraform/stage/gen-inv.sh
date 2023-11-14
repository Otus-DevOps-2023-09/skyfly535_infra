#!/bin/bash

if [[ $1 == "--list" ]]; then
    # apphost_ip=$(terraform output external_ip_address_app)
    # dbhost_ip=$(terraform output external_ip_address_db)
    apphost_ip=$(terraform output external_ip_address_app | sed -n 2p | sed 's/"//g' | sed 's/,//g' | sed 's/ //g')
    dbhost_ip=$(terraform output external_ip_address_db | sed -n 2p | sed 's/"//g' | sed 's/,//g' | sed 's/ //g')
    # apphost=$(yc compute instance get --name reddit-app-prod-0 --format=json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')
    # dbhost=$(yc compute instance get --name reddit-db-prod-0 --format=json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')
    #apphost_ip='158.160.41.144'
    #dbhost_ip='158.160.63.252'

    cat <<EOT > inventory.json
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
