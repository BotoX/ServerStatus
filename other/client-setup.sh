#!/bin/bash

normal=$(tput sgr0)
bold=$(tput bold)

PYTHON_CLIENT="https://raw.github.com/BotoX/ServerStatus/master/clients/client.py"
PYTHONPSUTIL_CLIENT="https://raw.github.com/BotoX/ServerStatus/master/clients/client-psutil.py"
BASH_CLIENT="https://raw.github.com/BotoX/ServerStatus/master/clients/client.sh"

CWD=$(pwd)

command_exists () {
	type "$1" &> /dev/null ;
}

if ! command_exists curl; then
	echo "curl not found, install it."
	exit 1
fi

user_input ()
{
	args="${@:2}"
	while [ true ]; do
		answer=""
		printf "~> "

		if [ "$1" ]; then
			args="${@:1}"
			read answer
			if [ "$answer" == "" ]; then
				answer=$1
				echo -en "\033[1A\033[2K"
				echo "~> $1"
				break
			fi
		else
			while [ true ]; do
				read answer
				if [ "$answer" == "" ]; then
					echo "${bold}Invalid input!${normal}"
					printf "~> "
				else
					break
				fi
			done
		fi

		if [ "$2" ]; then
			for arg in $args; do
				if [ "$arg" == "_NUM" ] && [ "${answer##*[!0-9]*}" ]; then
					break 2
				elif [ "${arg,,}" == "${answer,,}" ]; then
					break 2
				fi
			done
			echo "${bold}Invalid input!${normal}"
		else
			break
		fi
	done
}

echo
echo "ServerStatus Client Setup Script"
echo "https://github.com/BotoX/ServerStatus"
echo

echo "Which client implementation do you want to use? [${bold}python${normal}, python-psutil, bash]"
user_input "python" "python-psutil" "bash"
CLIENT="${answer,,}"

if [ "$CLIENT" == "python" ] && [ -f "${CWD}/serverstatus-client.py" ]; then
	echo "Python implementation already found in ${CWD}"
	echo "Do you want to skip the client configuration and update it? [${bold}yes${normal}/no]"
	user_input "yes" "no" "y" "n"
	if [ "${answer,,}" == "yes" ] || [ "${answer,,}" == "y" ]; then
		CLIENT_BIN="${CWD}/serverstatus-client.py"
		SKIP=true
	fi
elif [ "$CLIENT" == "python-psutil" ] && [ -f "${CWD}/serverstatus-client-psutil.py" ]; then
	echo "Python-psutil implementation already found in ${CWD}"
	echo "Do you want to skip the client configuration and update it? [${bold}yes${normal}/no]"
	user_input "yes" "no" "y" "n"
	if [ "${answer,,}" == "yes" ] || [ "${answer,,}" == "y" ]; then
		CLIENT_BIN="${CWD}/serverstatus-client-psutil.py"
		SKIP=true
	fi
elif [ "$CLIENT" == "bash" ] && [ -f "${CWD}/serverstatus-client.sh" ]; then
	echo "Bash implementation already found in ${CWD}"
	echo "Do you want to skip the client configuration and update it? [${bold}yes${normal}/no]"
	user_input "yes" "no" "y" "n"
	if [ "${answer,,}" == "yes" ] || [ "${answer,,}" == "y" ]; then
		CLIENT_BIN="${CWD}/serverstatus-client.sh"
		SKIP=true
	fi
fi

if [ ! $SKIP ]; then
	echo "What is your status servers address (${bold}DNS${normal} or IP)?"
	user_input
	SERVER="$answer"

	echo "What is your status servers port? [${bold}35601${normal},...]"
	user_input 35601 _NUM
	PORT="$answer"

	echo "Specify the username."
	user_input
	USERNAME="$answer"

	echo "Specify a password for the user."
	user_input
	PASSWORD="$answer"
else
	DATA=$(head -n 9 "$CLIENT_BIN")

	SERVER=$(echo "$DATA" | sed -n "s/SERVER\( \|\)=\( \|\)//p" | tr -d '"')
	PORT=$(echo "$DATA" | sed -n "s/PORT\( \|\)=\( \|\)//p" | tr -d '"')
	USERNAME=$(echo "$DATA" | sed -n "s/USER\( \|\)=\( \|\)//p" | tr -d '"')
	PASSWORD=$(echo "$DATA" | sed -n "s/PASSWORD\( \|\)=\( \|\)//p" | tr -d '"')
fi

echo
echo "${bold}Summarized settings:${normal}"
echo
echo -e "Client implementation:\t${bold}$CLIENT${normal}"
echo -e "Status server address:\t${bold}$SERVER${normal}"
echo -e "Status server port:\t${bold}$PORT${normal}"
echo -e "Username:\t\t${bold}$USERNAME${normal}"
echo -e "Password:\t\t${bold}$PASSWORD${normal}"
echo

echo "Is this correct? [${bold}yes${normal}/no]"
user_input "yes" "no" "y" "n"

