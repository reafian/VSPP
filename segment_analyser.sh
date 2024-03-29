#! /bin/bash

# segment analyser 
# a crappy script to show segment points in a manifest file

# v1 - 2021-07-23 - Richard Newton
# v2 - 2021-07-28 - Richard Newton

# Default Variables
host=localhost
port=5555
file=manifest.xml
output_file=extract.txt
manifest="http://${host}:${port}/sdash/${external_id}/index.mpd/Manifest?device=DASH"
segment_count=1
segment_total=0
temp="/tmp/manifest.tmp"

given_file=0
given_output_file=0
given_external_id=0
given_host_address=0
given_host_port=0

adaptation_flag=0
video_timings_source=10000000 #(20000000 = 2s)
# Not sure about these audio timings, they don't seem to make a whole lot of sense
# and I'm half-wondering if they need to be calculated on-the-fly. If they do that'll get messy.
#old_audio_timings_source=24000 #(20000000 = 2s)
#new_audio_timings_source=47996 #(20000000 = 2s)
#audio_timings_source=96768 #(20000000 = 2s)




# Usage
function usage {
	echo "Usage: $0 [ -f MANIFEST_FILE ] | [ -i EXTERNAL_ID ] [ -a HOST_ADDRESS ] [ -p PORT ] [ -o OUTPUT_FILE" ] 1>&2 
}

#Quick check to see if input file exists
function check_file_exists {
	if [[ -f $1 ]]
	then
		echo 0
	else
		echo 1
	fi
}

# Quick check to see if input file is XML
function check_file_is_xml {
	if [[ $(file $1) =~ XML ]]
	then
		echo 0
	else
		echo 1
	fi
}

# Check input file to see if it exists and is XML
function check_file {
	does_file_exist=$(check_file_exists $1)
	is_file_xml=$(check_file_is_xml $1)

	# Exist check
	if [[ does_file_exist == 1 ]]
	then
		echo $1 does not exist
		exit 1
	fi

	# XML check
	if [[ $is_file_xml == 1 ]]
	then
		echo $1 is not a valid XML file
		exit 1
	fi
}

# Check to see if output file exists and can be overwritten
function check_output_file {
	does_file_exist=$(check_file_exists $1)

	# This is the opposite of the input file, now 0 means the file
	# exists and if it exists we need to check it can be overwritten
	if [[ $does_file_exist == 0 ]]
	then
		read -p "File exists. Overwrite? (y/n) " answer
		while true
		do
			case $answer in
				[yY]* ) echo "Overwriting $1"
						break
						;;

				[nN]* ) echo "Not overwriting ${1}, exiting."
						exit 1
						;;

				* ) echo "Please use y or n."
			esac
		done
	fi
}

