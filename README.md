**VSPP Stuff**

Scripts and tools related to VSPP.

*It's usually crap but if it works, it works :-)*

---

## Contents

This is the stuff that's in this repo.

1. segment_analyser.sh - A small script to pick out all the segments from a manifest file.

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


---