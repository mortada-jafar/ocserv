#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

### BEGIN INIT INFO
# Provides:          ocserv - OpenConnect VPN server
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop:     $network $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Openconnect VPN server (ocserv) is a VPN server compatible with the openconnect VPN client.
# Description:       Start or stop the ocserv
### END INIT INFO

NAME="ocserv"
CONFIG="/etc/ocserv/ocserv.conf"
PID_FILE="/var/run/ocserv.pid"
LOG="/tmp/ocserv.log"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[Info]${Font_color_suffix}"
Error="${Red_font_prefix}[Error]${Font_color_suffix}"
RETVAL=0

check_running(){
	[[ ! -e ${PID_FILE} ]] && return 1
	PID=$(cat ${PID_FILE})
	if [[ ! -z ${PID} ]]; then
		return 0
	else
		return 1
	fi
}
do_start(){
	check_running
	if [[ $? -eq 0 ]]; then
		echo -e "${Info} $NAME (PID ${PID}) running..." && exit 0
	else
		echo -e "${Info} $NAME starting..."
		ulimit -n 51200
		nohup ocserv -f -d 1 -c "${CONFIG}" > "${LOG}" 2>&1 &
		sleep 2s
		check_running
		if [[ $? -eq 0 ]]; then
			echo -e "${Info} $NAME Start Successfully !"
		else
			echo -e "${Error} $NAME Startup Failed !"
			cat ${Log}
		fi
	fi
}
do_stop(){
	check_running
	if [[ $? -eq 0 ]]; then
		kill -9 ${PID}
		RETVAL=$?
		if [[ $RETVAL -eq 0 ]]; then
			rm -f ${PID_FILE}
			echo -e "${Info} $NAME Stop Success !"
		else
			echo -e "${Error} $NAME Stop Failure !"
		fi
	else
		echo -e "${Info} $NAME Not Running"
		RETVAL=1
	fi
}
do_status(){
	check_running
	if [[ $? -eq 0 ]]; then
		echo -e "${Info} $NAME (PID $(echo ${PID})) Running..."
	else
		echo -e "${Info} $NAME Not Running !"
		RETVAL=1
	fi
}
do_restart(){
	do_stop
	do_start
}
do_log(){
	[[ ! -e ${LOG} ]] && echo -e "${Error} log file does not exist !" && exit 0
	echo && echo -e " According to ${Red_font_prefix}Ctrl+C${Font_color_suffix} Stop viewing logs" && echo
	tail -f ${LOG}
}
do_test(){
	check_running
	if [[ $? -eq 0 ]]; then
		echo -e "${Info} $NAME (PID ${PID}) Running..." && exit 0
	fi
	echo && echo -e " Prompts for notes do not affect the use, but prompts for Errors do." && echo
	ocserv -f -t -c ${CONFIG}
}
case "$1" in
	start|stop|restart|status|log|test)
	do_$1
	;;
	*)
	echo "Instructions: $0 { start | stop | restart | status | log | test }"
	RETVAL=1
	;;
esac
exit $RETVAL