$traceRouteResult = Test-NetConnection -TraceRoute 8.8.8.8
$gateways = $traceRouteResult.TraceRoute

# Display the gateways
#$pingresult = Test-Connection 8.8.8.8

foreach ($gateway in $gateways) {
    $job = Start-Job -ScriptBlock {
        $gateway = $using:gateway
        Test-Connection -Count 1 $gateway | Format-Table Address, ResponseTime, @{Name = 'TimeStamp'; Expression = { Get-Date } }
    }
}

# Wait for the job to finish
Wait-Job $job

# Get the job's output and save it as CSV
$jobOutput = Receive-Job $job
$jobOutput | Export-Csv -Path "E:\Téléchargement\PingResults_.csv" -NoTypeInformation

# Cleanup: Remove completed jobs
Remove-Job $job

#$time = $pingresult | Select-Object -ExpandProperty ResponseTime
#Write-Output $time


#Count gateways
$count = $gateways | Measure-Object | Select-Object -ExpandProperty Count
Write-Host "Number of gateways: $count"


# Make a table with the gateways and the time 
<#
# Define the number of columns
$numberOfColumns = $count + 1 # For each gateway and the timestamp

# Define the array with column headers
$headers = @(1..$numberOfColumns | ForEach-Object { "Column $_" })

# Create a sample array with data
$data = @(1..20 | ForEach-Object { [PSCustomObject]@{ "Column 1" = $_; "Column 2" = $_ * 2; "Column 3" = $_ * 3; "Column 4" = $_ * 4 } })

# Format the table with the desired number of columns
$data | Format-Table -Property $headers -AutoSize
#>
