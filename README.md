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

# Дополнительное задание

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
