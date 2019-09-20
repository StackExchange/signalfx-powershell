<#
.SYNOPSIS
    Creates a new alert muting rule
.DESCRIPTION
    Creates a new alert muting rule, based on the specifications in the request body. Unlike the
    detector APIs, you can use the alert muting APIs with detectors you create in the web UI as well
    as detectors you create with the API.
.PARAMETER Description
    Description of the rule.
.PARAMETER Filter
    List of alert muting filters for this rule, in the form of a JSON array of alert muting filter
    objects. Each object is a set of conditions for an alert muting rule. Each object property
    (name-value pair) specifies a dimension or custom property to match to alert events.
.PARAMETER Duration
    The duration of the event in the form of [number][scale].
    Scale options:
        m = minute
        h = hour
        d = day

    The default is 1h.
.PARAMETER StartTime
    Starting time of an alert muting rule, in Unix time format UTC. If not specified, defaults to
    the current time.
.PARAMETER ApiToken
    Authentication token
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    String, Hashtable, Int64
.OUTPUTS
    Object
.NOTES
    The SignalFx API will return the string "OK" if the POST is successful.
#>
function New-SFxAlertMuting {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [string]
        $Description,

        [Parameter(Position = 1)]
        [hashtable]
        $Filter,

        [Parameter(Position=2)]
        [ValidatePattern("(\d+)([mhd]{1})")]
        [string]
        $Duration,

        [Parameter(Position=3)]
        [ValidateScript({if ($_ -ge (Get-Date)) {$true} else {Throw "StarTime must not be in the past."}})]
        [datetime]
        $StartTime,

        [Parameter(Position = 4)]
        [string]
        $ApiToken
    )

    process {
        $request = [SFxNewAlertMuting]::new($Description)

        if ($PSBoundParameters.ContainsKey('Filter')) {
            Foreach ($key in $Filter.Keys) {
                $request.AddFilter($key, $Filter[$key]) | Out-Null
            }
        }

        if ($PSBoundParameters.ContainsKey('StartTime')) {
            $request.SetStartTime($StartTime) | Out-Null
        }

        if ($PSBoundParameters.ContainsKey('Duration')) {
            $request.SetStopTime($Duration) | Out-Null
        }

        if ($PSBoundParameters.ContainsKey('ApiToken')) {
            $request.SetToken($ApiToken) | Out-Null
        }

        $request.Invoke()
    }
}