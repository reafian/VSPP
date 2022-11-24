#! /usr/bin/python3
import json
import sys
import os

if len(sys.argv) < 2:
	sys.exit("A file needs to be given for this to work.")

source = sys.argv[1]
destination = str(source).split(".")[0]+"_output.txt"

if os.path.exists(destination):
	os.remove(destination)

with open(source) as myfile:
	filedata=json.load(myfile)

frames = []
for properties in filedata['frames']:
#	print(properties)
	for key, value in properties.items():
		if key == "pts":
			pts = value
		else:
			pts = None
		if key == "pict_type":
			picttype = value.strip()

			if picttype == "I":
				picttype = " I"

				txt = ''
				count = 0
				for i in frames:
					txt += str(i)
					count += 1

				if len(txt) > 1:
					print(str(count-1) + " " + txt)
					with open(destination, 'a') as output:
						output.write(str(count-1) + " " + str(txt)+"\n")

				frames = []
				if pts != None:
					frames.append(pts)
				frames.append(picttype)
			else:
				frames.append(picttype)