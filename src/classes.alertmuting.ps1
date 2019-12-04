# https://developers.signalfx.com/incidents_reference.html#tag/Retrieve-Alert-Muting-Rules-Query
class SFxQueryAlertMuting : SFxClientApi {

    SFxQueryAlertMuting([string]$query) : base('alertmuting', 'GET') {
        $this.Uri = $this.Uri + '?query={0}' -f $query
    }

    [SFxQueryAlertMuting] Include([string]$include) {
        $this.Uri = $this.Uri + '&include={0}' -f $include
        return $this
    }

    [SFxQueryAlertMuting] OrderBy([string]$orderBy) {
        $this.Uri = $this.Uri + '&orderBy={0}' -f $orderBy
        return $this
    }

    [SFxQueryAlertMuting] Offset([int]$offset) {
        $this.Uri = $this.Uri + '&offset={0}' -f $offset
        return $this
    }

    [SFxQueryAlertMuting] Limit([int]$limit) {
        $this.Uri = $this.Uri + '&limit={0}' -f $limit
        return $this
    }

}

class SFxMuteFilter {
    [bool] $NOT = $false
    [string] $property
    [string] $propertyValue

    SFxMuteFilter([string]$p, [string]$v) {
        $this.property = $p
        $this.propertyValue = $v
    }

    SFxMuteFilter([bool]$n, [string]$p, [string]$v) {
        $this.NOT = $n
        $this.property = $p
        $this.propertyValue = $v
    }
}

# https://developers.signalfx.com/incidents_reference.html#tag/Create-Single-Alert-Muting-Rule
class SFxNewAlertMuting : SFxClientApi {

    [datetime] hidden $StartTime
    [datetime] hidden $StopTime

    SFxNewAlertMuting([string]$description) : base('alertmuting', 'POST') {
        $this.Body.Add('description', $description)
        $this.SetStartTime()
        $this.SetStopTime('1h')
    }

    [SFxNewAlertMuting] AddFilter ([bool]$not, [string]$key, [string]$value) {
        $filter = [SFxMuteFilter]::new($not, $key, $value)

        if ($this.Body.ContainsKey('filters')) {
            $this.Body.filters += $filter
        }
        else {
            $this.Body.Add('filters', @( $filter ))
        }
        return $this
    }

    [SFxNewAlertMuting] AddFilter ([string]$key, [string]$value) {
        return $this.AddFilter($false, $key, $value)
    }

    [SFxNewAlertMuting] SetStartTime([DateTime]$timestamp) {
        $this.StartTime = $timestamp
        if ($this.Body.ContainsKey('startTime')) {
            $this.Body['startTime'] = $this.GetTimeStamp($this.StartTime)
        }
        else {
            $this.Body.Add('startTime', $this.GetTimeStamp($this.StartTime))
        }
        return $this
    }

    [SFxNewAlertMuting] SetStartTime() {
        return $this.SetStartTime([datetime]::Now)
    }

    [SFxNewAlertMuting] SetStopTime([DateTime]$timestamp) {
        $this.StopTime = $timestamp
        if ($this.Body.ContainsKey('stopTime')) {
            $this.Body['stopTime'] = $this.GetTimeStamp($this.StopTime)
        }
        else {
            $this.Body.Add('stopTime', $this.GetTimeStamp($this.StopTime))
        }
        return $this
    }

    [SFxNewAlertMuting] SetStopTime([string]$timespan) {

        $pattern = [regex]"(\d+)([mhd]{1})"
        $match = $pattern.Match($timespan)

        if ($match.Length -ne 2) {
            throw "Not a valid Timespan format"
        }
        else {
            $value = $match.Groups[1].Value
            $scale = $match.Groups[2].Value

            [DateTime]$datetime = switch -casesensitive ($scale) {
                'm' {
                    $this.StartTime.AddMinutes($value)
                    break
                }
                'h' {
                    $this.StartTime.AddHours($value)
                    break
                }
                'd' {
                    $this.StartTime.AddDays($value)
                    break
                }
            }

            return $this.SetStopTime($datetime)
        }
    }

    [object] Invoke() {

        $parameters = @{
            Uri         = $this.Uri
            Headers     = $this.Headers
            ContentType = 'application/json'
            Method      = $this.Method
        }

        if ($this.Body.Count -gt 0) {
            $parameters["Body"] = ConvertTo-Json $this.Body
        }

        return Invoke-RestMethod @parameters
    }
}