#!/bin/bash

# Built on 21 August 2020
# Raspberry Pi Bluetooth Manager
# Manage your Pi's bluetooth radio fast and easy!
# Run script with sudo bash rpibtman.sh
# or sudo ./rpibtman.sh if script is executable

# MIT License
# Copyright (c) 2020 CONSTANTIN BUSUIOCEANU

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

###
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo"
   exit 1
fi
###

### COLOR SETTINGS ####
#BLACK=$(tput setaf 0 && tput bold)
RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
YELLOW=$(tput setaf 3 && tput bold)
BLUE=$(tput setaf 4 && tput bold)
MAGENTA=$(tput setaf 5 && tput bold)
CYAN=$(tput setaf 6 && tput bold)
WHITE=$(tput setaf 7 && tput bold)
#BLACKbg=$(tput setab 0 && tput bold)
REDbg=$(tput setab 1 && tput bold)
#GREENbg=$(tput setab 2 && tput bold)
#YELLOWbg=$(tput setab 3 && tput bold)
BLUEbg=$(tput setab 4 && tput dim)
MAGENTAbg=$(tput setab 5 && tput bold)
#CYANbg=$(tput setab 6 && tput bold)
#WHITEbg=$(tput setab 7 && tput bold)
STAND=$(tput sgr0)
###

### System dialog VARS
show_on="${GREEN}[on]$STAND"
show_off="${RED}[off]$STAND"
show_info="${GREEN}[info]$STAND"
show_hint="${YELLOW}[hint]${STAND}"
show_error="${RED}[error]$STAND"
show_execute="${BLUE}[running]$STAND"
show_status="${MAGENTA}[status]$STAND"
show_ok="${MAGENTA}[OK]$STAND"
show_input="${CYAN}[input]$STAND"
show_warning="${YELLOW}[warning]$STAND"
show_active="${GREEN}[active]$STAND"
show_inactive="${RED}[inactive]$STAND"
show_enabled="${GREEN}[enabled]$STAND"
show_disabled="${RED}[disabled]$STAND"
show_starting="${BLUE}[starting]$STAND"
show_connected="${GREEN}[connected]$STAND"
show_disconnected="${RED}[disconnected]$STAND"
###

version="1.0"
last_update="09/20/2020"
first_time_config=".rpibtman.conf"
tmp_paired_devs="/tmp/paired_devs"
tmp_connected_to_phone="/tmp/btconn2phone"
dhcp_dir="/etc/dhcp"
dhcpv4_conf="/etc/dhcp/dhcpd.conf"
dhcpv6_conf="/etc/dhcp/dhcpd6.conf"
b64_isc_dhcp_config="b3B0aW9uIGRvbWFpbi1uYW1lLXNlcnZlcnMgOC44LjguOCwgOC44LjQuNDsKCmRlZmF1bHQtbGVhc2UtdGltZSAxMjAwOwptYXgtbGVhc2UtdGltZSAzNjAwOwphdXRob3JpdGF0aXZlOwoKc3VibmV0IDEwLjEwLjEwLjAgbmV0bWFzayAyNTUuMjU1LjI1NS4wIHsKCiAgICAgcmFuZ2UgMTAuMTAuMTAuMiAxMC4xMC4xMC4yNTQ7CiAgICAgb3B0aW9uIGJyb2FkY2FzdC1hZGRyZXNzIDEwLjEwLjEwLjI1NTsKICAgICBvcHRpb24gcm91dGVycyAxMC4xMC4xMC4xOwp9"
isc_dhcp_server_defaults="/etc/default/isc-dhcp-server"
bluetooth_var_lib="/var/lib/bluetooth"
sysctl_conf="/etc/sysctl.conf"
bt_agent_service="/lib/systemd/system/btman-agent.service"
bt_network_service="/lib/systemd/system/btman-network.service"
b64_agent_service_config="W1VuaXRdCkRlc2NyaXB0aW9uPUJsdWV0b290aCBCYWNrZ3JvdW5kIEF1dGggQWdlbnQKQWZ0ZXI9Ymx1ZXRvb3RoLnNlcnZpY2UKUGFydE9mPWJsdWV0b290aC5zZXJ2aWNlCgpbU2VydmljZV0KVHlwZT1zaW1wbGUKRXhlY1N0YXJ0PS91c3IvYmluL2J0LWFnZW50CkV4ZWNTdG9wPS9iaW4va2lsbCAtMiAkTUFJTlBJRApUaW1lb3V0U2VjPTUKI0V4ZWNTdGFydFBvc3Q9L2Jpbi9zbGVlcCAxCiNFeGVjU3RhcnRQb3N0PS9iaW4vaGNpY29uZmlnIGhjaTAgc3NwbW9kZSAwCgpbSW5zdGFsbF0KV2FudGVkQnk9Ymx1ZXRvb3RoLnRhcmdldAo="
b64_network_service_config="W1VuaXRdCkRlc2NyaXB0aW9uPUJsdWV0b290aCBOZXR3b3JrIEFjY2VzcyBQb2ludCBTZXJ2aWNlCkFmdGVyPWJsdWV0b290aC5zZXJ2aWNlClBhcnRPZj1ibHVldG9vdGguc2VydmljZQoKW1NlcnZpY2VdClR5cGU9c2ltcGxlCkV4ZWNTdGFydD0vdXNyL2Jpbi9idC1uZXR3b3JrIC1zIG5hcCBwYW4wCkV4ZWNTdG9wPS9iaW4va2lsbCAtMiAkTUFJTlBJRAoKW0luc3RhbGxdCldhbnRlZEJ5PWJsdWV0b290aC50YXJnZXQK"
#
list_bt_controller_available="bluetoothctl -- list"
show_bt_controller_info="bluetoothctl -- show"
#
select_bt_controller_default="bluetoothctl -- select"
#
set_system_bt_controller_alias="bluetoothctl -- system-alias"
reset_system_bt_controller_alias="bluetoothctl -- reset-alias"
#
list_bt_devices="bluetoothctl -- devices"
list_bt_devices_paired="bluetoothctl -- paired-devices"
#
power_bt_controller_on="bluetoothctl -- power on"
power_bt_controller_off="bluetoothctl -- power off"
#
pairable_bt_controller_on="bluetoothctl -- pairable on"
pairable_bt_controller_off="bluetoothctl -- pairable off"
#
discoverable_bt_controller_on="bluetoothctl -- discoverable on"
discoverable_bt_controller_off="bluetoothctl -- discoverable off"
#
start_scan_bt_devices="bluetoothctl -- scan on"
#
show_paired_bt_device_info="bluetoothctl -- info"
#
trust_bt_device="bluetoothctl -- trust"
untrust_bt_device="bluetoothctl -- untrust"
#
block_bt_device="bluetoothctl -- block"
unblock_bt_device="bluetoothctl -- unblock"
#
remove_bt_device="bluetoothctl -- remove"
disconnect_bt_device="bluetoothctl -- disconnect"

### START_CHECK_DEPENDENCIES
_config_check_deps(){
check_bluetooth="$(apt-cache policy bluetooth | grep -o none)"
check_bridge_utils="$(apt-cache policy bridge-utils | grep -o none)"
check_bluez_tools="$(apt-cache policy bluez-tools | grep -o none)"
check_bluez="$(apt-cache policy bluez | grep -o none)"
check_python_dbus="$(apt-cache policy python-dbus | grep -o none)"
check_pulseaudio_module_bt="$(apt-cache policy pulseaudio-module-bluetooth | grep -o none)"
check_isc_dhcp_server="$(apt-cache policy isc-dhcp-server | grep -o none)"
check_netfilter_persistent="$(apt-cache policy netfilter-persistent | grep -o none)"

echo -e "\\n${WHITE}=> STARTING DEPENDENCY CHECK <=${STAND}"
apt-get update
if [[ ! -z "$check_bluetooth" ]]; then echo "$show_execute Installing bluetooth..." && apt-get install -y bluetooth; else echo "$show_info$show_ok Bluetooth is installed."; fi
if [[ ! -z "$check_bridge_utils" ]]; then echo "$show_execute Installing bridge-utils..." && apt-get install -y bridge-utils; else echo "$show_info$show_ok bridge-utils is installed."; fi
if [[ ! -z "$check_bluez_tools" ]]; then echo "$show_execute Installing bluez-tools..." && apt-get install -y bluez-tools; else echo "$show_info$show_ok bluez-tools is installed."; fi
if [[ ! -z "$check_bluez" ]]; then echo "$show_execute Installing bluez..." && apt-get install -y bluez; else echo "$show_info$show_ok bluez is installed."; fi
if [[ ! -z "$check_python_dbus" ]]; then echo "$show_execute Installing python-dbus..." && apt-get install -y python-dbus; else echo "$show_info$show_ok python-dbus is installed."; fi
if [[ ! -z "$check_pulseaudio_module_bt" ]]; then echo "$show_execute Installing pulseaudio-module-bluetooth..." && apt-get install -y pulseaudio-module-bluetooth; else echo "$show_info$show_ok pulseaudio-module-bluetooth is installed."; fi
if [[ ! -z "$check_isc_dhcp_server" ]]; then echo "$show_execute Installing isc-dhcp-server..." && apt-get install -y isc-dhcp-server; else echo "$show_info$show_ok isc-dhcp-server is installed."; fi
if [[ ! -z "$check_netfilter_persistent" ]]; then echo "$show_execute Installing netfilter-persistent..." && apt-get install -y iptables-persistent netfilter-persistent; else echo "$show_info$show_ok netfilter-persistent is installed."; fi
}
### END_CHECK_DEPENDENCIES

