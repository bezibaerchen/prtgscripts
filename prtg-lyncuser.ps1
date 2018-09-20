# prtg-lyncuser.ps1
#
# Loading current sip client connections as performance counter
#

## Please check GitHub repository for updates to that script: https://github.com/bezibaerchen/prtgscripts

param (
	[string]$server= "<server001>,<server002>,<server003>"  # specify Servers
)

$total=0
write-host "Start PRTG Sensor" 
write-host "Server:" $Server 

$serverlist = $server.split(",")
write-host "Serverlist count:" $Serverlist.count 

$result="<prtg>`r`n"


foreach ($server in $serverlist){
	write-host "Server: " $server
	$value = (Get-Counter "\LS:SIP - Peers(Clients)\SIP - Connections Active" -ComputerName $server -ErrorAction silentlycontinue)
	if ($error) {
		# Skip Counters
		write-host "Server: $server unable to read $counter"
		$error.clear()
	}
	else  {
		$result+="  <result>`r`n"
		$result+="    <channel>SIPClients("+$server+")</channel>`r`n"
		$result+="    <value>"+$value.CounterSamples[0].CookedValue+"</value>`r`n"
		$result+="    <unit>Count</unit>`r`n"
		$result+="    <mode>Absolute</mode>`r`n"
		$result+="  </result>`r`n"
		$total=$total+$value.CounterSamples[0].CookedValue
			}
}

$result+="<text>Total Sessions:"+$total+ "</text>`r`n"
$result+="  <result>`r`n"
$result+="    <channel>Total Sessions</channel>`r`n"
$result+="    <value>"+$total+"</value>`r`n"
$result+="    <unit>Count</unit>`r`n"
$result+="    <mode>Absolute</mode>`r`n"
$result+="  </result>`r`n"
$result+="</prtg>"

write-host "End: ExitCode "$error.count

Write-host "Sending Result to output pipeline"
$result

if ($error) {
	#write-host "Found Errors"
	EXIT 1
}