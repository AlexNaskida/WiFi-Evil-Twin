#!/bin/bash

main_des_path="/usr/local/bin"
lib_des_path="/usr/local/lib/etclon3r_lib"

if [ $USER = root ]; then
	
	echo "[*] You are root"
	echo "[#] Deleting files"
	rm "$main_des_path/etclon3r"
	rm "$lib_des_path/db_conf"
	rm "$lib_des_path/vars"
	rm "$lib_des_path/web"
	rm "$lib_des_path/file.zip"
	echo "[#] All files were removed"
	rm -rf "$lib_des_path"
	echo "[*] You can delete this directory!"	
else
	echo "[-] Run script as root"
	exit 1
fi