### START_CONFIG_FOR_ISC_DHCP_SERVER
_config_isc_dhcp_server(){

	echo -e "\\n${WHITE}=> STARTING CONFIGURATION FOR ISC-DHCP-SERVER <=${STAND}"

	if [[ -d "$dhcp_dir" ]]; then

		echo "$show_ok ISC-DHCP-SERVER folder found!"

		if [[ -e "$dhcpv4_conf" ]]; then

			echo "$show_ok DHCPv4 config found!"
			if [[ -e "${dhcpv4_conf}.bak" ]]; then

				echo "$show_ok DHCPv4 Backup already exists."
			else
				if cp -n "$dhcpv4_conf"{,.bak}; then echo "$show_execute Creating backup for ${YELLOW}$dhcpv4_conf${STAND}"; else echo "$show_error Could not create backup!"; fi
			fi

			if echo "$b64_isc_dhcp_config" | base64 -d > "$dhcpv4_conf"; then echo "$show_info ISC-DHCP-SERVER configuration created."; else echo "$show_error Could not create ISC-DHCP-SERVER configuration!"; fi
			if [[ $(systemctl is-enabled isc-dhcp-server) == "disabled" ]]; then echo "$show_execute Enabling ISC-DHCP-SERVER onboot..." && systemctl enable isc-dhcp-server; else echo "$show_ok ISC-DHCP-SERVER onboot already enabled."; fi
		else
			echo "$show_error DHCPv4 config not found!"
		fi

		if [[ -e "$dhcpv6_conf" ]]; then

			echo "$show_ok DHCPv6 config found!"
			if [[ -e "${dhcpv6_conf}.bak" ]]; then

				echo "$show_ok DHCPv6 Backup already exists."
			else
				if cp -n "$dhcpv6_conf"{,.bak}; then echo "$show_execute Creating backup for ${YELLOW}$dhcpv6_conf${STAND}"; else echo "$show_error Could not create backup!"; fi
			fi
		else
			echo "$show_error DHCPv6 config not found!"
		fi

		if [[ -e "$isc_dhcp_server_defaults" ]]; then

			if grep -q "INTERFACESv4=\"pan0\"" "$isc_dhcp_server_defaults"; then echo "$show_ok pan0 interface already set to be served by ISC-DHCP-SERVER."; else echo "$show_execute Setting pan0 interface to be served by ISC-DHCP-SERVER" && sed -i.bak -e 's/INTERFACESv4=\"\"/INTERFACESv4=\"pan0\"/' "$isc_dhcp_server_defaults"; fi
		else
			echo "$show_error This should not happen! Where is the ${YELLOW}$isc_dhcp_server_defaults${STAND}??"
		fi
			if [[ $(systemctl is-active isc-dhcp-server) == "inactive" ]]; then echo "$show_execute Starting ISC-DHCP-SERVER..."; else echo "$show_ok ISC-DHCP-SERVER already started. Restarting..." && systemctl restart isc-dhcp-server; fi
	else
		echo -e "$show_error ISC-DHCP-SERVER folder missing!\\n$show_hint Did the dependency check install isc-dhcp-server?" && ft_config
	fi
}
### END_CONFIG_FOR_ISC_DHCP_SERVER

### START_IPTABLES_CONFIG
_config_iptables_rules(){
check_ipt_pan0_new=$(iptables -nvL | grep "pan0   eth0" | grep NEW)
check_ipt_pan0_rel_est=$(iptables -nvL | grep "pan0   eth0" | grep "RELATED,ESTABLISHED")
check_ipt_eth0_new=$(iptables -nvL | grep "eth0   pan0" | grep NEW)
check_ipt_eth0_rel_est=$(iptables -nvL | grep "eth0   pan0" | grep "RELATED,ESTABLISHED")
check_ipt_eth0_masquerade=$(iptables -nvL -t nat | grep "eth0    10.10.10.0/24")
add_ipt_pan0_new(){ iptables -A FORWARD -i pan0 -o eth0 -s 10.10.10.0/24 -m conntrack --ctstate NEW -j ACCEPT -m comment --comment "ACCEPT_NEW_CON_PAN0_ETH0"; }
add_ipt_pan0_rel_est(){ iptables -A FORWARD -i pan0 -o eth0 -s 10.10.10.0/24 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT -m comment --comment "ACCEPT_REL_EST_CON_PAN0_TO_ETH0"; }
add_ipt_eth0_new(){ iptables -A FORWARD -i eth0 -o pan0 -d 10.10.10.0/24 -m conntrack --ctstate NEW -j ACCEPT -m comment --comment "ACCEPT_NEW_CON_ETH0_TO_PAN0"; }
add_ipt_eth0_rel_est(){ iptables -A FORWARD -i eth0 -o pan0 -d 10.10.10.0/24 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT -m comment --comment "ACCEPT_REL_EST_CON_ETH0_TO_PAN0"; }
add_ipt_eth0_masquerade(){ iptables -t nat -A POSTROUTING -o eth0 -s 10.10.10.0/24 -j MASQUERADE -m comment --comment "MASQUERADE_eth0"; }

if $check_ipt_pan0_new 2>/dev/null; then echo "$show_execute Creating FORWARD IPT rule for ${GREEN}pan0${STAND} NEW connections"; add_ipt_pan0_new; else echo "$show_ok FORWARD IPT rule for ${GREEN}pan0${STAND} NEW connections found!"; fi
if $check_ipt_pan0_rel_est 2>/dev/null; then echo "$show_execute Creating FORWARD IPT rule for ${GREEN}pan0${STAND} RELATED,ESTABLISHED connections"; add_ipt_pan0_rel_est; else echo "$show_ok FORWARD IPT rule for ${GREEN}pan0${STAND} RELATED,ESTABLISHED connections found!"; fi
if $check_ipt_eth0_new 2>/dev/null; then echo "$show_execute Creating FORWARD IPT rule for ${BLUE}eth0${STAND} NEW connections"; add_ipt_eth0_new; else echo "$show_ok FORWARD IPT rule for ${BLUE}eth0${STAND} NEW connections found!"; fi
if $check_ipt_eth0_rel_est 2>/dev/null; then echo "$show_execute Creating FORWARD IPT rule for ${BLUE}eth0${STAND} RELATED,ESTABLISHED connections"; add_ipt_eth0_rel_est; else echo "$show_ok FORWARD IPT rule for ${BLUE}eth0${STAND} RELATED,ESTABLISHED connections found!"; fi
if $check_ipt_eth0_masquerade 2>/dev/null; then echo "$show_execute Creating POSTROUTING IPT rule for ${BLUE}eth0${STAND}"; add_ipt_eth0_masquerade; else echo "$show_ok POSTROUTING IPT rule for ${BLUE}eth0${STAND} found!"; fi
}
### END_IPTABLES_CONFIG

