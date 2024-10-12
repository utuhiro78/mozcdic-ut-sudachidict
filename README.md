## Overview

A dictionary converted from [SudachiDict](https://github.com/WorksApplications/SudachiDict) for Mozc.

Thanks to the SudachiDict team.

## License

mozcdic-ut-sudachidict.txt: [Apache License, Version 2.0](https://github.com/WorksApplications/SudachiDict/blob/develop/LEGAL)

Source code: Apache License, Version 2.0

## Usage

Add the dictionary to dictionary00.txt and build Mozc as usual.

```
tar xf mozcdic-ut-*.txt.tar.bz2
cat mozcdic-ut-*.txt >> ../mozc-master/src/data/dictionary_oss/dictionary00.txt
```

To modify the costs for words or merge multiple UT dictionaries into one, use this tool:

[merge-ut-dictionaries](https://github.com/utuhiro78/merge-ut-dictionaries)

## Update this dictionary with the latest stuff

Requirement(s): python-jaconv

```
cd src/
sh make.sh
```

[HOME](http://linuxplayers.g1.xrea.com/mozc-ut.html)
