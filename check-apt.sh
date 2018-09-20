## Please check GitHub repository for updates to that script: https://github.com/bezibaerchen/prtgscripts

## Script to monitor available updates via PRTG


#!/bin/bash

numberofupdates=`apt-get update >/dev/null 2>&1 && apt-get --just-print upgrade 2>&1 | perl -ne 'if (/Inst\s([\w,\-,\d,\.,~,:,\+]+)\s\[([\w,\-,\d,\.,~,:,\+]+)\]\s\(([\w,\-,\d,\.,~,:,\+]+)\)? /i) {print "PROGRAM: $1 INSTALLED: $2 AVAILABLE: $3\n"}' | wc -l`

if [ "$numberofupdates" == "0" ]; then
        listofupdates="None"
else
        listofupdates=`apt-get --just-print upgrade 2>&1 | perl -ne 'if (/Inst\s([\w,\-,\d,\.,~,:,\+]+)\s\[([\w,\-,\d,\.,~,:,\+]+)\]\s\(([\w,\-,\d,\.,~,:,\+]+)\)? /i) {print "$1: $2 -->  $3\n"}'`
fi

echo -e "<prtg>\n<result>\n<channel>Available updates</channel>\n<value>$numberofupdates</value>\n<unit>Count</unit>\n</result>\n<text>$listofupdates</text>\n</prtg>"
