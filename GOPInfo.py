#! /usr/bin/python3
import subprocess
import argparse
import shutil
import json
import time

# Use argparses to generate useful help messages
parser = argparse.ArgumentParser()
parser.add_argument("file", help="Use \"GOPInfo <file>\" to extract GOP information.")
args = parser.parse_args()

# Create filenames for writing
json_file=args.file.split(".")[0] + ".json"
text_file=args.file.split(".")[0] + ".txt"

# main function that calls the rest
def main():
	probe_result = call_ffprobe(args.file)
	extract_frames(probe_result)

# funtion to mange ffprobe
def call_ffprobe(file):
	ffprobe = is_program_installed("ffprobe")
	if ffprobe == None:
		sys.exit("ffprobe not found!")
	else:
		print("Running ffprobe on file.")
		probe = run_ffprobe(ffprobe, file)
		return(probe)

# function to check if ffprobe is installed or not
def is_program_installed(ffprobe):
	return shutil.which(ffprobe)

# function to run ffprobe and generate a file to work with
# I'm not sure if we really need to write the file out (will size play an issue?)
# but I'm doing it anyway so I have a reference for later.
def run_ffprobe(ffprobe, file):
#	print(ffprobe)
#	print(file)
#	print(json_file)
	with open(json_file, "w") as jf:
		result = subprocess.Popen([ffprobe, "-select_streams", "v", "-show_frames", "-show_entries", 
			"frame=pts,pkt_duration,pkt_pos,pict_type,pkt_size,pkt_dts_time", "-v", "quiet", "-print_format", 
			"json", file], universal_newlines=True, stdout=subprocess.PIPE).communicate()[0]
		jf.write(str(result))
	return(result)

def convert_time(pkt_dts_time):
	return(time.strftime("%H:%M:%S", time.gmtime(float(pkt_dts_time))))
#	return(sec)

def extract_frames(probe_result):
	print("Extracting GOP structure of file.")
	filedata = json.loads(probe_result)
	# Empty frames array
	frames = []
	for properties in filedata['frames']:
#		print(properties)
		for key, value in properties.items():

			# Find the pts values for each frame
			if key == "pts":
				pts = value

			if key == "pkt_dts_time":
				pkt_dts_time = " " + convert_time(value)

			# Find the type of each frame
			if key == "pict_type":
				pict_type = value.strip()

				# If the frame is an I-Frame then we need to do something
				if pict_type == "I":
					pict_type = " I"

					# Zero out both the GOP and the count values
					gop_line = ""
					count = 0

					# Add the frame to the GOP and increment the line count by one
					for frame in frames:
						gop_line += str(frame)
						count += 1

					if len(gop_line) > 1:
						gop_result = str(count-1) + " " + gop_line
						print(gop_result)
						with open(text_file, 'a') as output:
							output.write(gop_result+"\n")
					
					# Need to zero out the array each time so I-Frames start on new lines
					# Zero the array, add the pts and the I-Frame
					frames = []
					frames.append(pts)
					frames.append(pkt_dts_time)
					frames.append(pict_type)
				else:
					# If the frame is not an I-Frame then tag it onto the end
					frames.append(pict_type)

main()
