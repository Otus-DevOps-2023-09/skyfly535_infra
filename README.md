# HW8 Управление конфигурацией. Основные DevOps инструменты. Знакомство с Ansible.

## В процессе выполнения ДЗ выполнены следующие мероприятия:

1. Установлен Ansible и произведена настройка клиента;

2. Подняты инстансы из окружения `stage` для отработки навыков работы с Ansible;

3. Создан файл `ansible.cfg` для настройки функций Ansible;

```
[defaults]
inventory = ./inventory
remote_user = ubuntu
private_key_file = ~/.ssh/appuser
host_key_checking = False
retry_files_enabled = False
```

4. Создан файл `inventory` для управления хостами при помощи Ansible;

```
[app]
appserver ansible_host=130.193.51.190

[db]
dbserver ansible_host=158.160.49.229
```
5. Изучена работа в Ansible с группами хостов;

6. Создан файл `inventory.yaml` для управления хостами при помощи Ansible;

```
app:
  hosts:
    appserver:
      ansible_host: 130.193.51.190

db:
  hosts:
    dbserver:
      ansible_host: 158.160.49.229
```
Внесены мзменения в `ansible.cfg`

```
inventory = ./inventory.yaml
```
Проверена работоспособность

```
$ ansible all -m ping
158.160.49.229 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
130.193.51.190 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```
7. Отработаны навыки по конфигурации хостов при помощи команд Ansible;

8. Написан простой плейбук, который выполняет клонирование репозитория;

```
---
- name: Clone
  hosts: app
  tasks:
    - name: Clone repo
      git:
        repo: https://github.com/express42/reddit.git
        dest: /home/ubuntu/reddit
```
Проверена работа данного плейбук

```
$ ansible-playbook clone.yml

PLAY [Clone] *****************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************
ok: [130.193.51.190]

TASK [Clone repo] ************************************************************************************************
ok: [130.193.51.190]

PLAY RECAP *******************************************************************************************************
130.193.51.190             : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```
## Дополнительное задание

9. Изучены две различных схемы JSON-inventory -- статическая и динамическая;

10. Создан Создан файл `inventorySTAT.json` в формате статического инвентори;

```
{
    "app": {
        "hosts": {
            "158.160.127.143": null
        },
        "vars": {
            "ansible_user": "ubuntu",
            "ansible_private_key_file": "~/.ssh/yc"
        }
    },
    "db": {
        "hosts": {
            "158.160.123.27": null
        },
        "vars": {
            "ansible_user": "ubuntu",
            "ansible_private_key_file": "~/.ssh/yc"
        }
    }
}
```

Можно воспользоваться командой `ansible-inventory` с параметром `--list` что бы сформировать json файл.

Для работы нового inventorySTAT.json также необходимо внести изменения в `ansible.cfg`.

11. Написан bash-скрипт  `gen-inv.sh`, который генерирует json массив в формате динамического инвентори. IP адреса инстансов `app` и `db` запрашиваются в YC через CLI `yc compute instance get`.

```
#!/bin/bash

if [[ $1 == "--list" ]]; then

    apphost_ip=$(yc compute instance get --name reddit-app-0 --format=json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')
    dbhost_ip=$(yc compute instance get --name reddit-db-0 --format=json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')

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
```
Не забываем внести изменения в `ansible.cfg`

```
inventory = ./gen-inv.sh
```
Проверяем работу

```
$ ansible all -m ping
158.160.49.229 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
130.193.51.190 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```
Можно  через консоль YC отключить один из истансов и повторить проверку

```
$ ansible all -m ping
null | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: ssh: Could not resolve hostname null: Temporary failure in name resolution",
    "unreachable": true
}
130.193.51.190 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```
# HW7 Принципы организации инфраструктурного кодаинфраструктурного кода и работа нади работа над инфраструктурой винфраструктурой в команде на примерекоманде на примере Terraform.

## В процессе выполнения ДЗ выполнены следующие мероприятия:

1. Теcтовое приложение разделено на две ВМ. Для каждой ВМ создан свой packer образ (`db.json` - ВМ с  MongoDB, `app.json` - ВМ с  Ruby);

2. Разбита конфигурация изначального тестового приложения на конфигурации двух инстансов (БД и Приложения);

3. Изучена работа с модулями в Terraform;

4. Рассмотрен функционал атрибутов ресурсов;

5. Проверена работа поднятых при помощи модулей инстансов по SSH;

6. Рассмотрен вариант применения Terraform модулей для использования на разных стадиях конвейера непрерывной поставки с необходимыми изменениями (принцип `DRY`):

  - создана инфраструктура окружения `stage`;

  - создана инфраструктура окружения `prod`.

## Дополнительное задание 1

