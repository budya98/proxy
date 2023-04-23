#!/bin/bash
iface=`ls /sys/class/net/ | head -1`
IP=`ip addr list $iface | grep "  inet " | head -n 1 | cut -d " " -f 6 | cut -d / -f 1`
via=`ip route | grep default | cut -d " " -f 3`
export TAB=$'\t'
nmodem=`lsusb | grep -o "Huawei" | wc -l`
ipv4=`curl ipinfo.io/ip`
# обновление
apt-get update
# правим имена интерфейсов, чтобы они определялись попорядку eth1,eth2...
sed -i -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/' /etc/default/grub
update-grub
# установка необходимык пакетов
apt-get -y install gcc g++ git make curl usb-modeswitch dos2unix pwgen dsniff

sed -i -e 's/ domain-name-servers,//' /etc/dhcp/dhclient.conf


# расширение лимитов на открыте файлов
echo "root hard nofile 250000
root soft nofile 500000
nobody hard nofile 250000
nobody soft nofile 500000
* hard nofile 250000
* soft nofile 500000
root hard nproc 20000
root soft nproc 40000
nobody hard nproc 20000
nobody soft nproc 40000
* hard nproc 20000
* soft nproc 40000" >> /etc/security/limits.conf
# настрока сетовых интерфейсов для 40 модемов
echo "# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).
source /etc/network/interfaces.d/*
# The loopback network interface
auto lo
iface lo inet loopback
# The primary network interface
auto eth0
iface eth0 inet static
address $IP
netmask 255.255.255.0
gateway $via
dns-nameservers $via
auto eth1 eth2 eth3 eth4 eth5 eth6 eth7 eth8 eth9 eth10 eth11 eth12 eth13 eth14 eth15 eth16 eth17 eth18 eth19 eth20 eth21 eth22 eth23 eth24 eth25 eth26 eth27 eth28 eth29 eth30 eth31 eth32 eth33 eth34 eth35 eth36 eth37 eth38 eth39 eth40
iface eth1 inet dhcp
iface eth2 inet dhcp
iface eth3 inet dhcp
iface eth4 inet dhcp
iface eth5 inet dhcp
iface eth6 inet dhcp
iface eth7 inet dhcp
iface eth8 inet dhcp
iface eth9 inet dhcp
iface eth10 inet dhcp
iface eth11 inet dhcp
iface eth12 inet dhcp
iface eth13 inet dhcp
iface eth14 inet dhcp
iface eth15 inet dhcp
iface eth16 inet dhcp
iface eth17 inet dhcp
iface eth18 inet dhcp
iface eth19 inet dhcp
iface eth20 inet dhcp
iface eth21 inet dhcp
iface eth22 inet dhcp
iface eth23 inet dhcp
iface eth24 inet dhcp
iface eth25 inet dhcp
iface eth26 inet dhcp
iface eth27 inet dhcp
iface eth28 inet dhcp
iface eth29 inet dhcp
iface eth30 inet dhcp
iface eth31 inet dhcp
iface eth32 inet dhcp
iface eth33 inet dhcp
iface eth34 inet dhcp
iface eth35 inet dhcp
iface eth36 inet dhcp
iface eth37 inet dhcp
iface eth38 inet dhcp
iface eth39 inet dhcp
iface eth40 inet dhcp" > /etc/network/interfaces
#  усановка отпечатка андроид
echo "net.ipv4.ip_forward=1
net.ipv4.route.min_adv_mss = 256
net.ipv4.tcp_rmem = 8192 87380 16777216
net.ipv4.tcp_wmem = 6144 87380 1048576" >> /etc/sysctl.conf
# создание файла, отвечающий за перевод модема в нужный режим
cat > /usr/share/usb_modeswitch/12d1:1f01 << END
DefaultVendor = 0x12d1
DefaultProduct = 0x1f01
TargetVendor = 0x12d1
TargetProduct = 0x14dс
# switch to 12d1:14dc (default HiLink CDC-Ether mode)
MessageContent="55534243123456780000000000000a11062000000000000100000000000000"
END
# предостаавление прав файлу
chmod +x /usr/share/usb_modeswitch/12d1:1f01
#  удаляем файл 40-usb_modeswitch.rules
rm /lib/udev/rules.d/40-usb_modeswitch.rules
cd /lib/udev/rules.d/
# скачиваем файл 40-usb_modeswitch.rules для того чтобы модемы переходили в нужный	режим и определялись как сетевая карта
wget https://kak-podnyat-proksi-ipv6.ru/skript/mob/40-usb_modeswitch.rules

# создаём таблицу маршрутихации для 40 модемов
#
export TAB=$'\t'
for i in {11..100}
do
    echo "$i${TAB}route$i" >> /etc/iproute2/rt_tables
done
#

cd /etc/network/if-up.d
wget https://kak-podnyat-proksi-ipv6.ru/skript/mob/ip-rout/add_routes16
mv add_routes16 add_routes
chmod +x add_routes

cd /root/
# скачиваем файл скрипта iface_checker.sh
wget https://kak-podnyat-proksi-ipv6.ru/skript/iface_checker.sh
# предоставляем им права
chmod +x iface_checker.sh
# скачиваем файл скрипта рекконетка
wget https://kak-podnyat-proksi-ipv6.ru/skript/mob/rekonekt.sh
# предоставляем ему права
chmod +x rekonekt.sh
# прописываем крон для 40ка модемов, если у вас меньшее кол-во модемов то после удалем лишнее
echo "* * * * * /root/iface_checker.sh >/dev/null 2>&1
* * * * * /root/ip_route.sh >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.11.100.lock /root/rekonekt.sh -r 4G  -i 192.168.11.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.12.100.lock /root/rekonekt.sh -r 4G  -i 192.168.12.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.13.100.lock /root/rekonekt.sh -r 4G  -i 192.168.13.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.14.100.lock /root/rekonekt.sh -r 4G  -i 192.168.14.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.15.100.lock /root/rekonekt.sh -r 4G  -i 192.168.15.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.16.100.lock /root/rekonekt.sh -r 4G  -i 192.168.16.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.17.100.lock /root/rekonekt.sh -r 4G  -i 192.168.17.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.18.100.lock /root/rekonekt.sh -r 4G  -i 192.168.18.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.19.100.lock /root/rekonekt.sh -r 4G  -i 192.168.19.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.20.100.lock /root/rekonekt.sh -r 4G  -i 192.168.20.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.21.100.lock /root/rekonekt.sh -r 4G  -i 192.168.21.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.22.100.lock /root/rekonekt.sh -r 4G  -i 192.168.22.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.23.100.lock /root/rekonekt.sh -r 4G  -i 192.168.23.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.24.100.lock /root/rekonekt.sh -r 4G  -i 192.168.24.1 >/dev/null 2>&1
*/2 * * * * /usr/bin/flock -w 0 /var/run/192.168.25.100.lock /root/rekonekt.sh -r 4G  -i 192.168.25.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.26.100.lock /root/rekonekt.sh -r 4G  -i 192.168.26.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.27.100.lock /root/rekonekt.sh -r 4G  -i 192.168.27.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.28.100.lock /root/rekonekt.sh -r 4G  -i 192.168.28.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.29.100.lock /root/rekonekt.sh -r 4G  -i 192.168.29.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.30.100.lock /root/rekonekt.sh -r 4G  -i 192.168.30.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.31.100.lock /root/rekonekt.sh -r 4G  -i 192.168.31.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.32.100.lock /root/rekonekt.sh -r 4G  -i 192.168.32.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.33.100.lock /root/rekonekt.sh -r 4G  -i 192.168.33.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.34.100.lock /root/rekonekt.sh -r 4G  -i 192.168.34.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.35.100.lock /root/rekonekt.sh -r 4G  -i 192.168.35.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.36.100.lock /root/rekonekt.sh -r 4G  -i 192.168.36.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.37.100.lock /root/rekonekt.sh -r 4G  -i 192.168.37.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.38.100.lock /root/rekonekt.sh -r 4G  -i 192.168.38.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.39.100.lock /root/rekonekt.sh -r 4G  -i 192.168.39.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.40.100.lock /root/rekonekt.sh -r 4G  -i 192.168.40.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.41.100.lock /root/rekonekt.sh -r 4G  -i 192.168.41.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.42.100.lock /root/rekonekt.sh -r 4G  -i 192.168.42.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.43.100.lock /root/rekonekt.sh -r 4G  -i 192.168.43.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.44.100.lock /root/rekonekt.sh -r 4G  -i 192.168.44.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.45.100.lock /root/rekonekt.sh -r 4G  -i 192.168.45.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.47.100.lock /root/rekonekt.sh -r 4G  -i 192.168.47.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.48.100.lock /root/rekonekt.sh -r 4G  -i 192.168.48.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.49.100.lock /root/rekonekt.sh -r 4G  -i 192.168.49.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.50.100.lock /root/rekonekt.sh -r 4G  -i 192.168.50.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.51.100.lock /root/rekonekt.sh -r 4G  -i 192.168.51.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.52.100.lock /root/rekonekt.sh -r 4G  -i 192.168.52.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.53.100.lock /root/rekonekt.sh -r 4G  -i 192.168.53.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.54.100.lock /root/rekonekt.sh -r 4G  -i 192.168.54.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.55.100.lock /root/rekonekt.sh -r 4G  -i 192.168.55.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.56.100.lock /root/rekonekt.sh -r 4G  -i 192.168.56.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.57.100.lock /root/rekonekt.sh -r 4G  -i 192.168.57.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.58.100.lock /root/rekonekt.sh -r 4G  -i 192.168.58.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.59.100.lock /root/rekonekt.sh -r 4G  -i 192.168.59.1 >/dev/null 2>&1
*/5 * * * * /usr/bin/flock -w 0 /var/run/192.168.60.100.lock /root/rekonekt.sh -r 4G  -i 192.168.60.1 >/dev/null 2>&1" > /var/spool/cron/crontabs/$USER
dos2unix /var/spool/cron/crontabs/$USER
/etc/init.d/cron restart
# создаём дирректорию
mkdir /usr/local/3proxy
# перходим в дирректорию
cd /usr/local/3proxy
# скачиваем компилированный основной файл 3proxy 
wget https://kak-podnyat-proksi-ipv6.ru/skript/mob/3proxy
# пердоставляем ему права
chmod +x /usr/local/3proxy/3proxy
#  создаём дирректорию
mkdir /usr/local/3proxy/mob/
# перходим в дирректорию
cd /usr/local/3proxy/mob/
# скачиваем скрипт по проверку пингов на модеме
wget https://kak-podnyat-proksi-ipv6.ru/skript/mob/chekping.sh
# пердоставляем ему права
chmod +x /usr/local/3proxy/mob/chekping.sh
# создаём дирректорию для логов
mkdir /usr/local/3proxy/mob/log
# перходим в дирректорию /etc/init.d/
cd /etc/init.d/
# скачиваем файл для запуска 3proxy как сервиса
wget http://kak-podnyat-proksi-ipv6.ru/skript/mob/servis3proxy/3proxy
# пердоставляем ему права
chmod +x /etc/init.d/3proxy
# устанавливаем в автозагрузку 3proxy
update-rc.d 3proxy defaults
cd
# уставливаем архиваторы для архивации логов
#apt-get install -y aptitude
#aptitude update
#aptitude install rar unrar
#apt install -y zip unzip
#apt install sshpass
# создаём файлы конфигов 3proxy, указывая своё значение вместо "40" тут for i in {1..40} (226 строка)
cd /usr/local/3proxy/mob/
n=1
ipv4=`curl ipinfo.io/ip`
iponly=8.8.8.8,2.2.2.2 # впишите ip для авторизации через запятую
porthttp=7001
portsocks=8001
for i in {1..40}; do
login=`pwgen -s1`
pass=`pwgen -s1`
ipmodem=$((${i}+10))
echo "monitor /usr/local/3proxy/mob/3proxy$i.cfg

daemon
timeouts 1 5 30 60 180 1800 15 60
maxconn 5000
nserver 192.168.$ipmodem.1
nscache 65535
log /dev/null
auth iponly strong
users $login:CL:$pass
allow $login
allow * $iponly * * * * * 
proxy -n -a -p$porthttp -i$IP -e192.168.$ipmodem.100
socks -n -a -p$portsocks -i$IP -e192.168.$ipmodem.100
flush" >> /usr/local/3proxy/mob/3proxy$n.cfg
echo "$ipv4:$porthttp:$login:$pass" >> /root/proxyhttp.txt
echo "$ipv4:$portsocks:$login:$pass" >> /root/proxysocks.txt
((inc+=1))
((n+=1))
((porthttp+=1))
((portsocks+=1))
done


echo "" > /etc/rc.local

cat > /etc/rc.local << END
#!/bin/bash
ulimit -n 600000
ulimit -u 600000
sudo route del default && sudo route add default gw $via eth0
exit 0
END

#  полсе отработки скрипта перзагружаем сервер командой reboot и чекаем прокси proxyhttp.txt и proxysocks.txt

