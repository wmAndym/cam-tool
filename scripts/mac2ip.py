#!/usr/bin/python
# get ip_address from arp tables by mac_address ---2015/11/23 Jifu
import subprocess
import sys
import re,os
import plistlib

def broadcast_address_prefix():
	output = subprocess.check_output(['ifconfig'])
	for line in output.split('\n'):
		ret=re.findall("broadcast (\d+\.\d+\.\d+)\.\d+",line)
		if len(ret) > 0:
			return ret[0]
def pingall(prefix):
	for x in range(254,1,-1):
		os.system("ping -c 1 -t 1 %s.%s >/dev/null 2>&1" %(prefix,x))
		os.system("sleep 2")
		
if __name__ == "__main__":
	broadcast_address_prefix = broadcast_address_prefix()
	#pingall(broadcast_address_prefix)
	#subprocess.call(["ping -c 4 -t 1 %s.255" % broadcast_address_prefix],shell=True)
	os.system("echo `dirname %s`"%sys.argv[0])

	os.system("sh `dirname '%s'`/ping_all.command" % sys.argv[0])
	output = subprocess.check_output(['arp','-an'])
	list_output = output.split('\n')
	mac2ip={}
	for line in list_output:
		#print line
		ret=re.findall("\((\d+.*?)\)\s+at\s+(\w+\:\w+.*?)\s+",line)
		if len(ret) > 0:
			#print "MAC:"+ret[0][1] +" IP:"+ret[0][0]
			mac=ret[0][1]
			ip=ret[0][0]
			formated_mac = ":".join(map(lambda x:x if len(x)==2 else "0%s"% x ,mac.split(":")))
			mac2ip[formated_mac]=ret[0][0]
	print mac2ip
	plist_file_path = sys.argv[1]
	plistlib.writePlist(mac2ip,plist_file_path)

