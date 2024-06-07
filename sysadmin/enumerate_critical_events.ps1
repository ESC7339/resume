# Define the time range (last 7 days)
$startTime = (Get-Date).AddDays(-7)

# Get critical events from System and Application logs
$events = Get-WinEvent -FilterHashtable @{
    LogName = 'System', 'Application'
    Level = 1 # Critical
    StartTime = $startTime
}

$groupedEvents = $events | Group-Object -Property Message
$result = @()

foreach ($group in $groupedEvents) {
    $count = $group.Count
    $message = $group.Name
    $firstOccurrence = $group.Group | Select-Object -First 1

    $result += [PSCustomObject]@{
        TimeCreated = $firstOccurrence.TimeCreated
        EventID = $firstOccurrence.Id
        Source = $firstOccurrence.ProviderName
        Message = $message
        RepeatCount = $count
    }
}


$uniqueEvents = $result | Where-Object { $_.RepeatCount -eq 1 }
$repeatedEvents = $result | Where-Object { $_.RepeatCount -gt 1 }

Write-Output "Unique Critical Events from the Last Week:"
$uniqueEvents | Format-Table -AutoSize

Write-Output "Repeated Critical Events from the Last Week:"
$repeatedEvents | Format-Table -AutoSize

foreach ($event in $repeatedEvents) {
    Write-Warning "Event ID $($event.EventID) from $($event.Source) repeated $($event.RepeatCount) times. Message: $($event.Message)"
}
