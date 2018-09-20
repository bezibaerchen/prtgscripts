## 2018-09-20_BEZ Script to check Job Status in Mailstore
# Check Postfix mailqueue via PRTG

#!/bin/bash

queuelength=`/usr/sbin/postqueue -p | tail -n1 | awk '{print $5}'`
queuecount=`echo $queuelength | grep "[0-9]"`

if [ "$queuecount" == "" ]; then
        amount=0;
else
        amount=$queuelength;
fi

echo -e "<prtg>\n<result>\n<channel>Queue length</channel>\n<value>$amount</value>\n<unit>Count</unit>\n</result>\n</prtg>"
