## Please check GitHub repository for updates to that script: https://github.com/bezibaerchen/prtgscripts

## Script to determine groupfolder usage vs. Quota and to output in a PRTG compatible format


#!/bin/bash
## Threshold is used as an argument to be set in PRTG
threshold=$1

## Get all groupfolders and neccessary information. Alter path to OCC if needed
allfolders=`sudo -u www-data php /var/www/nextcloud/occ groupfolders:list | awk -F '|' '/|\s[0-9]+\s+|/ {gsub(/ /, "", $3); gsub(/ /, "", $5); gsub(/ /, "", $6);;print $3"|"$5"|"$6}' | grep -v "||" | grep -v Name`

## Reset all used variables
usageissue="0"
foldernameswithissues=""
foldernameswithoutissues=""
folderschecked="0"

## Loop through folders and check if they are approaching the quota
for folder in $allfolders; do

		## Get name, set quota and size of folders
        name=$(echo $folder | cut -d '|' -f1)
        quota=$(echo $folder | cut -d '|' -f2)
        size=$(echo $folder | cut -d '|' -f3)
        sizeingb=$(echo $size | grep GB)
		## Raise counter of checked folders
        folderschecked=$((folderschecked+1))
		
		## We assign at least 5 GB of quota so we ignore all folders where size unit doesn't contain the unit GB
        if [ -z "$sizeingb" ]
        then
                :
        else
                ## get size and quotas without units to be able to calculate
				sizewithoutunit=$(echo $sizeingb | sed s/"GB"//)
                quotawithoutunit=$(echo $quota | sed s/"GB"//)
				## Calculate free space, usage and usage in percent. Division by "1" is needed as bc only reflects scale parameter in case of divisions
                spacefree=$(echo "scale=2;$quotawithoutunit - $sizewithoutunit /1" | bc)
                usage=$(echo "scale=2; $sizewithoutunit / $quotawithoutunit" | bc)
                usagepercent=$(echo "scale=0;$usage * 100/1" | bc)
				
				## Determin if usage in percent is above threshold
                if [ $usagepercent -gt $threshold ]
                        then
                                echo "$usagepercent is greater than $threshold for $name. Space free: $spacefree GB"
                                foldernameswithissues="$foldernameswithissues $name (Usage: $usagepercent% Space free: $spacefree GB)\n"
                                usageissue=$((usageissue+1))
                        else
                                foldernameswithoutissues="$foldernameswithoutissues $name (Usage: $usagepercent% Space free: $spacefree GB)\n"
                fi
        fi
done


## Set folders with issues to "None" if no folder is above threshold
if [ -z "$foldernamewithissues" ]
then
        foldernameswithissues="None\n"
else
        :
fi

## Echo PRTG compatible output
echo -e "<prtg>\n<result>\n<channel>Number of checked folders</channel>\n<value>$folderschecked</value>\n<unit>Count</unit>\n</result>\n<result>\n<channel>Number of Groupfolders approaching Quota</channel>\n<value>$usageissue</value>\n<unit>Count</unit>\n</result>\n<text>\nERROR:\n$foldernameswithissues\nOK:\n$foldernameswithoutissues</text>\n</prtg>"
