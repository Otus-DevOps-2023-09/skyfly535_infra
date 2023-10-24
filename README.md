# skyfly535_infra
skyfly535 Infra repository

Для подключения из консоли при помощи команды вида ssh someinternalhost
из локальной консоли рабочего устройства необходимо ~/.ssh/config добавить следующие настройки:

Host 10.128.0.* # внутренняя подсеть за bastionhost с инфраструктурой
    ProxyJump 158.160.125.87 # внешний IP bastionhost
    User appuser # учетка хостов внутренней подсети

Host 51.250.12.145
    User appuser # учетка bastionhost

 Если есть DNS, то вместо IP пишем DNS имена.

# Данные для подкллючения к bastion: #
bastion_IP = 51.250.12.145
someinternalhost_IP = 10.128.0.12