### START_CONFIG_BRIDGE
_config_bridge(){
get_bridge="$(brctl show | grep -o pan0)"

	echo -e "\\n${WHITE}=> BRIDGE/IP FORWARDING CONFIGURATOR <=${STAND}"

	if [[ "$get_bridge" == pan0 ]]; then

		echo "$show_ok Bridge interface found!"
		echo "${YELLOW}$(brctl show)${STAND}"
		if ifconfig | grep -qo pan0; then echo "$show_info pan0 interface is up!"; else echo "$show_execute Starting pan0 interface..." && ip link set pan0 up; fi
	else
		echo "$show_execute Configuring bridge interface..."

		if brctl addbr pan0; then echo "$show_ok Interface pan0 created"; else echo "$show_error Could not create pan0 interface!"; fi
		if brctl setfd pan0 0; then echo "$show_ok Bridge forward delay set to 0"; else echo "$show_error Could not set bridge forward delay!"; fi
		if brctl stp pan0 off; then echo "$show_ok Bridge STP set to off"; else echo "$show_error Could not set bridge STP to off!"; fi			# hope you don't have loops in your LAN! Else, set this to on!
		if ip addr add 10.10.10.1/255.255.255.0 dev pan0; then echo "$show_ok Added bridge IP"; else echo "$show_error Could not add interface IP!"; fi
		if ip link set pan0 up; then echo "$show_ok Started pan0 interface"; else echo "$show_error Could not start pan0 interface!"; fi
	fi

	if grep -q "#net.ipv4.ip_forward=1" "$sysctl_conf"; then echo "$show_execute Activating IP Forwarding..." && sed -i.bak -e 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' "$sysctl_conf" && sysctl -p; \
	elif grep -q "net.ipv4.ip_forward=1" "$sysctl_conf" || grep -q "net.ipv4.ip_forward = 1" "$sysctl_conf"; then echo "$show_ok IP Forwarding is active"; fi

}
### END_CONFIG_BRIDGE

### START_CONFIG_SERVICES
_config_services(){

	echo -e "\\n${WHITE}=> CONFIG AGENT/NETWORK SERVICES <=${STAND}"

	if [[ -e "$bt_agent_service" ]]; then

		echo -n "$show_info BT agent service file found!"
		if systemctl is-active btman-agent > /dev/null; then echo -n " $show_active"; else echo -n " $show_inactive$(if systemctl start btman-agent; then echo -n "$show_starting"; fi)"; fi
		if systemctl is-enabled btman-agent > /dev/null; then echo -n "$show_enabled"; else echo -n "$show_disabled"; fi
	else
		echo "$show_warning BT agent service file not found!"
		if echo "$b64_agent_service_config" | base64 -d > "$bt_agent_service"; then echo "$show_execute BT agent service configuration created."; else echo "$show_error Could not create BT agent service configuration!"; fi
		systemctl daemon-reload
		if [[ $(systemctl is-enabled btman-agent) == "disabled" ]]; then echo "$show_execute Enabling BT agent onboot..." && systemctl enable btman-agent; else echo "$show_ok BT agent onboot already enabled."; fi
		if systemctl start btman-agent; then echo "$show_info btman-agent service started."; else echo -e "$show_error Could not start btman-agent  service!\\n$show_hint Investigate why btman-agent daemon can't start."; fi
	fi

	if [[ -e "$bt_network_service" ]]; then

		echo -n -e "\\n$show_info BT network service file found!"
		if systemctl is-active btman-network > /dev/null; then echo -n " $show_active"; else echo -n " $show_inactive$(if systemctl start btman-network; then echo -n "$show_starting"; fi)"; fi
		if systemctl is-enabled btman-network > /dev/null; then echo -n -e "$show_enabled\\n\\n"; else echo -n -e "$show_disabled\\n"; fi
	else
		echo "$show_warning BT network service file not found!"

		if echo "$b64_network_service_config" | base64 -d > "$bt_network_service"; then echo "$show_execute BT network service configuration created."; else echo "$show_error Could not create BT network service configuration!"; fi
		systemctl daemon-reload
		if [[ $(systemctl is-enabled btman-network) == "disabled" ]]; then echo "$show_execute Enabling BT network onboot..." && systemctl enable btman-network; else echo "$show_ok BT network onboot already enabled."; fi
		if systemctl start btman-network; then echo "$show_info btman-network service started."; else echo -e "$show_error Could not start btman-network service!\\n$show_hint Investigate why btman-network daemon can't start."; fi
	fi
}
### END_CONFIG_SERVICES

### START_RUN_FT_CONFIG
run_ft_config(){
	touch "$first_time_config" && echo "$show_execute Created first time config file."
	if [[ "$DEPS_RETURN" -eq 0 ]]; then echo "DEPS=ok" > $first_time_config; else echo "DEPS=error" > $first_time_config; fi
	if [[ "$BR_RETURN" -eq 0 ]]; then echo "BR=ok" >> $first_time_config; else echo "BR=error" >> $first_time_config; fi
	if [[ "$ISC_RETURN" -eq 0 ]]; then echo "ISC=ok" >> $first_time_config; else echo "ISC=error" >> $first_time_config; fi
	if [[ "$IPT_RETURN" -eq 0 ]]; then echo "IPT=ok" >> $first_time_config; else echo "IPT=error" >> $first_time_config; fi
	if [[ "$SVC_RETURN" -eq 0 ]]; then echo "SVC=ok" >> $first_time_config; else echo "SVC=error" >> $first_time_config; fi
}
### END_RUN_FT_CONFIG

### START_FIRST_TIME_CONFIG
ft_config(){
echo "$WHITE"
echo "+-------------------------+----------------------------+"
echo "| It seems this is the first time running this script. |"
echo "|  We need to check dependencies & configure system.   |"
echo "|  Nothing bad will happen. This will only run once.   |"
echo "+-------------------------+----------------------------+"
echo "$STAND"
read -r -e -p "$show_input ${WHITE}Continue${STAND} (${GREEN}y${STAND},${RED}n${STAND}): " CONTINUE

if [[ "$CONTINUE" == [yY] ]]; then

	echo "$show_execute Starting dependency check..." && if _config_check_deps; then echo "$show_info Dependencies resolved $show_ok"; DEPS_RETURN=0; run_ft_config; else echo "$show_error Something went wrong when checking dependencies!"; DEPS_RETURN=1; run_ft_config; fi
	echo "$show_execute Configure bridge interface..." && if _config_bridge; then echo "$show_info Bridge configured $show_ok"; BR_RETURN=0; run_ft_config; else echo "$show_error Could not configure bridge interface!"; BR_RETURN=1; run_ft_config; fi
	echo "$show_execute Applying configuration for isc-dhcp-server..." && if _config_isc_dhcp_server; then echo "$show_info ISC-DHCP-SERVER configured $show_ok"; ISC_RETURN=0; run_ft_config; else echo "$show_error ISC-DHCP-SERVER was not configured!"; ISC_RETURN=1; run_ft_config; fi
	echo "$show_execute Setting iptables rules..." && if _config_iptables_rules; then echo "$show_info iptables configured $show_ok"; IPT_RETURN=0; run_ft_config; else echo "$show_error Could not configure iptables rules!"; IPT_RETURN=1; run_ft_config; fi
	echo "$show_execute Setting services..." && if _config_services; then echo "$show_info Services configured $show_ok"; SVC_RETURN=0; run_ft_config; mainmenu; else echo "$show_error Could not configure services!"; SVC_RETURN=1; run_ft_config; fi

elif [[ "$CONTINUE" == [nN] ]]; then

	echo "$show_warning You can't use this script if the initial checks are not done!" && _exit_rpibtman
fi

}
### END_FIRST_TIME_CONFIG

### PROGRESS_BAR_MODEL_1
1_sec_progress_model_1(){
bar=''
for (( x=35; x <= 100; x++ )); do
	sleep 0.0225
	bar="${bar} "

	echo -ne "\\r"
	echo -ne "\\e[42m$bar\\e[0m"

	local left="$(( 100 - x ))"
 	printf " %${left}s"
	echo -n "${x}%"
	done
	echo -e "\\n"
}
### PROGRESS_BAR_MODEL_1

### PROGRESS_BAR_MODEL_1
8_sec_progress_model_1(){
bar=''
for (( x=35; x <= 100; x++ )); do
	sleep 0.125
	bar="${bar} "

	echo -ne "\\r"
	echo -ne "\\e[42m$bar\\e[0m"

	local left="$(( 100 - x ))"
 	printf " %${left}s"
	echo -n "${x}%"
	done
	echo -e "\\n"
}
### PROGRESS_BAR_MODEL_1

### PROGRESS_BAR_MODEL_2
1_sec_progress_model_2(){
echo -ne '#####                     (33%)\\r'
sleep 0.50
echo -ne '#############             (66%)\\r'
sleep 0.50
echo -ne '#######################   (100%)\\r'
echo -ne '\\n'
}
### PROGRESS_BAR_MODEL_2

