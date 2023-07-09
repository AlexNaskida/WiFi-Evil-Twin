# File paths
tmpdir="/tmp/"
conf_dir="/opt/"
ET_dir="access_point/"
webdir="/var/www/captiveportal"

# Bash files
db_configuration="db_conf.sh"
confirm_html_page="web.sh"

# Configuration files
server_conf_file="web.conf"
hostapd_conf_file="hostapd.conf"
dhcpd_conf_file="dhcpd.conf"
dnsmasq_conf_file="dnsmasq.conf"

# Web files
confirm_file="confirm.htm"
indexfile=index.htm

# Tool files
zipfile="file.zip"
pcapfile="capture.pcap"
hostapd_output="hostapd_output.txt"

# Database files
dbname="access_point"
tablename="wifi_keys"
username="AP"
userpasswd="password"
dbhost="localhost"

## Commands
# Network
wireless_interface_name=$(iwconfig 2> /dev/null | grep "IEEE" | cut -d " " -f 1)
wifi_networks_scanner=$(iwlist $wireless_interface_name scan 2> /dev/null| grep "ESSID"| cut -d '"' -f 2)

# Database 
wifi_password=$(mysql -e "USE $dbname; SELECT * FROM $tablename;")

# Other
non_priv_user=$(cat /etc/passwd | grep "/home" | cut -d ":" -f 1)

# Colors
Color_Off="\033[0m"  
RED="\033[0;31m"
GREEN="\033[0;32m"