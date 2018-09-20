## Please check GitHub repository for updates to that script: https://github.com/bezibaerchen/prtgscripts

# name of AD group to check
$adgroup="G-ROLE-PowerBI-Professional"

$userscount = (Get-ADGroupMember -Identity $adgroup).count


"<prtg>
<result>
<channel>Number of Users in PowerBI-Professional AD group</channel>
<value>$userscount</value>
<showChart>1</showChart>
<showTable>1</showTable>
<unit>Count</unit>
<customunit>Usercount</customunit>
<mode>absolute</mode>
</result>
</prtg>"