**VSPP Stuff**

Scripts and tools related to VSPP.

*It's usually crap but if it works, it works :-)*

---

## Contents

This is the stuff that's in this repo.

1. segment_analyser.sh - A small script to pick out all the segments from a manifest file.
2. extract.py - small crappy python to extract frame details from a file.

## segment_analyser.sh

The script can use a file that's already been downloaded from VSPP or it can fetch the manifest itself given the correct details. It returns the adaptation sets and the segments within that set. i.e.

Adaptation Set = video
Segment_1 = 20000000 2 00h:00m:02s video
Segment_2 = 40000000 4 00h:00m:04s video
Segment_3 = 60000000 6 00h:00m:06s video

Adaptation Set = trickmode
Segment_1 = 20000000 2 00h:00m:02s trickmode
Segment_2 = 40000000 4 00h:00m:04s trickmode
Segment_3 = 60000000 6 00h:00m:06s trickmode

Adaptation Set = audio_482_eng
Segment_1 = 48128 2 00h:00m:02s audio
Segment_2 = 96256 4 00h:00m:04s audio
Segment_3 = 144384 6 00h:00m:06s audio

If the file has already been downloaded from VSPP use SublimeText 3 and format the file using IndentXML to make it nice and pretty. The script won't choke then.

## extract.py

Use ffprobe to generate a frame listing of an mpeg or ts file:

ffprobe -select_streams v -show_frames -show_entries frame=pts,pkt_duration,pkt_pos,pict_type,pkt_size -v quiet -print_format json <file>

Use extract.py on the output file to generate something like:

15 8599680 IBBPBBPBBPBBPBB
15 8653680 IBBPBBPBBPBBPBB
15 8707680 IBBPBBPBBPBBPBB
16 8761680 IBBPBBPBBPBBPBBP
17 8819280 IBBPBBPBBPBBPBPBB
15 8880480 IBBPBBPBBPBBPBB
26 8934480 IBBPBBPBBPBBPBBPBBPBBPBBPP

Which shows the GOP length, the pts value for the I-frame and the frame sequence until the next I-frame.

*** NOTE

segment_analyser doesn't work with the new format of manifest file. It's super annoying.

Old Version:

	<SegmentTimeline>
		<S d="20000000" r="561"/>
		<S d="19200000"/>

New Version:

	<SegmentTimeline>
		<S t="0" d="20000000" r="286" />
		<S t="5740000000" d="10000000" r="1" />
---
