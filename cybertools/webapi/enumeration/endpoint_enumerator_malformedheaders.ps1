#This script assumes you have a text file with a list of endpoints in a directory named "scripts" in the same folder as this script.


$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptRoot


$apiEndpointsFile = ".\scripts\api_endpoints.txt"
$resultsCsvFile = ".\scripts\results.csv"
$errorsLogFile = ".\scripts\errors.txt"
$rawDataFile = ".\scripts\raw.txt"

#set target here
$apiBaseUrl = "http://"

# Define custom header including username and additional manipulations
$customHeaders = @{
    "User-Agent" = "Googlebot/2.1 (+http://www.google.com/bot.html)";
    "Referer" = "http://www.google.com/";
    "X-Forwarded-For" = "127.0.0.1";
    "Host" = "api.example.com";
    "Content-Type" = "application/json";
}

# Limit requests
#$requestLimit = 5
#$delayBetweenRequests = 1 / $requestLimit

# Verbose switch
$verbose = $false

function Send-Request {
    param (
        [string]$baseUrl,
        [string]$endpoint,
        [hashtable]$headers
    )

    try {
        $url = "$baseUrl/$endpoint"
        
        if ($verbose) {
            Write-Host "Request URL: $url"
            Write-Host "Request Headers:"
            $headers.GetEnumerator() | ForEach-Object { Write-Host "$($_.Key): $($_.Value)" }
        }

        $response = Invoke-WebRequest -Uri $url -Headers $headers -Method Get -ErrorAction Stop

        if ($verbose) {
            Write-Host "Response Headers:"
            $response.Headers.GetEnumerator() | ForEach-Object { Write-Host "$($_.Key): $($_.Value)" }
            Write-Host "Response Body: $($response.Content)"
        }

        return $response
    } catch {
        $errorMessage = "Failed to request ${endpoint}: $_"
        Write-ErrorLog $errorMessage
        if ($verbose) {
            Write-Host $errorMessage
        }
        return $null
    }
}


function Write-ErrorLog {
    param (
        [string]$message
    )

    Add-Content -Path $errorsLogFile -Value $message
}

function Write-RawData {
    param (
        [string]$endpoint,
        [string]$response
    )

    Add-Content -Path $rawDataFile -Value "Endpoint: $endpoint`n$response`n"
}

# Function to update ETA in the console
function Update-ETA {
    param (
        [int]$processed,
        [int]$total,
        [datetime]$startTime,
        [timespan]$totalEstimatedTime
    )

    $elapsedTime = (Get-Date) - $startTime
    $remainingTime = $totalEstimatedTime - $elapsedTime

    Write-Host ("Processed: {0}/{1} - Elapsed: {2:hh\:mm\:ss} - ETA: {3:hh\:mm\:ss}" -f $processed, $total, $elapsedTime, $remainingTime) -NoNewline
}

# Store endpoints in text file, read here
$apiEndpoints = Get-Content -Path $apiEndpointsFile
$totalEndpoints = $apiEndpoints.Length

$totalEstimatedTime = [timespan]::FromSeconds($totalEndpoints * $delayBetweenRequests)


$results = @()


$startTime = Get-Date
$processedEndpoints = 0

if (-not $verbose) {
    Clear-Host
    Update-ETA -processed $processedEndpoints -total $totalEndpoints -startTime $startTime -totalEstimatedTime $totalEstimatedTime
}

# bang on door
foreach ($endpoint in $apiEndpoints) {
    $response = Send-Request -baseUrl $apiBaseUrl -endpoint $endpoint -headers $customHeaders
    if ($null -ne $response) {
        Write-RawData -endpoint $endpoint -response ($response.Content)
        if ($response -is [PSObject] -or $response -is [String]) {
            $results += [PSCustomObject]@{
                Endpoint = $endpoint
                Response = $response.Content | ConvertTo-Json -Compress
            }
        }
    }
    $processedEndpoints++

    if ($verbose) {
        Write-Host "Processed: $endpoint"
    } else {
        Clear-Host
        Update-ETA -processed $processedEndpoints -total $totalEndpoints -startTime $startTime -totalEstimatedTime $totalEstimatedTime
    }

    Start-Sleep -Seconds $delayBetweenRequests
}


$results | Export-Csv -Path $resultsCsvFile -NoTypeInformation

if ($verbose) {
    Write-Host "Script completed. Results written to $resultsCsvFile. Errors logged to $errorsLogFile."
} else {
    Clear-Host
    Write-Host "Script completed. Results written to $resultsCsvFile. Errors logged to $errorsLogFile."
}
