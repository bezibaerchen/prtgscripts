## 2018-09-20_BEZ Script to check Job Status in Mailstore

## Please check GitHub repository for updates to that script: https://github.com/bezibaerchen/prtgscripts

# Define credentials for mailstore server
$user="<user>"
$pass="<pass>"

# Define mailstore server
$msserver="<servername_fqdn>"

# Import Mailstore Powershell Module
Import-Module 'C:\scripts\PRTG\mailstore\MS.PS.Lib.psd1'

# Open new API connection to mailstore serverSideExecution
$msapiclient = New-MSApiClient -Username $user -Password $pass -MailStoreServer $msserver -Port 8463 -IgnoreInvalidSSLCerts

# Get current date in format 2018-09-20T08:45:43
$date=(get-date -format s)

# Get current date minus 24h hours
$date_24h_ago=(get-date (get-date).AddDays(-1) -format s)

# set counters to 0
$errorcount=0
$successfulcount=0
$completedWithErrors=0
$cancelled=0

# get configured profiles from Mailstore serverSideExecution
$return=Invoke-MSApiCall $msapiclient "GetProfiles" @{raw = "true"} 

# Loop through profiles set to automatic execution
foreach($id in ($return.result| where {$_.serverSideExecution.automatic -eq $true}).id)
{
    # loop through jobs set to automatic with result succeeded
	$result=Invoke-MSApiCall $msapiclient "GetWorkerResults" @{fromIncluding = $date_24h_ago; toExcluding = $date; timeZoneID = "W. Europe Standard Time"; profileID=$id} | where {$_.result.result -eq "succeeded"}
    
	# raise counter for successful jobs
    if($result) {
        $successfulcount=$successfulcount+1
    }
    
}

foreach($id in ($return.result| where {$_.serverSideExecution.automatic -eq $true}).id)
{
    # loop through jobs set to automatic with result succeeded
	$result=Invoke-MSApiCall $msapiclient "GetWorkerResults" @{fromIncluding = $date_24h_ago; toExcluding = $date; timeZoneID = "W. Europe Standard Time"; profileID=$id} | where {$_.result.result -eq "completedWithErrors"}
    
	# raise counter for successful jobs
    if($result) {
        $completedWithErrors=$completedWithErrors+1
    }
    
}

foreach($id in ($return.result| where {$_.serverSideExecution.automatic -eq $true}).id)
{
    # loop through jobs set to automatic with result succeeded
	$result=Invoke-MSApiCall $msapiclient "GetWorkerResults" @{fromIncluding = $date_24h_ago; toExcluding = $date; timeZoneID = "W. Europe Standard Time"; profileID=$id} | where {$_.result.result -eq "cancelled"}
    
	# raise counter for successful jobs
    if($result) {
        $cancelled=$cancelled+1
    }
    
}


# Loop through profiles set to automatic execution
foreach($id in ($return.result| where {$_.serverSideExecution.automatic -eq $true}).id)
{
    # loop through jobs set to automatic with StatusCode not being succeeded
    $result=Invoke-MSApiCall $msapiclient "GetWorkerResults" @{fromIncluding = $date_24h_ago; toExcluding = $date; timeZoneID = "W. Europe Standard Time"; profileID=$id} | where {$_.result.result -eq "failed"}
	
	# raise counter for non-successful jobs
    if($result) {
        $errorcount=$errorcount+1
    }
}


# Output result in PRTG readable XML

"<prtg>
<result>
<channel>Successful jobs</channel>
<value>$successfulcount</value>
<showChart>1</showChart>
<showTable>1</showTable>
<unit>Count</unit>
<mode>absolute</mode>
</result>
<result>
<channel>Jobs completed with errors</channel>
<value>$completedWithErrors</value>
<showChart>1</showChart>
<showTable>1</showTable>
<unit>Count</unit>
<mode>absolute</mode>
</result>
<result>
<channel>Jobs cancelled</channel>
<value>$cancelled</value>
<showChart>1</showChart>
<showTable>1</showTable>
<unit>Count</unit>
<mode>absolute</mode>
</result>
<result>
<channel>Jobs Failed</channel>
<value>$errorcount</value>
<showChart>1</showChart>
<showTable>1</showTable>
<unit>Count</unit>
<mode>absolute</mode>
</result>
<text>Successful jobs: $successfulcount  Jobs completed with errors: $completedWithErrors Jobs cancelled: $cancelled Jobs with errors: $errorcount</text>
</prtg>"