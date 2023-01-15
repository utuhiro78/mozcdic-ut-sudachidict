#!/bin/bash

# Author: UTUMI Hirosi (utuhiro78 at yahoo dot co dot jp)
# License: APACHE LICENSE, VERSION 2.0

ruby convert_sudachidict_to_mozcdic.rb
ruby adjust_entries.rb mozcdic-ut-sudachidict.txt
ruby filter_unsuitable_words.rb mozcdic-ut-sudachidict.txt

tar cjf mozcdic-ut-sudachidict.txt.tar.bz2 mozcdic-ut-sudachidict.txt
mv mozcdic-ut-sudachidict.txt* ../

rm -rf mozcdic-ut-sudachidict-release/
rsync -a ../* mozcdic-ut-sudachidict-release --exclude=jawiki-* --exclude=*core_lex.* --exclude=sudachidict-*.txt --exclude=mozcdic-ut-*.txt
