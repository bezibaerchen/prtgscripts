## Please check GitHub repository for updates to that script: https://github.com/bezibaerchen/prtgscripts


########################### Add Exchange Shell##############################

$exchangeuri = "http://<fqdn_of_Exchange_Server_with_RemotePowerShell>/PowerShell"

$session = new-pssession `
		-ConfigurationName "Microsoft.Exchange" `
		-ConnectionUri $exchangeuri `
		-Authentication Kerberos
		
import-pssession -Session $session -AllowClobber | out-null		


##########################Define Variables & Strings########################
[String] $errMessage = $null
[Bool] $bolFailover = $False
$countwrong = 0

#########################Get The Databases##################################
$dbcopystatus = Get-MailboxDatabaseCopyStatus * | Sort-Object Name

 ForEach ($dbcopy in $dbcopystatus) 
    {
        
       
        $db = $dbcopy.name
        $status = $dbcopy.status
        $server = $dbcopy.MailBoxServer
        $actpref = $dbcopy.ActivationPreference
      
        # Compare the server where the DB is currently active to the server where it should be
        If ($status -eq "Mounted" -and $actpref -ne "1")
                    {
              $errMessage += "`n$($dbcopy.Name) has a mounted copy on $($dbcopy.MailboxServer) with Activation Preference $actpref"
			  $countwrong = $countwrong + 1

		 $bolFailover = $True           
	}
}
$errMessage += "`n`n"
if ($bolFailover) {
	
	
	#$errMessage 
    ##Write-Host "1"
	##Write-Host "$errMessage" 
	$prefcheckstatus = "$errMessage"
    ##exit 2
}

Else
{
    $prefcheckstatus = "All good. No misplaced DB(s) found..."
	##Write-Host "0"
	##Write-Host "All Good. No misplaced DB(s) found..."
    ##exit 0
}


"<prtg>
<result>
<channel>misplacedDBs</channel>
<value>$countwrong</value>
<showChart>1</showChart>
<showTable>1</showTable>
<unit>Count</unit>
<customunit>Misplaced DBs</customunit>
<mode>absolute</mode>
</result>
<text>$prefcheckstatus</text>
</prtg>"

remove-pssession -session $session

