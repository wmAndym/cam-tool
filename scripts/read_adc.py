#!/usr/bin/python
# obtain CPU and SSD voltage from CAM board ---2015/11/23 Jifu

import socket
import sys
import os
import plistlib
from argparse import ArgumentParser

def read_adc_from_cam(ip,dict):
	link=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
	link.settimeout(1)
	ai_list = ("AIN4","AIN5")
	try:
		link.connect((ip,5555))
		for c in ai_list:
				link.sendall("&8s"+ c[-1])
				data=link.recv(2024)
				s=data.strip()
				sample=int(s[0]+s[1]+s[2],16)
				read=float(sample)/1000
				#print c+ "--" + str(read*10) + "V"
				dict[ip][c] = str(read*10)
		link.close()
	except:
		for c in ai_list:
			dict[ip][c] = str(0)
if __name__ == "__main__":
	parser =ArgumentParser(description='get the analog voltage at the command line')
	parser.add_argument('--ip', dest='ip_addrs', action='store', type=str, metavar='ADDRESS',nargs='+',help='Read a register. With an arg, write a register.')
	parser.add_argument('--file', dest='file_name', action='store', type=str, metavar='FILE NAME',help='Read a register. With an arg, write a register.')
	args = parser.parse_args()
	plist_file_path = args.file_name
	dict={}
	for ip in args.ip_addrs:
		dict[ip]={}
		read_adc_from_cam(ip,dict)
		plistlib.writePlist(dict,plist_file_path)
