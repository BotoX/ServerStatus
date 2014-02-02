#!/usr/bin/env python2
# -*- coding: utf-8 -*-

SERVER = "status.botox.bz"
PORT = 35601
USER = "s01"
PASSWORD = "some-hard-to-guess-copy-paste-password"
INTERVAL = 1 # Update interval


import socket
import time
import string
import math
import re
import os
import json
import subprocess

def get_uptime():
	f = open('/proc/uptime', 'r')
	uptime = f.readline()
	f.close()
	uptime = uptime.split('.', 2)
	time = int(uptime[0])
	return int(time)

def get_memory():
	re_parser = re.compile(r'^(?P<key>\S*):\s*(?P<value>\d*)\s*kB')
	result = dict()
	for line in open('/proc/meminfo'):
		match = re_parser.match(line)
		if not match:
			continue;
		key, value = match.groups(['key', 'value'])
		result[key] = int(value)

	MemTotal = float(result['MemTotal'])
	MemFree = float(result['MemFree'])
	Cached = float(result['Cached'])
	MemUsed = MemTotal - (Cached + MemFree)
	return int(MemTotal), int(MemUsed)

def get_hdd():
	p = subprocess.check_output(['df', '-Tlm', '--total', '-t', 'ext4', '-t', 'ext3', '-t', 'ext2', '-t', 'reiserfs', '-t', 'jfs', '-t', 'ntfs', '-t', 'fat32', '-t', 'btrfs', '-t', 'fuseblk', '-t', 'zfs', '-t', 'simfs']).decode("Utf-8")
	total = p.splitlines()[-1]
	used = total.split()[3]
	size = total.split()[2]
	return int(size), int(used)

def get_load():
	return os.getloadavg()[0]

def get_time():
	stat_file=file("/proc/stat", "r")
	time_list=stat_file.readline().split(" ")[2:6]
	stat_file.close()
	for i in range(len(time_list))  :
		time_list[i]=int(time_list[i])
	return time_list
def delta_time():
	x=get_time()
	time.sleep(INTERVAL)
	y=get_time()
	for i in range(len(x)):
		y[i]-=x[i]
	return y
def get_cpu():
	t=delta_time()
	result=100-(t[len(t)-1]*100.00/sum(t))
	return round(result)

def get_network(ip_version):
	IP6_ADDR = "2001:4860:4860::8888"
	IP4_ADDR = "8.8.8.8"

	ping = 1
	if(ip_version == 4):
		ping = os.system("ping -c 1 -w 1 " + IP4_ADDR + " > /dev/null 2>&1")
	elif(ip_version == 6):
		ping = os.system("ping6 -c 1 -w 1 " + IP6_ADDR + " > /dev/null 2>&1")

	if ping:
		return False
	else:
		return True

if __name__ == '__main__':
	while 1:
		try:
			print("Connecting...")
			s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			s.connect((SERVER, PORT))
			data = str(s.recv(1024))
			if data == 'Authentication required:\n\x00\x00':
				s.send(USER+":"+PASSWORD+"\n")
				data = s.recv(1024)
				if(data != 'Authentication successful. Access granted.\n\x00\x00'):
					print(data)
					raise socket.error
			else:
				print(data)
				raise socket.error

			print(data)
			data = s.recv(1024)
			print(data)

			timer = 0
			check_ip = 0
			if(data == "You are connecting via: IPv4\n\x00\x00"):
				check_ip = 6
			elif(data == "You are connecting via: IPv6\n\x00\x00"):
				check_ip = 4

			while 1:
				CPU = get_cpu()
				Uptime = get_uptime()
				Load = get_load()
				MemoryTotal, MemoryUsed = get_memory()
				HDDTotal, HDDUsed = get_hdd()

				array = {}
				if not timer:
					array['online' + str(check_ip)] = get_network(check_ip)
					timer = 10
				else:
					timer -= 1*INTERVAL

				array['uptime'] = Uptime
				array['load'] = Load
				array['memory_total'] = MemoryTotal
				array['memory_used'] = MemoryUsed
				array['hdd_total'] = HDDTotal
				array['hdd_used'] = HDDUsed
				array['cpu'] = CPU

				s.send("update " + json.dumps(array) + "\n")
		except KeyboardInterrupt:
			raise
		except socket.error:
			# keep on trying after a disconnect
			s.close()
			print("Disconnected...")
			time.sleep(3)