if [ "${answer,,}" != "yes" ] && [ "${answer,,}" != "y" ]; then
	echo "Aborting."
	echo "You may want to rerun this script."
	exit 1
fi

if [ "$CLIENT" == "python" ]; then
	echo "Magic going on..."
	curl "$PYTHON_CLIENT" | sed -e "0,/^SERVER = .*$/s//SERVER = \"${SERVER}\"/" \
		-e "0,/^PORT = .*$/s//PORT = ${PORT}/" \
		-e "0,/^USER = .*$/s//USER = \"${USERNAME}\"/" \
		-e "0,/^PASSWORD = .*$/s//PASSWORD = \"${PASSWORD}\"/" > "${CWD}/serverstatus-client.py"
	chmod +x "${CWD}/serverstatus-client.py"
	CLIENT_BIN="${CWD}/serverstatus-client.py"
	echo
	echo "Python client copied to ${CWD}/serverstatus-client.py"

elif [ "$CLIENT" == "python-psutil" ]; then
	echo "Magic going on..."
	curl "$PYTHONPSUTIL_CLIENT" | sed -e "0,/^SERVER = .*$/s//SERVER = \"${SERVER}\"/" \
		-e "0,/^PORT = .*$/s//PORT = ${PORT}/" \
		-e "0,/^USER = .*$/s//USER = \"${USERNAME}\"/" \
		-e "0,/^PASSWORD = .*$/s//PASSWORD = \"${PASSWORD}\"/" > "${CWD}/serverstatus-client-psutil.py"
	chmod +x "${CWD}/serverstatus-client.py"
	CLIENT_BIN="${CWD}/serverstatus-client-psutil.py"
	echo
	echo "Python-psutil client copied to ${CWD}/serverstatus-client-psutil.py"

elif [ "$CLIENT" == "bash" ]; then
	echo "Magic going on..."
	curl "$BASH_CLIENT" | sed -e "0,/^SERVER=.*$/s//SERVER=\"${SERVER}\"/" \
		-e "0,/^PORT=.*$/s//PORT=${PORT}/" \
		-e "0,/^USER=.*$/s//USER=\"${USERNAME}\"/" \
		-e "0,/^PASSWORD=.*$/s//PASSWORD=\"${PASSWORD}\"/" > "${CWD}/serverstatus-client.sh"
	chmod +x "${CWD}/serverstatus-client.sh"
	CLIENT_BIN="${CWD}/serverstatus-client.sh"
	echo
	echo "Bash client copied to ${CWD}/serverstatus-client.sh"
fi

echo -e "Do you want to autostart the script with your system? \e[0;31mThis requires sudo.\e[0m [${bold}yes${normal}/no]"
user_input "yes" "no" "y" "n"
if [ "${answer,,}" != "yes" ] && [ "${answer,,}" != "y" ]; then
	echo "Aborting."
	echo "Don't forget to start the script, it is recommended that you add it to your autostart too!"
	exit 0
fi

echo "Trying to detect the init system..."

# try to detect systemd, otherwise default to SysVinit
INIT="sysvinit"

if [ -f /proc/1/comm ]; then
	if grep -qi systemd /proc/1/comm; then
		INIT="systemd"
	fi
fi

if grep -qi systemd /proc/1/cmdline; then
	INIT="systemd"
fi

if [ "$INIT" == "systemd" ]; then
	echo "Systemd has been detected, is this correct? [${bold}yes${normal}/no]"
	user_input "yes" "no" "y" "n"
	if [ "${answer,,}" != "yes" ] && [ "${answer,,}" != "y" ]; then
		echo "Okay, SysVinit it is then."
		INIT="sysvinit"
	fi
else
	echo "SysVinit has been detected, is this correct? [${bold}yes${normal}/no]"
	user_input "yes" "no" "y" "n"
	if [ "${answer,,}" != "yes" ] && [ "${answer,,}" != "y" ]; then
		echo "Okay, systemd it is then."
		INIT="systemd"
	fi
fi

# Install client script
if [ "$CLIENT" == "bash" ]; then
	DAMN_IT_BASH="IgnoreSIGPIPE=no"
fi
_CLIENT=$(echo "$CLIENT_BIN" | sed "s|$CWD|/usr/local/share|g")
echo "Installing script to $_CLIENT"
if [ -f $_CLIENT ]; then
	echo "Target already exists, overwrite? [${bold}yes${normal}/no]"
	user_input "yes" "no" "y" "n"
	if [ "${answer,,}" != "yes" ] && [ "${answer,,}" != "y" ]; then
		echo "Aborting."
		exit 1
	fi
fi
sudo cp -a "$CLIENT_BIN" "$_CLIENT"

