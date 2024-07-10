#!/bin/bash

# Author: UTUMI Hirosi (utuhiro78 at yahoo dot co dot jp)
# License: Apache License, Version 2.0

rm sudachidict-*.txt
python convert_sudachidict_to_mozcdic.py
python adjust_entries.py mozcdic-ut-sudachidict.txt
python filter_unsuitable_words.py mozcdic-ut-sudachidict.txt

tar cjf mozcdic-ut-sudachidict.txt.tar.bz2 mozcdic-ut-sudachidict.txt
mv mozcdic-ut-sudachidict.txt* ../
