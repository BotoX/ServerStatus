#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import socket
import time
import string
import math
import os
import json
import collections
import psutil
import ConfigParser

def get_uptime():
	return int(time.time() - psutil.boot_time())

def get_memory():
	Mem = psutil.virtual_memory()
	try:
		MemUsed = Mem.total - (Mem.cached + Mem.free)
	except:
		MemUsed = Mem.total - Mem.free
	return int(Mem.total/1024.0), int(MemUsed/1024.0)

def get_swap():
	Mem = psutil.swap_memory()
	return int(Mem.total/1024.0), int(Mem.used/1024.0)

def get_hdd():
	valid_fs = [ "ext4", "ext3", "ext2", "reiserfs", "jfs", "btrfs", "fuseblk", "zfs", "simfs", "ntfs", "fat32", "exfat" ]
	disks = dict()
	size = 0
	used = 0
	for disk in psutil.disk_partitions():
		if not disk.device in disks and disk.fstype.lower() in valid_fs:
			disks[disk.device] = disk.mountpoint
	for disk in disks.itervalues():
		usage = psutil.disk_usage(disk)
		size += usage.total
		used += usage.used
	return int(size/1024.0/1024.0), int(used/1024.0/1024.0)

def get_load():
	try:
		return os.getloadavg()[0]
	except:
		return -1.0

def get_cpu():
	return psutil.cpu_percent(interval=INTERVAL)

class Traffic:
	def __init__(self):
		self.rx = collections.deque(maxlen=10)
		self.tx = collections.deque(maxlen=10)
	def get(self):
		avgrx = 0; avgtx = 0
		for name, stats in psutil.net_io_counters(pernic=True).iteritems():
			if name == "lo" or name.find("tun") > -1:
				continue
			avgrx += stats.bytes_recv
			avgtx += stats.bytes_sent

		self.rx.append(avgrx)
		self.tx.append(avgtx)
		avgrx = 0; avgtx = 0

		l = len(self.rx)
		for x in range(l - 1):
			avgrx += self.rx[x+1] - self.rx[x]
			avgtx += self.tx[x+1] - self.tx[x]

		avgrx = int(avgrx / l / INTERVAL)
		avgtx = int(avgtx / l / INTERVAL)

		return avgrx, avgtx

def get_network(ip_version):
	if(ip_version == 4):
		HOST = "ipv4.google.com"
	elif(ip_version == 6):
		HOST = "ipv6.google.com"
	try:
		s = socket.create_connection((HOST, 80), 2)
		return True
	except:
		pass
	return False

if __name__ == '__main__':
	config = ConfigParser.RawConfigParser()
	config.read("client.cfg")
	SERVER = config.get("client", "SERVER")
	PORT = config.getint("client", "PORT")
	USER = config.get("client", "USER")
	PASSWORD = config.get("client", "PASSWORD")
	INTERVAL = config.getint("client", "INTERVAL")

	socket.setdefaulttimeout(30)
	while 1:
		try:
			print("Connecting...")
			s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			s.connect((SERVER, PORT))
			data = s.recv(1024)
			if data.find("Authentication required") > -1:
				s.send(USER + ':' + PASSWORD + '\n')
				data = s.recv(1024)
				if data.find("Authentication successful") < 0:
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
			if data.find("IPv4") > -1:
				check_ip = 6
			elif data.find("IPv6") > -1:
				check_ip = 4
			else:
				print(data)
				raise socket.error

			traffic = Traffic()
			traffic.get()
			while 1:
				CPU = get_cpu()
				NetRx, NetTx = traffic.get()
				Uptime = get_uptime()
				Load = get_load()
				MemoryTotal, MemoryUsed = get_memory()
				SwapTotal, SwapUsed = get_swap()
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
				array['swap_total'] = SwapTotal
				array['swap_used'] = SwapUsed
				array['hdd_total'] = HDDTotal
				array['hdd_used'] = HDDUsed
				array['cpu'] = CPU
				array['network_rx'] = NetRx
				array['network_tx'] = NetTx

				s.send("update " + json.dumps(array) + "\n")
		except KeyboardInterrupt:
			raise
		except socket.error:
			print("Disconnected...")
			# keep on trying after a disconnect
			s.close()
			time.sleep(3)
		except Exception as e:
			print("Caught Exception:", e)
			s.close()
			time.sleep(3)
