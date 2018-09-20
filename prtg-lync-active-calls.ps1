## Please check GitHub repository for updates to that script: https://github.com/bezibaerchen/prtgscripts

$ComputerName="<fqdn of mediation server>"

$ResultInbound = (Get-Counter -Counter "\LS:MediationServer - inbound calls(_total)\- current" -ComputerName $ComputerName  -ErrorAction silentlycontinue).CounterSamples[0].CookedValue
$ResultOutbound = (Get-Counter -Counter "\LS:MediationServer - outbound calls(_total)\- current" -ComputerName $ComputerName -ErrorAction silentlycontinue).CounterSamples[0].CookedValue


"<prtg>"
       "<result>"
       "<channel>Inbound calls</channel>"
       "<value>$ResultInbound</value>"
       "</result>"
       "<result>"
       "<channel>Outbound calls</channel>"
       "<value>$Resultoutbound</value>"
       "</result>"
       $TotalCalls = ($ResultInbound+$ResultOutbound)
       "<result>"
       "<channel>Total calls</channel>"
       "<value>$TotalCalls</value>"
       "</result>"
       "<text>$TotalCalls active calls</text>"
"</prtg>"