###
check_bt_service(){

if [[ "$(systemctl is-active bluetooth)" == inactive ]]; then
	echo "$show_warning Bluetooth service not started!"
	read -r -e -p "$show_input Start Bluetooth service now? (${GREEN}y${STAND} or ${RED}n${STAND}): " BT_SERVICE
	if [[ "$BT_SERVICE" == y ]]; then

		if [[ $(hciconfig hci0 class | grep -E "Class: [0-9]" | awk '{print $2}') == 0x020000 ]]; then echo "$show_ok Device service class is set to ${MAGENTA}Networking${STAND}"; else echo -e "$show_warning Device class is not set to Networking!\\n$show_execute Trying to fix that..." && kill -9 "$(pgrep bt-network)" && bt-network -s nap pan0 -d; fi
		#if [[ -z $(pgrep bt-network) ]]; then bt-network -s nap pan0 -d; echo "$show_execute Starting Bluetooth NAP process...${WHITE}${MAGENTAbg}PID: $(pgrep bt-network)${STAND}"; else echo "$show_ok Bluetooth NAP process is already started! ${WHITE}${MAGENTAbg}PID: $(pgrep bt-network)${STAND}"; fi
		if systemctl start bluetooth; then echo "$show_info Bluetooth service started."; else echo -e "$show_error Could not start Bluetooth service!\\n$show_hint Investigate why the Bluetooth daemon can't start."; fi

	elif [[ "$BT_SERVICE" == n ]]; then
		echo "$show_info Going back to main menu" && mainmenu
	fi
elif [[ "$(systemctl is-active bluetooth)" == active ]]; then

	if [[ -z $list_bt_controller_available ]]; then
		echo "$show_warning No Bluetooth controller available!"
	else
		echo "$show_info Bluetooth service $show_ok"
	fi
fi
}
###

# START_list_bt_controller_available_F
_list_bt_controller_available(){
	echo -e "\\n${WHITE}=> AVAILABLE BLUETOOTH CONTROLLERS <=${STAND}"

	check_bt_service
	echo -e "\\n$show_info Controller(s) available:\\n${YELLOW}$($list_bt_controller_available)${STAND}\\n"
	echo -e "$show_info Controller info: ${YELLOW}$($show_bt_controller_info)${STAND}\\n"

}
# END_list_bt_controller_available_F

# START_select_bt_controller_default_F
_select_bt_controller_default(){

	echo -e "\\n${WHITE}=> SET DEFAULT BLUETOOTH CONTROLLER <=${STAND}"

	check_bt_service
	echo -e "\\n$show_info Controller(s) available: \\n${GREEN}$($list_bt_controller_available)${STAND}"

	read -r -e -p "$show_input Write controller MAC address to use as default (${RED}x${STAND} to abort): " BT_CONTROLLER

	if [[ "$BT_CONTROLLER" == x ]]; then

		echo "$show_info Going back to main menu." && mainmenu

	elif [[ "$BT_CONTROLLER" =~ ^[a-fA-F0-9:]{17}$ ]]; then

		echo "$show_info Chosen Bluetooth Controller MAC address is: $BT_CONTROLLER"
		echo "$show_execute Applying..."

		if $select_bt_controller_default "$BT_CONTROLLER" | grep "not available"; then echo "$show_error Chosen Bluetooth Controller MAC address is not available!"; else echo "$show_info Command ran successfully!"; fi


	elif [[ "$BT_CONTROLLER" == * ]]; then

		echo "$show_error MAC address incorrect! Try again." && _select_bt_controller_default

	fi
}
# END_select_bt_controller_default_F

