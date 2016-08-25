import os
import sys
import time

def test_main(item_num,item_name):
	print "%i:%s\n" % (item_num,item_name)
	return 0

if  __name__=='__main__':
    print test_main(0,"test first item name")
