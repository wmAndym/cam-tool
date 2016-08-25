#!/usr/bin/python

# convert file format between csv and plist. --2015/11/23 Jifu.

import argparse
import csv
import plistlib
csv_header=['Signal_Name', 'Port_Name', 'Port_Type', 'Wait_Before_Run']
def build_argparser():
    '''Create and return the command line argument parser'''
    parser = argparse.ArgumentParser(
        description='build sequnce file from both csv and plist file format')
    parser.add_argument(
        '-s', metavar='SOURCE_FILE_PATH', required=True, type=str, dest='source_file_path',
        help='Specifies the source file path')
    parser.add_argument(
        '-t', metavar='TARGET_FILE_PATH', required=True,type=str, dest='target_file_path',
        help='Specifies the target file path')
    parser.add_argument(
        '-p', metavar='PURPOSE', type=str, dest='purpose',
        default="csv2plist",
        help='the purpose of csv2plist or plist2csv')
    return parser
    
def csv2plist(source_file_path,target_file_path):
	plist_contents = []
	with open(source_file_path,'rb') as csvfile:
		csv_reader= csv.reader(csvfile)
		csv_column_counts=len(csv_header)
		for row in csv_reader:
			if row == csv_header:
				pass
			elif len(row) == csv_column_counts:
				item = dict(zip(csv_header,row))
				plist_contents.append(item)
	plistlib.writePlist(plist_contents,target_file_path)

def plist2csv(source_file_path,target_file_path):
	csv_contents = plistlib.readPlist(source_file_path)
	csv_list = map(lambda l:[l[x] for x in csv_header] ,csv_contents)
	#csv_list.insert(0,csv_header)
	with open(target_file_path,'wb') as plistfile:
		csv_writer=csv.writer(plistfile)
		csv_writer.writerow(csv_header)
		csv_writer.writerows(csv_list)
	
def  convert_file(source_file_path,target_file_path,purpose):
	if purpose == "csv2plist":
		csv2plist(source_file_path,target_file_path)
	else:
		plist2csv(source_file_path,target_file_path)
		
if __name__ == "__main__":
    
    aparser=build_argparser()
    args=aparser.parse_args()
    convert_file(args.source_file_path,args.target_file_path,args.purpose)
    