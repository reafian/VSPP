#! /usr/bin/python3
import json
import sys
import os

source = sys.argv[1]
destination = str(source)+"_output.txt"

if os.path.exists(destination):
	os.remove(destination)

with open(source) as myfile:
	filedata=json.load(myfile)

frames = []
for properties in filedata['frames']:
#	print(properties)
	for key, value in properties.items():
#		if key == "pktpts":
#			pkt_pts = value
		if key == "pict_type":
			picttype = value.strip()

			if picttype == "I":
				picttype = " I"

				txt = ''
				for i in frames:
					txt += str(i)

				if len(txt) > 1:
					print(txt)
					with open(destination, 'a') as output:
						output.write(str(txt)+"\n")

				frames = []
#				frames.append(pktpts)
				frames.append(picttype)
			else:
				frames.append(picttype)