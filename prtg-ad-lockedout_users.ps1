## Please check GitHub repository for updates to that script: https://github.com/bezibaerchen/prtgscripts

# Import ActiveDirectory Powershell Module
Import-Module ActiveDirectory

# search for locked out users in AD
$server=Search-ADAccount -LockedOut -UsersOnly | select SamAccountName
if ($server.count -eq $null -and $server -eq $null){
    $a=0
}
Elseif ($server.count -eq $null -and $server -ne $null){
    $a=1
}
Else
{
    $a=@($server.count)
    
}

# Output in PRTG readable XML
Write-Host "<prtg>"
Write-Host "<result>" 
"<channel>Locked Out Users</channel>" 
    
"<value>"+ $a +"</value>" 
"</result>"
"<text>" + (($server | select SamAccountName | ConvertTo-Csv -NoTypeInformation | select -skip 1 ) -join ", ").replace("""","") + "</text>"
Write-Host "</prtg>"