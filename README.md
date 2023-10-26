# HW4 Деплой приложения

## Данные для подключения к Monolith Reddit

```
testapp_IP = 130.193.49.155
testapp_port = 9292
```

В процессе выполнения ДЗ выполнены следующие мероприятия:

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
