#!/bin/bash

normal=$(tput sgr0)
bold=$(tput bold)

PYTHON_CLIENT="https://raw.github.com/BotoX/ServerStatus/master/clients/client.py"
BASH_CLIENT="https://raw.github.com/BotoX/ServerStatus/master/clients/client.sh"

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
				if [ "$arg" == "_NUM" ]; then
					if [ "${answer##*[!0-9]*}" ]; then
						break 2
					fi
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

echo "Which client implementation do you want to use? [${bold}python${normal}, bash]"
user_input "python" "bash"
CLIENT="${answer,,}"

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
user_input "yes" "no"

if [ "${answer,,}" == "no" ]; then
	echo "Aborting."
	echo "You may want to rerun this script."
	exit 1
fi

if [ "$CLIENT" == "python" ]; then
	echo "Magic going on..."
	curl "$PYTHON_CLIENT" | sed -e "0,/^SERVER = .*$/s//SERVER = \"${SERVER}\"/" \
		-e "0,/^PORT = .*$/s//PORT = ${PORT}/" \
		-e "0,/^USER = .*$/s//USER = \"${USERNAME}\"/" \
		-e "0,/^PASSWORD = .*$/s//PASSWORD = \"${PASSWORD}\"/" > client.py
	chmod +x client.py

elif [ "$CLIENT" == "bash" ]; then
	echo "Magic going on..."
	curl "$BASH_CLIENT" | sed -e "0,/^SERVER=.*$/s//SERVER=\"${SERVER}\"/" \
		-e "0,/^PORT=.*$/s//PORT=${PORT}/" \
		-e "0,/^USER=.*$/s//USER=\"${USERNAME}\"/" \
		-e "0,/^PASSWORD=.*$/s//PASSWORD=\"${PASSWORD}\"/" > client.sh
	chmod +x client.sh
fi