# START_set_reset_system_bt_controller_alias_F
_set_reset_system_bt_controller_alias(){

	echo -e "\\n${WHITE}=> SET/RESET BT CONTROLLER ALIAS <=${STAND}"
	check_bt_service
	echo -e "\\n$show_info Current ${GREEN}$($show_bt_controller_info | grep "Alias:")${STAND}\\n"

	read -r -e -p "$show_input Choose what to do (${GREEN}s${STAND} to set, ${BLUE}r${STAND} to reset, ${RED}x${STAND} to abort): " OPTION

	if [[ "$OPTION" == x ]]; then

		echo "$show_info Going back to main menu." && mainmenu

	elif [[ "$OPTION" == s ]]; then

		echo -e "\\n${WHITE}=> SET Bluetooth CONTROLLER ALIAS <=${STAND}"
		echo -e "\\n$show_info Current controller(s) alias(es): \\n\\n${GREEN}$($list_bt_controller_available | awk '{print $2" ""\033[1;31m"$3"\033[0m"" ""\033[1;32m"$4"\033[0m"}')${STAND}\\n"

		read -r -e -p "$show_input Write new Alias for the default controller (${RED}x${STAND} to abort): " BT_CONTROLLER_ALIAS

		if [[ "$BT_CONTROLLER_ALIAS" == x ]]; then

			echo "$show_info Going back to main menu." && mainmenu

		elif [[ "$BT_CONTROLLER_ALIAS" =~ ^[a-zA-Z0-9]{1,}$ ]]; then

			echo "$show_info Chosen Bluetooth Controller alias: $BT_CONTROLLER_ALIAS"
			echo "$show_execute Applying..."

			if $set_system_bt_controller_alias "$BT_CONTROLLER_ALIAS" | grep "not available"; then echo "$show_error Error processing your request."; else echo "$show_info Bluetooth alias changed successfully!"; fi

		elif [[ "$BT_CONTROLLER_ALIAS" == * ]]; then

			echo "$show_error Alias format incorrect! Only a-z, 0-9 allowed. Try again." && _set_reset_system_bt_controller_alias
		fi

	elif [[ "$OPTION" == r ]]; then

		echo -e "\\n${WHITE}=> RESET Bluetooth CONTROLLER ALIAS <=${STAND}"
		if $reset_system_bt_controller_alias | grep "succeeded"; then echo "$show_info Bluetooth alias reset successfully!"; else echo "$show_error Could not reset Bluetooth alias.."; fi

	elif [[ "$OPTION" == * ]]; then

		echo "$show_error Wrong option. Try again.." && _set_reset_system_bt_controller_alias
	fi
}
# END_set_reset_system_bt_controller_alias_F

# F #
f_scanned(){
	check_bt_service
	echo -e "\\n$show_info Scanned device(s) list: "
	if [ -z "$($list_bt_devices)" ]; then echo "$show_info You don't have any scanned devices."; else echo "${YELLOW}$($list_bt_devices)${STAND}"; fi
}

f_paired(){
	check_bt_service
	echo -e "\\n$show_info Paired device(s) list: "
	if [ -z "$($list_bt_devices_paired)" ]; then echo "$show_info You don't have any paired devices."; return=0; else echo "${YELLOW}$($list_bt_devices_paired)${STAND}"; return=1; fi
}
# F #

# START_list_bt_devices_F
_list_bt_devices(){

if [[ "$menuoption" == 4s ]]; then

	echo -e "\\n${WHITE}=> LIST SCANNED Bluetooth DEVICES <=${STAND}"
	f_scanned && mainmenu	# shortcut

elif [[ "$menuoption" == 4p ]]; then

	echo -e "\\n${WHITE}=> LIST PAIRED Bluetooth DEVICES <=${STAND}"
	f_paired && mainmenu 	# shortcut

elif [[ "$menuoption" == 4 ]]; then

	echo -e "\\n${WHITE}=> LIST SCANNED/PAIRED Bluetooth DEVICES <=${STAND}\\n"

	read -r -e -p "$show_input Choose (${GREEN}s${STAND} to list scanned dev, ${BLUE}p${STAND} to list paired dev, ${RED}x${STAND} to abort): " OPTION

	if [[ "$OPTION" == x ]]; then

		echo "$show_info Going back to main menu." && mainmenu

	elif [[ "$OPTION" == s ]]; then

		echo -e "\\n${WHITE}=> LIST SCANNED Bluetooth DEVICES <=${STAND}"
		f_scanned

	elif [[ "$OPTION" == p ]]; then

		echo -e "\\n${WHITE}=> LIST PAIRED Bluetooth DEVICES <=${STAND}"
		f_paired

	elif [[ "$OPTION" == * ]]; then

		echo "$show_error Wrong option. Try again.." && _list_bt_devices
	fi
fi
}
# END_list_bt_devices_F

# START_power_bt_controller_on_off_F
_power_bt_controller_on_off(){

echo -e "\\n${WHITE}=> BLUETOOTH POWER ON/OFF <=${STAND}"
echo -e "\\n$show_info Current status: "

if [[ $($show_bt_controller_info | grep "Powered:" | awk '{print $2}') == yes ]]; then

	echo "$show_status Bluetooth is $show_on"

	if [[ "$menuoption" == "50" ]]; then

		if $power_bt_controller_off; then echo "$show_info Bluetooth turned $show_off"; else echo "$show_error Could not turn bluetooth off!"; fi
	fi
else
	echo "$show_status Bluetooth is $show_off"

	if [[ "$menuoption" == "51" ]]; then

		if $power_bt_controller_on; then echo "$show_info Bluetooth turned $show_on"; else echo "$show_error Could not turn bluetooth on!"; fi
	fi
fi
}
# END_power_bt_controller_on_off_F

# START_discoverable_bt_controller_on_off_F
_discoverable_bt_controller_on_off(){

echo -e "\\n${WHITE}=> BLUETOOTH DISCOVERABLE ON/OFF <=${STAND}"
echo -e "\\n$show_info Current status: "

if [[ $($show_bt_controller_info | grep "Discoverable:" | awk '{print $2}') == yes ]]; then

	echo "$show_status Bluetooth discoverable $show_on"

	if [[ "$menuoption" == "60" ]]; then

		if $discoverable_bt_controller_off; then echo "$show_status Bluetooth discoverable $show_off"; else echo "$show_error Could not turn Bluetooth discoverability off!"; fi
	fi
else
	echo "$show_status Bluetooth discoverable $show_off"

	if [[ "$menuoption" == "61" ]]; then

		if $discoverable_bt_controller_on; then echo "$show_status Bluetooth discoverable $show_on"; else echo "$show_error Could not turn Bluetooth discoverability on!"; fi
	fi
fi
}
# END_discoverable_bt_controller_on_off_F

# START_pairable_bt_controller_on_off_F
_pairable_bt_controller_on_off(){

echo -e "\\n${WHITE}=> BLUETOOTH PAIRABLE ON/OFF <=${STAND}"
echo -e "\\n$show_info Current status: "

if [[ $($show_bt_controller_info | grep "Pairable:" | awk '{print $2}') == yes ]]; then

	echo "$show_status Bluetooth pairing $show_on"

	if [[ "$menuoption" == "70" ]]; then

		if $pairable_bt_controller_off; then echo "$show_info Bluetooth pairing $show_off"; else echo "$show_error Could not turn bluetooth pairing off!"; fi
	fi
else
	echo "$show_status Bluetooth pairing $show_off"

	if [[ "$menuoption" == "71" ]]; then

		if $pairable_bt_controller_on; then echo "$show_info Bluetooth pairing $show_on"; else echo "$show_error Could not turn bluetooth pairing on!"; fi
	fi
fi
}
# END_pairable_bt_controller_on_off_F

# F #
_receive_internet_from_phone_cmd(){

read -r -e -p "$show_input Please confirm you started Bluetooth & tethering option on your phone/tablet/etc (${GREEN}y${STAND} or ${RED}n${STAND}): " CONFIRM_DEVICE_TETHERING

if [[ "$IS_PI_PAIRED" == n ]]; then

	echo "$show_info Bluetooth agent will help you pair your phone to RPi!"
	#if kill -n 9 $(pgrep bt-agent) 2>/dev/null; then echo "$show_ok Bt-agent daemon closed successfully!"; else echo "$show_info$show_ok No bt-agent process found!"; fi
	if $power_bt_controller_on && $pairable_bt_controller_on && $discoverable_bt_controller_on; then echo "$show_status BT power, pairing and discoverable on"; else echo "$show_error Could not change status for one of BT power - pairing - discoverable"; mainmenu; fi
	echo -e "$show_status Bluetooth agent $show_on\\n$show_hint ${WHITE}${REDbg}On your phone, press on the RPi corresponding name to pair${STAND}\\n${show_hint} ${WHITE}${REDbg}          Press ctrl c here after pairing is done!        ${STAND}" && echo "${YELLOW}"; bt-agent "${STAND}"
fi

if [[ "$CONFIRM_DEVICE_TETHERING" == y ]]; then

	get_default_bt_controller=$($list_bt_controller_available | grep default | awk '{print $2" "$3" "$4}')
	get_default_bt_controller_MAC=$($list_bt_controller_available | grep default | awk '{print $2}')
	if $list_bt_devices_paired | awk '{print NR" "$2" "$3}' > $tmp_paired_devs; then echo "$show_info Paired BT list saved!"; else echo "$show_error Could not save paired BT list!"; fi

	echo "$show_execute We'll pre-check the default BT controller & paired devices"

	if [[ -n "$get_default_bt_controller" ]]; then

		echo "$show_info Your default BT controller is: ${MAGENTA}$get_default_bt_controller${STAND}"
		read -r -e -p "$show_input Confirm? (${GREEN}y${STAND} or ${RED}n${STAND}): " CONFIRM_DEFAULT_BT_CONTROLLER

		if [[ "$CONFIRM_DEFAULT_BT_CONTROLLER" == [yY] ]]; then

			echo "$show_info Paired BT devices available:"
			#n=1
			while IFS= read -r paired_devs
			do
				echo "$show_info ${MAGENTA}$paired_devs${STAND}"
			#n=$((n+1))
			done <<< "$(cat $tmp_paired_devs)"

			read -r -e -p "$show_input Choose corresponding number for your phone/tablet/etc: " CHOOSE_DEV_NUMBER

			if [[ "$CHOOSE_DEV_NUMBER" == [0-9] ]]; then
				get_dev_number_MAC=$(grep -w "$CHOOSE_DEV_NUMBER" $tmp_paired_devs | awk '{print $2}')

				if [[ -n "$get_dev_number_MAC" ]]; then
					bt-network -a "$get_default_bt_controller_MAC" -c "$get_dev_number_MAC" nap > $tmp_connected_to_phone &
					1_sec_progress_model_1
					if [[ $(grep -wom1 "service is connected" $tmp_connected_to_phone) == "service is connected" ]]; then

						echo "$show_info RPi -> phone connection established."
						echo "$show_execute Getting info..."
						8_sec_progress_model_1

						is_pi_connected="$(ifconfig bnep0 | grep "netmask" | awk '{print $2}')"
						get_pi_gateway="$(ip route show 0.0.0.0/0 dev bnep0 | cut -d ' ' -f3)"
						if [[ ! -z "$is_pi_connected" ]]; then echo -e "$show_ok RPi is connected. ${WHITE}${MAGENTAbg}IP: ${is_pi_connected}${STAND} via ${WHITE}${MAGENTAbg}GW: ${get_pi_gateway}${STAND}\\n$show_hint Now, you can SSH to your RPi via smartphone!\\n$show_hint ${WHITE}${BLUEbg}ssh pi@${is_pi_connected}${STAND}"; else echo "$show_warning RPi is not connected..."; fi
					else
						if [[ $(grep -wom1 "service is already connected" $tmp_connected_to_phone) == "service is already connected" ]]; then

							echo "$show_ok RPI -> phone connection is already established!"
							is_pi_connected="$(ifconfig bnep0 | grep "netmask" | awk '{print $2}')"
							get_pi_gateway="$(ip route show 0.0.0.0/0 dev bnep0 | cut -d ' ' -f3)"
							if [[ ! -z "$is_pi_connected" ]]; then echo -e "$show_ok RPi is connected. ${WHITE}${MAGENTAbg}IP: ${is_pi_connected}${STAND} via ${WHITE}${MAGENTAbg}GW: ${get_pi_gateway}${STAND}\\n$show_hint Now, you can SSH to your RPi via smartphone!\\n$show_hint ${WHITE}${BLUEbg}ssh pi@${is_pi_connected}${STAND}"; else echo "$show_warning RPi is not connected..."; fi

						else
							echo "$show_error This is a Segmentation fault. You probably didn't activate tethering on your phone/tablet/etc." && mainmenu
						fi
					fi
				else
					echo "$show_error Chosen device number '$CHOOSE_DEV_NUMBER' is not available! Try again."
				fi

			elif [[ "$CHOOSE_DEV_NUMBER" == * ]]; then

					echo "$show_error Only numbers are accepted."
			fi

		elif [[ "$CONFIRM_DEFAULT_BT_CONTROLLER" == [nN] ]]; then

			echo "$show_info Going back to main menu." && mainmenu

		elif [[ "$CONFIRM_DEFAULT_BT_CONTROLLER" == * ]]; then

			echo "$show_error You need to use ${GREEN}y${STAND} or ${RED}n${STAND}. Try again." && mainmenu
		fi
	else
		echo "$show_error No default BT controller found! Is bluetooth service started?" && mainmenu
	fi

elif [[ "$CONFIRM_DEVICE_TETHERING" == n ]]; then

	echo "$show_info Going back to main menu." && mainmenu

elif [[ "$CONFIRM_DEVICE_TETHERING" == * ]]; then

	echo "$show_error You need to use ${GREEN}y${STAND} or ${RED}n${STAND}. Try again." && mainmenu
fi
}
# F #

# START_receive_internet_from_phone_F
_receive_internet_from_phone(){

echo -e "\\n${WHITE}=> RECEIVE INTERNET FROM PHONE/DEVICE <=${STAND}"

read -r -e -p "$show_input Is RPi already paired to phone/tablet/etc? (${GREEN}y${STAND} or ${RED}n${STAND}): " IS_PI_PAIRED

if [[ "$IS_PI_PAIRED" == y ]]; then

	_receive_internet_from_phone_cmd

elif [[ "$IS_PI_PAIRED" == n ]]; then

	_receive_internet_from_phone_cmd

elif [[ "$IS_PI_PAIRED" == * ]]; then

	echo "$show_error You need to use ${GREEN}y${STAND} or ${RED}n${STAND}. Try again." && _receive_internet_from_phone
fi
}
# END_receive_internet_from_phone_F

# F #
_transmit_internet_from_rpi_cmd(){

	f_paired

	if [[ "$TRANSMIT_PI_INTERNET" == y ]]; then

		if pgrep bt-network > /dev/null; then echo "$show_ok BT NAP process is already started! ${WHITE}${MAGENTAbg}PID: $(pgrep bt-network)${STAND}"; else bt-network -s nap pan0 -d; echo "$show_execute Starting BT NAP process...${WHITE}${MAGENTAbg}PID: $(pgrep bt-network)${STAND}"; fi
		if [[ $(hciconfig hci0 class | grep -E "Class: [0-9]" | awk '{print $2}') == 0x020000 ]]; then echo "$show_ok Device service class is set to ${MAGENTA}Networking${STAND}"; else echo -e "$show_warning Device class is not set to Networking!\\n$show_execute Trying to fix that..." && kill -9 "$(pgrep bt-network)" && bt-network -s nap pan0 -d; fi
		echo -e "$show_status Bluetooth agent $show_on\\n$show_hint ${WHITE}${REDbg}Press on the RPi name from your device to connect.${STAND}\\n${show_hint} ${WHITE}${REDbg}      Press ctrl c after connection is made!      ${STAND}" && echo "${YELLOW}"; bt-agent "${STAND}"
		get_connected_ext_devs="$(arp -n | grep -E "10.10.10.[0-9]{1,3}" | awk '{print $1" "$3" "$5}')"
		if [[ ! -z "$get_connected_ext_devs" ]]; then echo -e "$show_ok Found connected device(s):\\n${GREEN}${get_connected_ext_devs}${STAND}"; else echo "$show_info We didn't find any external device(s) tethered to RPi."; fi

	elif [[ "$TRANSMIT_PI_INTERNET" == n ]]; then

		echo "$show_info Bluetooth agent will help you pair your phone to RPi!"
#		if kill -n 9 $(pgrep bt-agent) 2>/dev/null; then echo "$show_ok Bt-agent daemon closed successfully!"; else echo "$show_info$show_ok No bt-agent daemon process found!"; fi
		if $power_bt_controller_on && $pairable_bt_controller_on && $discoverable_bt_controller_on; then echo "$show_status BT power, pairing and discoverable $show_on"; else echo "$show_error Could not change status for one of BT power - pairing - discoverable"; mainmenu; fi
		if pgrep bt-network > /dev/null; then echo "$show_ok BT NAP process is already started! ${WHITE}${MAGENTAbg}PID: $(pgrep bt-network)${STAND}"; else bt-network -s nap pan0 -d; echo "$show_execute Starting BT NAP process...${WHITE}${MAGENTAbg}PID: $(pgrep bt-network)${STAND}"; fi
		if [[ $(hciconfig hci0 class | grep -E "Class: [0-9]" | awk '{print $2}') == 0x020000 ]]; then echo "$show_ok Device service class is set to ${MAGENTA}Networking${STAND}"; else echo -e "$show_warning Device class is not set to Networking!\\n$show_execute Trying to fix that..." && kill -9 "$(pgrep bt-network)" && bt-network -s nap pan0 -d; fi
		echo -e "$show_status Bluetooth agent $show_on\\n$show_hint ${WHITE}${REDbg}On your phone, press on the RPi corresponding name to pair${STAND}\\n$show_hint ${WHITE}${REDbg}   After pairing, press on the paired RPi name to connect.${STAND}\\n${show_hint} ${WHITE}${REDbg}           Press ctrl c after connection is made!         ${STAND}" && echo "${YELLOW}"; bt-agent "${STAND}"
		get_connected_ext_devs="$(arp -n | grep -E "10.10.10.[0-9]{1,3}" | awk '{print $1" "$3" "$5}')"
		if [[ ! -z "$get_connected_ext_devs" ]]; then echo -e "$show_ok Found connected device(s):\\n${GREEN}${get_connected_ext_devs}${STAND}"; else echo "$show_info We didn't find any external device(s) tethered to RPi."; fi
	fi
}
# F #

# START_transmit_internet_from_RPI_F
_transmit_internet_from_rpi(){

echo -e "\\n${WHITE}=> TRANSMIT INTERNET FROM RPI (BT AP) <=${STAND}"

read -r -e -p "$show_input Is your phone/tablet/etc already paired to RPi? (${GREEN}y${STAND}, ${RED}n${STAND} or ${BLUE}x${STAND}): " TRANSMIT_PI_INTERNET

if [[ "$TRANSMIT_PI_INTERNET" == y ]]; then

	_transmit_internet_from_rpi_cmd

elif [[ "$TRANSMIT_PI_INTERNET" == n ]]; then

	_transmit_internet_from_rpi_cmd

elif [[ "$TRANSMIT_PI_INTERNET" == x ]]; then

	echo "$show_info Going back to main menu." && mainmenu

elif [[ "$TRANSMIT_PI_INTERNET" == * ]]; then

	echo "$show_error You need to use ${GREEN}y${STAND} or ${RED}n${STAND}. Try again." && _transmit_internet_from_rpi
fi
}
# END_transmit_internet_from_RPI_F

# F #
_scan_bt_devs_cmd(){
	check_bt_service
	8_sec_progress_model_1
	echo -e "$show_execute Starting Bluetooth scanning\\n$show_hint ${WHITE}Press ctrl c to stop scanning.${STAND}"
	if $start_scan_bt_devices; then echo "$show_info Scanning finished."; else echo "$show_error Couldn't start Bluetooth scanning"; fi
}
# F #

# START_scan_bt_devs_F
_scan_bt_devs(){

echo -e "\\n${WHITE}=> SCAN FOR BLUETOOTH DEVICES <=${STAND}"

	_internal_f_call_scan_bt_devs(){

		read -r -e -p "$show_input Start scanning for Bluetooth devices? (${GREEN}y${STAND}, ${RED}n${STAND}): " SCAN_BT_DEVS

		if [[ "$SCAN_BT_DEVS" == y ]]; then

			_scan_bt_devs_cmd

		elif [[ "$SCAN_BT_DEVS" == n ]]; then

			echo "$show_info Going back to main menu." && mainmenu

		elif [[ "$SCAN_BT_DEVS" == * ]]; then

			echo "$show_error You need to use ${GREEN}y${STAND} or ${RED}n${STAND}. Try again." && _internal_f_call_scan_bt_devs
		fi

	}
	_internal_f_call_scan_bt_devs
}
# END_scan_bt_devs_F

# START_show_bt_device_info_F
_show_paired_bt_device_info(){

	echo -e "\\n${WHITE}=> SHOW PAIRED DEVICE INFO <=${STAND}"

	f_paired

	PAIRED_RETURN_CODE=$return

	if [ "$PAIRED_RETURN_CODE" -eq "1" ]; then

	_internal_f_call_show_bt_device_info(){

		read -r -e -p "$show_input Enter paired device MAC to see info (${RED}x${STAND} to abort): " PAIRED_BT_DEVICE_INFO

		if [[ "$PAIRED_BT_DEVICE_INFO" =~ ^[a-fA-F0-9:]{17}$ ]]; then

			if $show_paired_bt_device_info "$PAIRED_BT_DEVICE_INFO" | grep "not available"; then echo "$show_error Device MAC address is not available!"; else echo "$show_info ${YELLOW}$($show_paired_bt_device_info "$PAIRED_BT_DEVICE_INFO")${STAND}"; fi

		elif [[ "$PAIRED_BT_DEVICE_INFO" == x ]]; then

			echo "$show_info Going back to main menu." && mainmenu

		elif [[ "$PAIRED_BT_DEVICE_INFO" == * ]]; then

			echo "$show_error MAC address incorrect! Try again." && _internal_f_call_show_bt_device_info
		fi
	}
	_internal_f_call_show_bt_device_info

	elif [ "$PAIRED_RETURN_CODE" -eq "0" ]; then
		mainmenu
	fi

}
# END_show_bt_device_info_F

# F #
_trust_untrust_mac_cmd(){

	read -r -e -p "$show_input Write device MAC address to $(if [[ "$OPTION" == t ]]; then echo "${GREEN}trust${STAND}"; elif [[ "$OPTION" == u ]]; then echo "${RED}untrust${STAND}"; fi) (${RED}x${STAND} to abort): " DEV_MAC

	if [[ "$DEV_MAC" == x ]]; then

		echo "$show_info Going back to main menu." && mainmenu

	elif [[ "$DEV_MAC" =~ ^[a-fA-F0-9:]{17}$ ]]; then

		if [[ "$OPTION" == t ]]; then

			echo "$show_info Chosen device to trust: $DEV_MAC"
			if $trust_bt_device "$DEV_MAC" | grep "not available"; then echo "$show_error Chosen Bluetooth device MAC address is not available!"; else echo "$show_info Device ${GREEN}$DEV_MAC${STAND} trusted."; fi

		elif [[ "$OPTION" == u ]]; then

			echo "$show_info Chosen device to untrust: $DEV_MAC"
			if $untrust_bt_device "$DEV_MAC" | grep "not available"; then echo "$show_error Chosen Bluetooth device MAC address is not available!"; else echo "$show_info Device ${RED}$DEV_MAC${STAND} untrusted."; fi
		fi

	elif [[ "$DEV_MAC" == * ]]; then

		echo "$show_error MAC address incorrect! Try again." && _trust_untrust_mac_cmd
	fi
}
# F #

# START _trust_untrust_bt_device
_trust_untrust_bt_device(){

echo -e "\\n${WHITE}=> TRUST/UNTRUST Bluetooth DEVICES <=${STAND}"
echo -e "\\n$show_info Trusted/Untrusted devices: \\n"

get_default_bt_controller_MAC=$($list_bt_controller_available | grep default | awk '{print $2}')
#get_default_bt_controller_paired_devices=$(ls "/var/lib/bluetooth/$get_default_bt_controller_MAC" | grep -E "^[a-fA-F0-9:]{17}$")
get_default_bt_controller_paired_devices=$(find "$bluetooth_var_lib/$get_default_bt_controller_MAC/" -mindepth 1 -maxdepth 1 -type d -name "cache" -prune -o -type f -name "settings" -prune -o -printf "%f\\n")
get_first_result=$(echo "$get_default_bt_controller_paired_devices" | sed '/^\s*$/d' | wc -l)

if [[ -d "$bluetooth_var_lib/$get_default_bt_controller_MAC" ]]; then

	if [[ "$get_first_result" -gt 0 ]]; then

		for paired_devices in $get_default_bt_controller_paired_devices;
		do
			get_name=$(grep "Name=" /var/lib/bluetooth/"$get_default_bt_controller_MAC"/"$paired_devices"/info | cut -d '=' -f2)
			get_trust=$(grep "Trusted=" /var/lib/bluetooth/"$get_default_bt_controller_MAC"/"$paired_devices"/info | cut -d '=' -f2)
			echo "-> ${WHITE}Trusted: $(if [[ "$get_trust" == true ]]; then echo "${GREEN}$get_trust${STAND}"; else echo "${RED}$get_trust${STAND}"; fi) | ${WHITE}Device Name: ${YELLOW}$get_name${STAND} | ${WHITE}MAC: ${BLUE}$paired_devices${STAND}"
		done
		echo ""
	else
		echo -e "$show_info You don't have any device to trust/untrust.\\n" && mainmenu
	fi
else
	echo "$show_error Default Bluetooth controller not found! Do you have a default Bluetooth controller set?" && mainmenu
fi

read -r -e -p "$show_input Choose (${GREEN}t${STAND} to trust, ${RED}u${STAND} to untrust, ${BLUE}x${STAND} to abort): " OPTION

if [[ "$OPTION" == x ]]; then

	echo "$show_info Going back to main menu." && mainmenu

elif [[ "$OPTION" == t ]]; then

	_trust_untrust_mac_cmd

elif [[ "$OPTION" == u ]]; then

	_trust_untrust_mac_cmd

elif [[ "$OPTION" == * ]]; then

	echo "$show_error Wrong option. Try again.." && _trust_untrust_bt_device
fi
}
# END _trust_untrust_bt_device

# F #
_block_unblock_bt_device_cmd(){

	read -r -e -p "$show_input Write device MAC address to $(if [[ "$OPTION" == b ]]; then echo "${RED}block${STAND}"; elif [[ "$OPTION" == u ]]; then echo "${GREEN}unblock${STAND}"; fi) (${RED}x${STAND} to abort): " DEV_MAC

	if [[ "$DEV_MAC" == x ]]; then

		echo "$show_info Going back to main menu." && mainmenu

	elif [[ "$DEV_MAC" =~ ^[a-fA-F0-9:]{17}$ ]]; then

		if [[ "$OPTION" == b ]]; then

			echo "$show_info Chosen device to block: $DEV_MAC"
			if $block_bt_device "$DEV_MAC" | grep "not available"; then echo "$show_error Chosen Bluetooth device MAC address is not available!"; else echo "$show_info Device ${RED}$DEV_MAC${STAND} blocked."; fi

		elif [[ "$OPTION" == u ]]; then

			echo "$show_info Chosen device to unblock: $DEV_MAC"
			if $unblock_bt_device "$DEV_MAC" | grep "not available"; then echo "$show_error Chosen Bluetooth device MAC address is not available!"; else echo "$show_info Device ${GREEN}$DEV_MAC${STAND} unblocked."; fi
		fi

	elif [[ "$DEV_MAC" == * ]]; then

		echo "$show_error MAC address incorrect! Try again." && _block_unblock_bt_device_cmd
	fi
}
# F #

# START _block_unblock_bt_device
_block_unblock_bt_device(){

echo -e "\\n${WHITE}=> BLOCK/UNBLOCK Bluetooth DEVICES <=${STAND}"
echo -e "\\n$show_info Blocked/Unblocked devices: \\n"

get_default_bt_controller_MAC=$($list_bt_controller_available | grep default | awk '{print $2}')
#get_default_bt_controller_paired_devices=$(ls "$bluetooth_var_lib/$get_default_bt_controller_MAC/" | grep -E "^[a-fA-F0-9:]{17}$")
get_default_bt_controller_paired_devices=$(find "$bluetooth_var_lib/$get_default_bt_controller_MAC/" -mindepth 1 -maxdepth 1 -type d -name "cache" -prune -o -type f -name "settings" -prune -o -printf "%f\\n")
get_first_result=$(echo "$get_default_bt_controller_paired_devices" | sed '/^\s*$/d' | wc -l)

if [[ -d "$bluetooth_var_lib/$get_default_bt_controller_MAC" ]]; then

	if [[ "$get_first_result" -gt 0 ]]; then

		for paired_devices in $get_default_bt_controller_paired_devices;
		do

			get_name=$(grep "Name=" /var/lib/bluetooth/"$get_default_bt_controller_MAC"/"$paired_devices"/info | cut -d '=' -f2)
			get_block=$(grep "Blocked=" /var/lib/bluetooth/"$get_default_bt_controller_MAC"/"$paired_devices"/info | cut -d '=' -f2)

			echo "-> ${WHITE}Blocked: $(if [[ "$get_block" == true ]]; then echo "${GREEN}$get_block${STAND}"; else echo "${RED}$get_block${STAND}"; fi) | ${WHITE}Device Name: ${YELLOW}$get_name${STAND} | ${WHITE}MAC: ${BLUE}$paired_devices${STAND}"
		done
		echo ""
	else
		echo -e "$show_info You don't have any device to block/unblock.\\n" && mainmenu
	fi
else
	echo "$show_error Default Bluetooth controller not found! Do you have a default Bluetooth controller set?" && mainmenu
fi

read -r -e -p "$show_input Choose (${GREEN}b${STAND} to block, ${RED}u${STAND} to unblock, ${BLUE}x${STAND} to abort): " OPTION

if [[ "$OPTION" == x ]]; then

	echo "$show_info Going back to main menu." && mainmenu

elif [[ "$OPTION" == b ]]; then

	_block_unblock_bt_device_cmd

elif [[ "$OPTION" == u ]]; then

	_block_unblock_bt_device_cmd

elif [[ "$OPTION" == * ]]; then

	echo "$show_error Wrong option. Try again.." && _block_unblock_bt_device
fi
}
# END _block_unblock_bt_device

# START_REMOVE_BT_DEVICE
_remove_bt_device(){

	echo -e "\\n${WHITE}=> Remove Bluetooth device <=${STAND}"

	f_paired

	PAIRED_RETURN_CODE=$return

	if [ "$PAIRED_RETURN_CODE" -eq "1" ]; then

	_internal_f_call_remove_bt_device(){

		read -r -e -p "$show_input Enter device MAC to remove it (${RED}x${STAND} to abort): " RM_BT_DEVICE

		if [[ "$RM_BT_DEVICE" =~ ^[a-fA-F0-9:]{17}$ ]]; then

			if $remove_bt_device "$PAIRED_BT_DEVICE" | grep "not available"; then echo "$show_error Device MAC address is not available!"; else echo "$show_info ${YELLOW}$($remove_bt_device "$RM_BT_DEVICE")${STAND}"; fi

		elif [[ "$RM_BT_DEVICE" == x ]]; then

			echo "$show_info Going back to main menu." && mainmenu

		elif [[ "$RM_BT_DEVICE" == * ]]; then

			echo "$show_error MAC address incorrect! Try again." && _internal_f_call_remove_bt_device
		fi
	}
	_internal_f_call_remove_bt_device

	elif [ "$PAIRED_RETURN_CODE" -eq "0" ]; then
		echo "code is $PAIRED_RETURN_CODE"

		echo "$show_warning You don't have any paired devices!" && mainmenu
	fi
}
# END_REMOVE_BT_DEVICE

# START_DISCONNECT_BT_DEVICE
_disconnect_bt_device(){

echo -e "\\n${WHITE}=> DISCONNECT Bluetooth DEVICES <=${STAND}"
echo -e "\\n$show_info Connected devices: \\n"

get_default_bt_controller_MAC=$($list_bt_controller_available | grep default | awk '{print $2}')
#get_default_bt_controller_paired_devices=$(ls "$bluetooth_var_lib/$get_default_bt_controller_MAC/" | grep -E "^[a-fA-F0-9:]{17}$")
get_default_bt_controller_paired_devices=$(find "$bluetooth_var_lib/$get_default_bt_controller_MAC/" -mindepth 1 -maxdepth 1 -type d -name "cache" -prune -o -type f -name "settings" -prune -o -printf "%f\\n")
get_first_result=$(echo "$get_default_bt_controller_paired_devices" | sed '/^\s*$/d' | wc -l)

if [[ -d "$bluetooth_var_lib/$get_default_bt_controller_MAC" ]]; then

	if [[ "$get_first_result" -gt 0 ]]; then

		for paired_devices in $get_default_bt_controller_paired_devices;
		do
			get_name=$(bt-device -i "$paired_devices" | awk '/Name:/ {print $2}')
			get_connected=$(bt-device -i "$paired_devices" | awk '/Connected:/ {print $2}')

			echo "-> ${WHITE}Connected: $(if [[ "$get_connected" -eq 1 ]]; then echo "${GREEN}$show_connected${STAND}"; else echo "${RED}$show_disconnected${STAND}"; fi) | ${WHITE}Device Name: ${YELLOW}$get_name${STAND} | ${WHITE}MAC: ${BLUE}$paired_devices${STAND}"
		done
		echo ""
	else
		echo -e "$show_info You don't have any paired devices.\\n" && mainmenu
	fi
else
	echo "$show_error Default Bluetooth controller not found! Do you have a default Bluetooth controller set?" && mainmenu
fi

_internal_f_call_disconnect_bt_device(){

	read -r -e -p "$show_input Enter device MAC to disconnect (x to abort): " DC_MAC

	if [[ "$DC_MAC" =~ ^[a-fA-F0-9:]{17}$ ]]; then

		if bt-device -i "$DC_MAC" | grep -q "Connected: 1" > /dev/null; then

			echo "$show_execute Disconnecting..." && $disconnect_bt_device

		elif bt-device -i "$DC_MAC" | grep -q "Connected: 0" > /dev/null; then

			echo "$show_info Device with MAC ${BLUE}$DC_MAC${STAND} is already disconnected!"
		else
			echo "$show_error MAC address does not look like the one above!" && _internal_f_call_disconnect_bt_device
		fi

	elif [[ "$DC_MAC" == x ]]; then

		echo "$show_info Going back to main menu." && mainmenu

	elif [[ "$DC_MAC" == * ]]; then

		echo "$show_error MAC address incorrect! Try again." && _internal_f_call_disconnect_bt_device
	fi
}
_internal_f_call_disconnect_bt_device
}
# END_DISCONNECT_BT_DEVICE

#### Exit
_exit_rpibtman() {
	echo -e "\\nBye!"
	rm -f $tmp_paired_devs $tmp_connected_to_phone; exit 0
}
####

###MAIN MENU
function mainmenu () {
#### Infinite Loop To Show Menu Until Exit
while :
do
echo "${RED}+------------------------------------------------------------------+"
echo "${RED}|              RPIBTMAN              | -> Version: ${GREEN}$version             ${RED}|${STAND}"
echo "${RED}|   Raspberry Pi Bluetooth Manager   | -> Updated: ${GREEN}$last_update      ${RED}|${STAND}"
echo "${RED}+------------------------------------+-----------------------------+${WHITE}"
echo "|              Main Menu             |          Shortcuts          |"
echo "+------------------------------------+-----------------------------+"
echo "|  1. Available BT controllers       |  4s. List scanned BT devs   |"
echo "|  2. Select default BT controller   |  4p. List paired BT devs    |"
echo "|  3. Set/Reset BT controller alias  |  50. Bluetooth off          |"
echo "|  4. List scanned/paired BT devices |  51. Bluetooth on           |"
echo "|  5. Bluetooth status               |  60. Discoverable off       |"
echo "|  6. Discoverable status            |  61. Discoverable on        |"
echo "|  7. Pairable status                |  70. Pairable off           |"
echo "|  8. Receive Internet from phone    |  71. Pairable on            |"
echo "|  9. Transmit Internet from RPi     |                             |"
echo "| 10. Scan for Bluetooth devices     +-----------------------------+"
echo "| 11. Show paired BT device info     |            Utils            |"
echo "| 12. Trust/Untrust BT devices       +-----------------------------+"
echo "| 13. Block/Unblock BT devices       |  c1. Check dependencies     |"
echo "| 14. Remove BT device               |  c2. Config Bridge          |"
echo "| 15. Disconnect BT device           |  c3. Config ISC-DHCP-SERVER |"
echo "|  q. Exit                           |  c4. Config iptables        |"
echo "|                                    |  c5. Config services        |"
echo "+------------------------------------+-----------------------------+${STAND}"

read -r -e -p "Choose an option: " menuoption
case $menuoption in
1) _list_bt_controller_available ;;
2) _select_bt_controller_default ;;
3) _set_reset_system_bt_controller_alias ;;
4|4p|4s) _list_bt_devices ;;
5|50|51) _power_bt_controller_on_off ;;
6|60|61) _discoverable_bt_controller_on_off ;;
7|70|71) _pairable_bt_controller_on_off ;;
8) _receive_internet_from_phone ;;
9) _transmit_internet_from_rpi ;;
10) _scan_bt_devs ;;
11) _show_paired_bt_device_info ;;
12) _trust_untrust_bt_device ;;
13) _block_unblock_bt_device ;;
14) _remove_bt_device ;;
15) _disconnect_bt_device ;;
q) _exit_rpibtman ;;
c1) _config_check_deps ;;
c2) _config_bridge ;;
c3) _config_isc_dhcp_server ;;
c4) _config_iptables_rules ;;
c5) _config_services ;;
*) echo " \"$menuoption\" Is not a valid option!"; sleep 1 ;;
esac
done
}

if grep -q "DEPS=ok" "$first_time_config" 2>/dev/null && \
   grep -q "BR=ok" "$first_time_config" 2>/dev/null && \
   grep -q "ISC=ok" "$first_time_config" 2>/dev/null && \
   grep -q "IPT=ok" "$first_time_config" 2>/dev/null && \
   grep -q "SVC=ok" "$first_time_config" 2>/dev/null; then
	mainmenu
else
	ft_config
fi
