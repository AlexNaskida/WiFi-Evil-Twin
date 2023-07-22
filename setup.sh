#!/bin/bash

main_des_path="/usr/local/bin"
lib_des_path="/usr/local/lib"
etclon3r_lib="$lib_des_path/etclon3r_lib"
script_path=$(pwd)

if [[ $EUID -eq 0 ]]; then
	if [[ -e "$main_des_path" ]] && [[ -e "$lib_des_path" ]]; then
		echo "[#] Updating system"
		apt update -y && apt install dnsmasq hostapd lighttpd dhcpd mysql-common network-manager tshark aircrack-ng tmux xterm -y  && apt autoremove -y 
		mkdir "$etclon3r_lib"

		mv "$script_path/etclon3r" "$main_des_path"
		mv "$script_path/db_conf" "$etclon3r_lib"
		mv "$script_path/vars" "$etclon3r_lib"
		mv "$script_path/web" "$etclon3r_lib"
		mv "$script_path/file.zip" "$etclon3r_lib"

		chmod +x "$main_des_path/etclon3r"
		echo "[#] Completed"
	else
		echo "$main_des_path or $lib_des_path do not exist"
		exit 1
	fi
else
	echo "[-] Rin script as root"
	exit 1
fi