# Extract data from XML. Should probably try to make this more functional
function new_extract_segment_information {
	audio_timings_source=$3

	echo "Creating segment extract file"
	if [[ $2 ]]
	then
		output=$2
	else
		output=$output_file
	fi

	while read line
	do
  		if [[ $line =~ "<SegmentTemplate " ]]
  		then
  			if [[ adaptation_counter == 0 ]]
  			then
    			echo Adaptation Set = $(echo $line | rev | cut -d\( -f1 | rev | cut -d= -f1)
    			adaptation_flag=1
    		else
    			echo
    			echo Adaptation Set = $(echo $line | rev | cut -d\( -f1 | rev | cut -d= -f1)
    			adaptation_flag=1
    		fi
    		segment_total=0
    		segment_count=1
    		if [[ $line =~ "video" ]]
    		then
    			content_type="video"
    		elif [[ $line =~ "trickmode" ]]
    		then
    			content_type="trickmode"
    		elif [[ $line =~ "audio" ]]
    		then
    			content_type="audio"
    		fi
 		fi
  		if [[ $line =~ "<S " ]]
  		then
#  			echo ""
#  			echo "*** $(echo $line | sed -e"s/<S/Segments/" | sed -e"s/\/>//") ***"
#  			echo ""

  			if [[ $line =~ "r=" ]]
    		then
    			segment=$(echo $line | cut -d\" -f4)
      			repetitions=$(echo $line | cut -d\" -f6)
#  				echo line contains r= $segment $repetitions $content_type

  				for i in $( seq 1 $(($repetitions+1)) )
      			do
      				segment_total=$(($segment+$segment_total))
      				if [[ $content_type != "audio" ]]
      				then
        				run_time=$(( $segment_total/$video_timings_source ))
        				length=$(printf '%02dh:%02dm:%02ds\n' $(($run_time/3600)) $(($run_time%3600/60)) $(($run_time%60)))
        			else
        				run_time=$(( $segment_total/$audio_timings_source ))
        				length=$(printf '%02dh:%02dm:%02ds\n' $(($run_time/3600)) $(($run_time%3600/60)) $(($run_time%60)))
        			fi
        			echo "	Segment_${segment_count} = $segment_total $segment $run_time $length $content_type"
        			segment_count=$(($segment_count+1))
      			done

  			else
  				segment=$(echo $line | cut -d\" -f4)
    			segment_total=$(($segment+$segment_total))
#  				echo no r= $segment $segment_total $content_type
    			if [[ $content_type != "audio" ]]
    			then
    				run_time=$(( $segment_total/$video_timings_source ))
        			length=$(printf '%02dh:%02dm:%02ds\n' $(($run_time/3600)) $(($run_time%3600/60)) $(($run_time%60)))
        		else
        			run_time=$(( $segment_total/$audio_timings_source ))
        			length=$(printf '%02dh:%02dm:%02ds\n' $(($run_time/3600)) $(($run_time%3600/60)) $(($run_time%60)))
        		fi
    			echo "	Segment_${segment_count} = $segment_total $segment $run_time $length $content_type"
    			segment_count=$(($segment_count+1))

  			fi

  		fi
#	done < <(cat $1)
	done < <(cat $1) >$output
}

# Extract data from XML. Should probably try to make this more functional
function old_extract_segment_information {
	audio_timings_source=$3

	echo "Creating segment extract file"
	if [[ $2 ]]
	then
		output=$2
	else
		output=$output_file
	fi

	while read line
	do
  		if [[ $line =~ "<SegmentTemplate " ]]
  		then
  			if [[ adaptation_counter == 0 ]]
  			then
    			echo Adaptation Set = $(echo $line | rev | cut -d\( -f1 | rev | cut -d= -f1)
    			adaptation_flag=1
    		else
    			echo
    			echo Adaptation Set = $(echo $line | rev | cut -d\( -f1 | rev | cut -d= -f1)
    			adaptation_flag=1
    		fi
    		segment_total=0
    		segment_count=1
    		if [[ $line =~ "video" ]]
    		then
    			content_type="video"
    		elif [[ $line =~ "trickmode" ]]
    		then
    			content_type="trickmode"
    		elif [[ $line =~ "audio" ]]
    		then
    			content_type="audio"
    		fi
 		fi
  		if [[ $line =~ "<S d=" ]]
  		then
#  			echo ""
#  			echo "*** $(echo $line | sed -e"s/<S/Segments/" | sed -e"s/>//") ***"
#  			echo ""
  			if [[ $line =~ "r=" ]]
    		then
  				segment=$(echo $line | cut -d\" -f2)
      			repetitions=$(echo $line | cut -d\" -f4)
#      			echo Manifest Line = Segment = $segment, Repetitions = $repetitions Segment Total = $segment_total
      			for i in $( seq 1 $(($repetitions+1)) )
      			do
      				segment_total=$(($segment+$segment_total))
      				if [[ $content_type != "audio" ]]
      				then
        				run_time=$(( $segment_total/$video_timings_source ))
        				length=$(printf '%02dh:%02dm:%02ds\n' $((run_time/3600)) $((run_time%3600/60)) $((run_time%60)))
        			else
        				run_time=$(( $segment_total/$audio_timings_source ))
        				length=$(printf '%02dh:%02dm:%02ds\n' $((run_time/3600)) $((run_time%3600/60)) $((run_time%60)))
        			fi
        			echo "	Segment_${segment_count} = $segment_total $segment $run_time $length $content_type"
        			segment_count=$(($segment_count+1))
      			done
  			else
  				segment=$(echo $line | cut -d\" -f2)
    			segment_total=$(($segment+$segment_total))
    			if [[ $content_type != "audio" ]]
    			then
    				run_time=$(( $segment_total/$video_timings_source ))
        			length=$(printf '%02dh:%02dm:%02ds\n' $((run_time/3600)) $((run_time%3600/60)) $((run_time%60)))
        		else
        			run_time=$(( $segment_total/$audio_timings_source ))
        			length=$(printf '%02dh:%02dm:%02ds\n' $((run_time/3600)) $((run_time%3600/60)) $((run_time%60)))
        		fi
    			echo "	Segment_${segment_count} = $segment_total $segment $run_time $length $content_type"
    			segment_count=$(($segment_count+1))
  			fi
  		fi
#	done < <(cat $1)
	done < <(cat $1) >$output
}

# Call the extract function with input and output file names
function process_local_file {
	echo "Processing $file, using an output file of $output_file"
	echo "Extracting audio timescale"
	timescale=$(grep SegmentTemplate $file | grep audio | sed -e"s/timescale=\"/@/" | cut -d@ -f2 | cut -d\" -f1)
	echo "Using an audio timescale of $timescale"
	grep -q " t=\"" $file 2>&1 >/dev/null
	if [[ $? == 0 ]]
	then
		echo "Using new_extract_segment_information"
		new_extract_segment_information $file $output_file $timescale
	else
		echo "Using old_extract_segment_information"
		old_extract_segment_information $file $output_file $timescale
	fi
}

# Download the manifest using given details
function download_manifest {
	echo "Fetching manifest file"
	manifest="http://${host}:${port}/sdash/${external_id}/index.mpd/Manifest?device=DASH"
#	echo curl -s -o ${temp} ${manifest}
	curl -s -o ${temp} ${manifest}
	if [[ $? != 0 ]]
	then
  		echo "cURL failed to retrieve content."
  		echo "Exiting"
  		exit 1
	fi
}

# Build the manifest call
function build_manifest_call {
	# No external ID / Back Office ID is a dealbreaker for downloading
	if [[ $given_external_id != 1 ]]
	then
		echo "No external ID given, no asset can be downloaded with an external ID..."
		exit 1
	else
		echo "Using $external_id as the asset to be fetched"
	fi

	# If we haven't been given a host assume an SSH tunnel through localhost
	if [[ $given_host_address == 1 ]]
	then
		echo "Using $host_address as the host to fetch the manifest from"
		host=$host_address
	else
		echo "Using $host as the host to fetch the manifest from"
	fi

	# If we haven't been given a port assume the standard port of 5555
	if [[ $given_host_port == 1 ]]
	then
		echo "Using $host_port as the port to fetch the manifest from"
		port=$host_port
	else
		echo "Using $port as the port to fetch the manifest from"
	fi
}

# Transform the downloaded XML into something readable
function create_manifest_xml {
	echo "$(date "+%Y-%m-%d %H:%M:%S") - Creating XML file"
	xmllint -format -recover $temp > $file
	rm $temp
}

# Functions to create the download request and process it
function fetch_manifest {
	build_manifest_call
	download_manifest
	create_manifest_xml
	process_local_file $file $output_file
}

# Script starts prompting here
while getopts "f:i:a:p:o:h" options
do              
	case "${options}" in
		f)
			file=${OPTARG}
			check_file $file
			given_file=1
			;;
		i)
			external_id=${OPTARG}
			given_external_id=1
			;;
		a)
			host_address=${OPTARG}
			given_host_address=1
			;;
		p)
			host_port=${OPTARG}
			given_host_port=1
			;;
		o)
			output_file=${OPTARG}
			check_output_file $output_file
			given_output_file=1
			;;
		h)
			usage
			;;
		*)
			usage
			;;
	esac
done

# Handler for various options
if [[ $given_file == 1 ]] && [[ $given_output_file == 1 ]]
then
	# If we have an input and output name, use them
	process_local_file $file $output_file
elif [[ $given_file == 1 ]]
then
	# Just use given input name, I haven't bothered with just an output name
	# because that'd be stupid. Who specifies an output name for a file that's been downloaded
	# manually? Nobody.
	process_local_file $file
elif [[ $given_external_id == 1 ]] || [[ $given_host_address == 1 ]] || [[ $given_host_port == 1 ]]
then
	# If we have any URL details use them but no external ID will cause an abort
	fetch_manifest $external_id $host_address $host_port
fi

# Finally, if no arguments are given assume we're testing and just use the default options
if [ -z "$1" ]
then
	echo "$(date "+%Y-%m-%d %H:%M:%S") - No arguments given, using $file for manifest file and $output_file for output file"
	process_local_file
fi