# Install service
if [ "$INIT" == "systemd" ]; then
	echo "Under which user should the script be run? [${bold}http${normal}, ...]"
	user_input "http"
	RUNUSER="$answer"
	if ! id -u "$RUNUSER" >/dev/null 2>&1; then
		echo "Aborting."
		echo "The specified user \"$RUNUSER\" could not be found!"
		exit 1
	fi
	echo "Installing systemd service to /etc/systemd/system/serverstatus.service"
	if [ -f /etc/systemd/system/serverstatus.service ]; then
		echo "Service already exists, overwrite? [${bold}yes${normal}/no]"
		user_input "yes" "no" "y" "n"
		if [ "${answer,,}" != "yes" ] && [ "${answer,,}" != "y" ]; then
			echo "Aborting."
			exit 1
		fi
		REPLACE=true
	fi

	sudo tee "/etc/systemd/system/serverstatus.service" > /dev/null <<__EOF__
[Unit]
Description=ServerStatus Client
After=network.target

[Service]
Type=simple
$DAMN_IT_BASH
User=$RUNUSER
ExecStart=$_CLIENT

[Install]
WantedBy=multi-user.target
__EOF__

	echo "Starting service..."
	echo
	sudo chown "$RUNUSER" "$_CLIENT"
	if [ $REPLACE ]; then
		sudo systemctl stop serverstatus.service
		sleep 1
		sudo systemctl daemon-reload
	fi
	sudo systemctl start serverstatus.service
	sleep 1
	systemctl status serverstatus.service
	echo
	echo "Should be started. Adding service to autostart..."
	echo
	sleep 1
	sudo systemctl enable serverstatus.service
	echo
	echo "Done."

else # if [ "$INIT" == "sysvinit" ]; then
	echo "Under which user should the script be run? [${bold}www-data${normal}, ...]"
	user_input "www-data"
	RUNUSER="$answer"
	if ! id -u "$RUNUSER" >/dev/null 2>&1; then
		echo "Aborting."
		echo "The specified user \"$RUNUSER\" could not be found!"
		exit 1
	fi
	echo "Installing init.d script to /etc/init.d/serverstatus"
	if [ -f /etc/init.d/serverstatus ]; then
		echo "Init.d script already exists. Overwrite? [${bold}yes${normal}/no]"
		user_input "yes" "no" "y" "n"
		if [ "${answer,,}" != "yes" ] && [ "${answer,,}" != "y" ]; then
			echo "Aborting."
			exit 1
		fi
		REPLACE=true
	fi

	sudo tee "/etc/init.d/serverstatus" > /dev/null <<__EOF__
#!/bin/sh
### BEGIN INIT INFO
# Provides:          serverstatus
# Required-Start:    \$remote_fs \$network
# Required-Stop:     \$remote_fs \$network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: ServerStatus Client
# Description:       ServerStatus Client
### END INIT INFO

. /lib/lsb/init-functions

DAEMON="$_CLIENT"
RUNAS="$RUNUSER"
DESC="ServerStatus Client"

PIDFILE=/var/run/serverstatus.pid

test -x "\$DAEMON" || exit 5

case \$1 in
	start)
		log_daemon_msg "Starting \$DESC"
		start-stop-daemon --start --background --pidfile "\$PIDFILE" --make-pidfile --chuid "\$RUNAS" --startas "\$DAEMON"

		if [ \$? -ne 0 ]; then
			log_end_msg 1
		else
			log_end_msg 0
		fi
		;;
	stop)
		log_daemon_msg "Stopping \$DESC"
		start-stop-daemon --stop --pidfile "\$PIDFILE" --retry 5

		if [ \$? -ne 0 ]; then
			log_end_msg 1
		else
			log_end_msg 0
		fi
		;;
	restart)
		\$0 stop
		sleep 1
		\$0 start
		;;
	status)
		status_of_proc -p "\$PIDFILE" "\$DAEMON" "serverstatus" && exit 0 || exit \$?
		;;
	*)
		echo "Usage: \$0 {start|stop|restart|status}"
		exit 2
		;;
esac
__EOF__

	echo "Starting service..."
	echo
	sudo chown "$RUNUSER" "$_CLIENT"
	sudo chmod +x /etc/init.d/serverstatus
	if [ $REPLACE ]; then
		sudo service serverstatus stop
		sleep 1
	fi
	sudo service serverstatus start
	sleep 1
	sudo service serverstatus status
	echo
	echo "Should be started. Adding service to autostart..."
	echo
	sleep 1
	sudo update-rc.d serverstatus defaults
	echo
	echo "Done."
fi

if [ ! $SKIP ]; then
	echo
	echo "In case you haven't already added the new client to the master server:"
	echo

	echo -e "\t\t{"
	echo -e "\t\t\t\"name\": \"Change me\","
	echo -e "\t\t\t\"type\": \"Change me\","
	echo -e "\t\t\t\"host\": \"Change me\","
	echo -e "\t\t\t\"location\": \"Change me\","
	echo -e "\t\t\t\"username\": \"$USERNAME\","
	echo -e "\t\t\t\"password\": \"$PASSWORD\","
	echo -e "\t\t},"
fi

echo
echo "Have fun."
echo

exit 0