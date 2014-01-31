#!/bin/bash

SERVER="status.botox.bz"
PORT=35601
USER="s01"
PASSWORD="some-hard-to-guess-copy-paste-password"
INTERVAL=1 # Update interval


while true; do
	PREV_TOTAL=0
	PREV_IDLE=0
	STRING=""
	CHECK_IP=0
	TIMER=0

	# Open connection
	echo "Connecting..."
	exec 3<>/dev/tcp/${SERVER}/${PORT}

	if ! echo "${USER}:${PASSWORD}" >&3; then
		echo "Disconnected..."
		sleep 3
		continue
	fi

	while IFS= read -t1 -u3 -rn1 b; do
		if [ "$b" ]; then
			STRING+=$b
		else
			STRING+=$'\n'
		fi
	done
	if grep -q "IPv6" <<< "$STRING"; then
		CHECK_IP=4
	elif grep -q "IPv4" <<< "$STRING"; then
		CHECK_IP=6
	else
		exit 1
	fi

	echo "Connected!"

	while true; do
		sleep $INTERVAL

		# Connectivity
		if [ $TIMER -ge 0 ]; then
			IP6_ADDR="2001:4860:4860::8888"
			IP4_ADDR="8.8.8.8"
			if [ $CHECK_IP == 4 ]; then
				if ping -c 1 -w 1 $IP4_ADDR &> /dev/null; then
					Online="\"online4\": true"
				else
					Online="\"online4\": false"
				fi
			elif [ $CHECK_IP == 6 ]; then
				if ping6 -c 1 -w 1 $IP6_ADDR &> /dev/null; then
					Online="\"online6\": true"
				else
					Online="\"online6\": false"
				fi
			fi
			TIMER=10
		else
			let TIMER-=1*INTERVAL
		fi

		# Uptime
		Uptime=$(awk '{ print int($1) }' /proc/uptime)

		# Load Average
		Load=$(awk '{ print $1 }' /proc/loadavg)

		# Memory
		MemTotal=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
		MemFree=$(awk '/MemFree/ {print $2}' /proc/meminfo)
		Cached=$(awk '/\<Cached\>/ {print $2}' /proc/meminfo)
		MemUsed=$(($MemTotal - ($Cached + $MemFree)))

		# Disk
		HDD=$(df -Tlm --total -t ext4 -t ext3 -t ext2 -t reiserfs -t jfs -t ntfs -t fat32 -t btrfs -t fuseblk -t zfs -t simfs | tail -n 1)
		HDDTotal=$(echo -n ${HDD} | awk '{ print $3 }')
		HDDUsed=$(echo -n ${HDD} | awk '{ print $4 }')

		# CPU
		# Get the total CPU statistics, discarding the 'cpu ' prefix.
		CPU=($(sed -n 's/^cpu\s//p' /proc/stat))
		IDLE=${CPU[3]} # Just the idle CPU time.
		# Calculate the total CPU time.
		TOTAL=0
		for VALUE in "${CPU[@]}"; do
			let "TOTAL=$TOTAL+$VALUE"
		done
		# Calculate the CPU usage since we last checked.
		let "DIFF_IDLE=$IDLE-$PREV_IDLE"
		let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
		let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
		# Remember the total and idle CPU times for the next check.
		PREV_TOTAL="$TOTAL"
		PREV_IDLE="$IDLE"

		echo -e "update {$Online, \"uptime\": $Uptime, \"load\": $Load, \"memory_total\": $MemTotal, \"memory_used\": $MemUsed, \"hdd_total\": $HDDTotal, \"hdd_used\": $HDDUsed, \"cpu\": ${DIFF_USAGE}.0}"
	done >&3

	# keep on trying after a disconnect
	echo "Disconnected..."
	sleep 3
	echo "Reconnecting..."
done
