## Please check GitHub repository for updates to that script: https://github.com/bezibaerchen/prtgscripts

# define Parameter to pass groupname via PRTG.
# add a parameter in the respective sensor e.g. "-groupname mygrouptobecounted"
param (
	[string]$groupname= ""  # specify group to be checked
)


# Get ActiveDirectory group count. Note that this Commandlet doesn't have issues with the standard 5.000 users limit
$userscount=(Get-ADGroup $groupname -Properties Member | Select-Object -ExpandProperty Member).count

# Output result in PRTG readable XML

"<prtg>
<result>
<channel>Number of Users in $group</channel>
<value>$userscount</value>
<showChart>1</showChart>
<showTable>1</showTable>
<unit>Count</unit>
<customunit>Usercount</customunit>
<mode>absolute</mode>
</result>
</prtg>"