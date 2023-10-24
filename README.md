# skyfly535_infra
skyfly535 Infra repository

Для подключения из консоли при помощи команды вида ssh someinternalhost
из локальной консоли рабочего устройства необходимо ~/.ssh/config добавить следующие настройки:

Host 10.128.0.* # внутренняя подсеть за bastionhost с инфраструктурой
    ProxyJump 158.160.125.87 # внешний IP bastionhost
    User appuser # учетка хостов внутренней подсети

Host 158.160.125.87
    User appuser # учетка bastionhost

 Если есть DNS, то вместо IP пишем DNS имена.

# Данные для подкллючения к bastion: #
bastion_IP = 158.160.125.87
someinternalhost_IP = 10.128.0.21
