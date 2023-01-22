#!/bin/bash
dbname=access_point
tablename=wifi_keys
username=AP
userpasswd=password

GREEN="\033[0;32m"
RED="\033[0;31m"


# mysql database configuration
function Database()
{
	if [ $? -eq 0 ]; then
		echo "[*] Creating new MySQL database..."
		mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
		if [ $? -eq 0 ]; then
			echo "[*] Database successfully created!"	
		else
			echo "[-] Couldn't create database"
			exit 1
		fi
	else
		echo "[-] Problem occured in database creation"
		exit 1
	fi	

	sleep 2
	if [ $? -eq 0 ]; then
		echo "[*] Creating new user..."
		mysql -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpasswd}';"
		if [ $? -eq 0 ]; then
			echo "[*] User successfully created!"
		else
			echo "[-] Couldn't create user"
		fi
	else
		echo "[-] Problem occured in user creation"
		exit 1
	fi

		sleep 2
	if [ $? -eq 0 ]; then
		echo "[*] Granting ALL privileges on ${dbname} to ${username}!"
		mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${username}'@'localhost' identified by '${userpasswd}';"
		mysql -e "FLUSH PRIVILEGES;"
		echo "[*] Privileges setup done!"
	else
		echo "[-] Problem occured with privileges granting"
		exit 1
	fi

	sleep 2
	if [ $? -eq 0 ]; then
		echo "[*] Creating table called ${tablename}"
		mysql -e "USE ${dbname}; CREATE TABLE ${tablename}(password1 varchar(30), password2 varchar(30));"
		if [ $? -eq 0 ]; then
			echo "[*] All done"
			echo '**********************************************************'
		else
			echo "[-] Couldn't create table"
		fi
	else
		echo  "[-] Problem occured in tables creation"
		exit 1
	fi

	while true; do
		sleep 4		
		wifi_password=$(mysql -e "USE ${dbname}; SELECT * FROM ${tablename};")
		echo "[*] Viewing columns"

		if [ -z "$wifi_password" ] ; then
		   echo "[#] Nothing in columns"
		else
			data=$(mysql -e "USE ${dbname}; SELECT * FROM ${tablename};")
			password1=$(echo $data | awk '{print $3}')
		    password2=$(echo $data | awk '{print $4}')			
		    if [ $password1 = $password2 ]; then
		    	echo -e "${GREEN}[#] Password is:"
		    	echo -e "${GREEN}[#] $password1"
		    else
		    	echo -e "${RED}[#] Password are different:"
		    	echo -e "${RED}[#] $password1"
		    	echo -e "${RED}[#] $password2"
			fi
			break
		fi
	done
}	


Database