7. При помощи сценария Terraform и мануала (https://cloud.yandex.ru/docs/storage/operations/buckets/create) создан бакет (каталог `terraform/storageS3` с конфиг файами для автоматизации создания бакета);

Минимально необходимая роль для создания бакета — `storage.editor` (в секции `provider` использовал `owner token`).

8. Настроено хранение стейт файлов в удаленном бекенде (`remote backends`) для окружений `stage` и `prod`, используя `Yandex Object Storage` в качестве бекенда;

Инициализация бэкэнда для окружений `stage` и `prod` производится в каталогах этих окружений следующим образом

```
$ export ACCESS_KEY="<идентификатор_ключа>"
$ export SECRET_KEY="<секретный_ключ>"

$ tterraform init -backend-config="access_key=$ACCESS_KEY" -backend-config="secret_key=$SECRET_KEY"
```
Ключи пришлось вытаскивать через `terraform.tfstate`.

## Дополнительное задание 2

9. Добавлены необходимые `provisioner` в модули для деплоя и работы приложения.

Внутренний IP адрес ВМ с БД передается в конфигурацию сервиса Puma `puma.service` через переменную `DATABASE_URL` ( terraform/modules/app/puma.service ).

```
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Environment='DATABASE_URL=${internal_ip_address_db}'
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/reddit
ExecStart=/bin/bash -lc 'puma'
Restart=always

[Install]
WantedBy=multi-user.target
```
Определение переменной `internal_ip_address_db` осуществляется через функцию `templatefile` в провиженере `file`:
```
provisioner "file" {
  content     = templatefile("${path.module}/puma.service", { internal_ip_address_db = "${var.db_ip}" })
  destination = "/tmp/puma.service"
}
```

# HW6 Практика IaC с использованием Terraform

## В процессе выполнения ДЗ выполнены следующие мероприятия:

1. Установлен `Terraform` и  настроен `Provider`, который позволит управлять ресурсами `YC`;

2. Описана конфигурация (в файле `main.tf`) развертываемого инстанса. ВМ поднимаем из базового образа предыдущего ДЗ;

3. Настроен экспорт `SSH ключей` в развертываемую ВМ;

4. Настроен вывод необходимых значений (внешние IP DV) после отработки terraform на экран и в файл состояния (файл конфигурации `outputs.tf`);

5. Настроен диплой приложения при помощи скрипта `deploy.sh` и systemd unit `puma.service` (секция `provisioner`);

В процессе диплоя пришлось решать проблему залоченной базы `apt`

добавленна проверкав начало скрипта `deploy.sh` из предыдущего ДЗ

```
echo Waiting for apt-get to finish...
a=1; while [ -n "$(pgrep apt-get)" ]; do echo $a; sleep 1s; a=$(expr $a + 1); done
echo Done.
```
6. Настроены входные переменные (input переменные) файлы `variables.tf` и `terraform.tfvars`;

## Дополнительное задание
7. Создан дополнительный клон инстанса с веб приложением при помощи параметра ресурса `count`;

```
resource "yandex_compute_instance" "app" {
  count = var.instances_count
  name  = "reddit-app-${count.index}"

  ...
```
8. Создан `Network Load Balancer` и настроена балансировка между инстансами веб приложения;

файл lb.tf

```
resource "yandex_lb_network_load_balancer" "lb-skyfly" {
  name = "lb-skyfly"
  type = "external"


  listener {
    name        = "web-listener"
    port        = 80
    target_port = 9292

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.loadbalancer.id

    healthcheck {
      name = "http"
      http_options {
        port = 9292
        path = "/"
      }
    }
  }
}

resource "yandex_lb_target_group" "loadbalancer" {
  name      = "target-group"
  folder_id = var.folder_id

  dynamic "target" {
    for_each = yandex_compute_instance.app.*.network_interface.0.ip_address
    content {
      subnet_id = var.subnet_id
      address   = target.value
    }
  }
}
```
9. Проверена работа балансировщика с неработающим одним сервером.

# HW5 Сборка образов VM приСборка образов VM при помощи Packerпом

## В процессе выполнения ДЗ выполнены следующие мероприятия:

1.  Создан сервисный аккаунта для `Packer` в Yandex.Cloud;

2.  Создан файл-шаблона Packer `ubuntu16.json` с секцией `provisioners`;

В процессе сбора образа пришлось столкнуться со следующей ошибкой

```
==> yandex: WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
==> yandex:
==> yandex: E: Could not get lock /var/lib/dpkg/lock-frontend - open (11: Resource temporarily unavailable)
==> yandex: E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?
```

(это обозначает что где то есть процесс который закрыл базу apt для использования)

Проблема решена добавление костыля в секцию `provisioners`

```
{
            "type": "shell",
            "inline": [
                "echo Waiting for apt-get to finish...",
                "a=1; while [ -n \"$(pgrep apt-get)\" ]; do echo $a; sleep 1s; a=$(expr $a + 1); done",
                "echo Done."
            ]
        }
```

3.  Работа с переменными Packer при помощи файла `variables.json`.


Команда запуска сбора образа с файлом переменнных `variables.json`

```
packer build -var-file variables.json ubuntu16.json
```

## Дополнительное задание

1.  Создан  `bake-образ` для запуска истанса с развернутым приложением;

Переработанный файл `ubuntu16.json` для создания  `bake-образа` (`immutable.json`)

```
{
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "{{ user `service_account_key_file` }}",
            "folder_id": "{{ user `folder_id` }}",
            "source_image_family": "{{ user `source_image_family` }}",
            "use_ipv4_nat": true,
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-full",
            "ssh_username": "{{ user `ssh_username` }}",
            "platform_id": "standard-v1",
            "disk_size_gb": "10"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "inline": [
                "echo Waiting for apt-get to finish...",
                "a=1; while [ -n \"$(pgrep apt-get)\" ]; do echo $a; sleep 1s; a=$(expr $a + 1); done",
                "echo Done."
            ]
        },
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "file",
            "source": "./files/puma.service",
            "destination": "/tmp/puma.service"
        },
        {
            "type": "shell",
            "inline": [
                "sudo mv /tmp/puma.service /etc/systemd/system/puma.service",
                "sudo apt-get update",
                "sudo apt-get install -y git",
                "sudo mkdir -p /monolith",
                "sudo chown $USER /monolith",
                "cd /monolith",
                "git clone -b monolith https://github.com/express42/reddit.git",
                "cd /monolith/reddit && bundle install",
                "sudo systemctl daemon-reload",
                "sudo systemctl start puma",
                "sudo systemctl enable puma"
            ]
        }

    ]

}
```
2.  Создан systemd unit `files/puma.service` для запуска приложения при старте инстанса;

```
[Unit]
Description=Puma
After=network.target

[Service]
Type=simple
WorkingDirectory=/monolith/reddit
ExecStart=/usr/local/bin/puma
Restart=always

[Install]
WantedBy=multi-user.target
```
3.  Создан скрипт `config-scripts/create-reddit-vm.sh` для создания ВМ  с помощью `Yandex.Cloud CLI`.

```
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
```



# HW4 Деплой приложения

## Данные для подключения к Monolith Reddit

```
testapp_IP = 130.193.49.155
testapp_port = 9292
```

## В процессе выполнения ДЗ выполнены следующие мероприятия:

1. Установлен и настроен YC CLI для работы с аккаунтом, создан профиль CLI;

2. Создан хост с помощью CLI;

3. Развернута требуемая в ДЗ инфраструктура;

4. Написаны скрипты для автоматизации процесса развертывания инфраструктура;

5. Отработан процесс развертывания инстанса при помощи ключа CLI `--metadata-from-file user-data` и `cloud config`

## Файлы bash скриптов ДЗ:

- install_ruby.sh - установка Ruby;

- install_mongodb.sh - установка MongoDB;

- deploy.sh - скачивание кода, установка
зависимостей через bundler и запуск приложения.

## Дополнительное задание

Преобразуем начальную команду CLI

```
yc compute instance create \
  --name reddit-app \
  --zone=ru-central1-a \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --metadata-from-file user-data=/path/to/file/install_deploy.yaml
```
Собственно сам cloud config

```
#cloud-config

ssh_pwauth: false
users:
  - name: yc-user
    gecos: YandexCloud User
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - "<PUBLIC_KEY_TO_USER>"

package_update: true
package_upgrade: true
packages:
  - mongodb
  - ruby-full
  - ruby-bundler
  - build-essential
  - git

runcmd:
  - systemctl start mongodb
  - systemctl enable mongodb
  - cd /home/yc-user
  - git clone -b monolith https://github.com/express42/reddit.git
  - cd reddit && bundle install
  - puma -d
```
<PUBLIC_KEY_TO_USER> - меняем на публичный ключ для нашего пользователя.

# HW3. Знакомство с облачной инфраструктурой Yandex.Cloud

Для подключения из консоли при помощи команды вида ssh someinternalhost
из локальной консоли рабочего устройства необходимо ~/.ssh/config добавить следующие настройки:

```
Host 10.128.0.* # внутренняя подсеть за bastionhost с инфраструктурой

    ProxyJump 158.160.125.87 # внешний IP bastionhost

    User appuser # учетка хостов внутренней подсети
```
```
Host 51.250.12.145
    User appuser # учетка bastionhost
```
 Если есть DNS, то вместо IP пишем DNS имена.

## Данные для подкллючения к bastion:

```
bastion_IP = 51.250.12.145

someinternalhost_IP = 10.128.0.12
```
