<#
.SYNOPSIS
    Generates a couple simple, precanned reports about recent Incidents.
.DESCRIPTION
    The data returned by Get-SfxIncidents is pretty verbose.
    This cmdlet summarizes that information into some simple reports.
.EXAMPLE
    PS C:\> Get-SfxIncidentReport -ByDetector

    Returns a count of the incidents from the last 7 days grouped by Detector Name.
.EXAMPLE
    PS C:\> Get-SfxIncidentReport 30 -ByDetector

    Returns a count of the incidents from the last 30 days grouped by Detector Name.
.EXAMPLE
    PS C:\> Get-SfxIncidentReport -SignalLossByHost

    Returns a count of the Hosts that have triggered a Loss of Signal alert in the last 7 days.
    This assumes you have a detector named 'host.loss_of_signal'
.INPUTS
    Int
.OUTPUTS
    GroupInfoNoElement
.NOTES
    Experimental. These reports may not work for you.
#>
function Get-SfxIncidentReport {
    [CmdletBinding(DefaultParameterSetName='byDetector')]
    param (
        [Parameter(Position = 0)]
        [int]
        $Days = 7,

        [Parameter(ParameterSetName='byDetector')]
        [switch]
        $ByDetector,

        [Parameter(ParameterSetName='SignalLossByHost')]
        [switch]
        $SignalLossByGost
    )

    $incidents = GetRecentIncidents -days $Days

    switch ($PsCmdlet.ParameterSetName) {
        "byDetector" {
            $incidents | Group-Object DetectorName -NoElement | Sort-Object -Property Count -Descending
        }
        "SignalLossByHost" {
            $incidents | Where-Object DetectorName -eq 'host.loss_of_signal' | ForEach-Object {
                $inputs = $_.Inputs | ConvertFrom-Json
                $hostvalue = $inputs._S7.key.host
                $_ | Add-Member -MemberType NoteProperty -Name 'Host' -Value $hostvalue -PassThru
            } | Group-Object -Property Host -NoElement
        }
    }
}

function GetRecentIncidents {
    param (
        [int]$days
    )

    $batchSize = 100
    $count = 0
    $cutoff = (Get-Date).AddDays($days * -1).ToUniversalTime()
    $oldest = (Get-Date).ToUniversalTime()
    $incidents = @()

    while ($oldest -gt $cutoff) {
        Write-Verbose "Querying SFx Limit [$batchSize] Offset [$count]"
        $batch = Get-SFxIncident -Limit $batchSize -Offset $count -IncludeResolved

        $data = foreach ($incident in $batch) {

            $firstEvent = $incident.events | Sort-Object timestamp -desc | Select-Object -first 1

            $duration = if ($incident.duration) { [Timespan]$incident.duration } else { $null }

            [PSCustomObject]@{
                Active                    = [bool]$incident.active
                AnomalyState              = $incident.anomalyState
                DetectLabel               = $incident.detectLabel
                DetectorId                = $incident.detectorId
                DetectorName              = $incident.detectorName
                TimestampUtc              = [DateTimeOffset]::FromUnixTimeMilliseconds($firstEvent.timestamp).UtcDateTime
                Duration                  = $duration
                IncidentId                = $incident.incidentId
                IsMuted                   = [bool]$incident.isMuted
                Severity                  = $incident.severity
                TriggeredNotificationSent = [bool]$incident.triggeredNotificationSent
                TriggeredWhileMuted       = [bool]$incident.triggeredWhileMuted
                Inputs                    = $firstEvent.inputs | ConvertTo-Json -Compress
            }
        }

        $incidents += $data
        $oldest = $incidents | Sort-Object -Property TimestampUtc | Select-Object -First 1 -ExpandProperty TimestampUtc
        $count += $batch.count
        if ($count -eq 0) {break}
    }

    $incidents | Where-Object {$_.TimestampUtc -gt $cutoff} | Sort-Object -Property TimestampUtc
}