class SFxClient {
    [string]$Realm = 'us1'
    [string]$ApiVersion = 'v2'
    [string]$Uri
    [string]$Method

    [string] hidden $Endpoint
    [string] hidden $Path
    [hashtable] hidden $Headers = @{ }
    [hashtable] hidden $Body = @{ }

    [string] hidden $EnvName_Realm = 'SFX_REALM'
    [string] hidden $EnvName_AccessToken = 'SFX_ACCESS_TOKEN'
    [string] hidden $EnvName_UserToken = 'SFX_USER_TOKEN'



    SFxClient($endpoint, $path, $method) {
        if ([Environment]::GetEnvironmentVariables().Contains($this.EnvName_Realm)) {
            $this.SetRealm([Environment]::GetEnvironmentVariable($this.EnvName_Realm))
        }
        $this.Endpoint = $endpoint
        $this.Path = $path
        $this.Method = $method

        $this.ConstructUri()
    }

    [void] ConstructUri() {
        $this.Uri = 'https://{0}.{1}.signalfx.com/{2}/{3}' -f $this.Endpoint, $this.Realm, $this.ApiVersion, $this.Path
    }

    [SFxClient] SetRealm([string]$realm) {
        $this.Realm = $realm
        $this.ConstructUri()
        return $this
    }

    [SFxClient] SetToken([string]$token) {
        if ($this.Headers.ContainsKey('X-SF-TOKEN')) {
            $this.Headers['X-SF-TOKEN'] = $token
        }
        else {
            $this.Headers.Add('X-SF-TOKEN', $token)
        }
        return $this
    }

    [object] Invoke() {

        $parameters = @{
            Uri         = $this.Uri
            Headers     = $this.Headers
            ContentType = 'application/json'
            Method      = $this.Method
        }

        if ($this.Body.Count -gt 0) {
            $parameters["Body"] = '[{0}]' -f ($this.Body | ConvertTo-Json)
        }

        return Invoke-RestMethod @parameters
    }

    [int64] GetTimeStamp() {
        return [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    }

    [int64] GetTimeStamp([DateTime]$timestamp) {
        return [DateTimeOffset]::new($timestamp).ToUnixTimeMilliseconds()
    }
}

class SFxClientApi : SFxClient {
    SFxClientApi ($path, $method) : base ('api', $path, $method) {
        if ([Environment]::GetEnvironmentVariables().Contains('SFX_USER_TOKEN')) {
            $this.SetToken([Environment]::GetEnvironmentVariable('SFX_USER_TOKEN'))
        }
    }
}

class SFxClientIngest : SFxClient {
    SFxClientIngest ($path, $method) : base ('ingest', $path, $method) {
        if ([Environment]::GetEnvironmentVariables().Contains('SFX_ACCESS_TOKEN')) {
            $this.SetToken([Environment]::GetEnvironmentVariable('SFX_ACCESS_TOKEN'))
        }
    }
}

class SFxClientBackfill : SFxClient {
    [Text.StringBuilder] $Body

    SFxClientBackfill () : base ('backfill', 'backfill', 'POST') {
        $this.ApiVersion = 'v1'

        # Apply the custom API version for this endpoint
        $this.ConstructUri()

        if ([Environment]::GetEnvironmentVariables().Contains('SFX_ACCESS_TOKEN')) {
            $this.SetToken([Environment]::GetEnvironmentVariable('SFX_ACCESS_TOKEN'))
        }

        # At least 360 datapoints an hour in the JSON format SFx is expecting is at least 13,320 chars
        # So, we might as well initialize the StringBuilder to hold at least that
        $this.Body = [Text.StringBuilder]::new(13400)
    }

    [object] Invoke() {

        $parameters = @{
            Uri         = $this.Uri
            Headers     = $this.Headers
            ContentType = 'application/json'
            Method      = $this.Method
            Body        = $this.Body.ToString()
        }

        return Invoke-RestMethod @parameters
    }
}

# https://developers.signalfx.com/metrics_metadata_reference.html#tag/Retrieve-Dimension-Metadata-Name-Value
class SFxGetDimension : SFxClientApi {

    SFxGetDimension([string]$key, [string]$value) : base('dimension', 'GET') {
        $this.Uri = $this.Uri + '/{0}/{1}' -f $key, $value
    }
}

# https://developers.signalfx.com/metrics_metadata_reference.html#operation/Retrieve%20Dimensions%20Query
class SFxQueryDimension : SFxClientApi {

    SFxQueryDimension([string]$query) : base('dimension', 'GET') {
        $this.Uri = $this.Uri + '?query={0}' -f $query
    }

    [SFxQueryDimension] OrderBy([string]$orderBy) {
        $this.Uri = $this.Uri + '&orderBy={0}' -f $orderBy
        return $this
    }

    [SFxQueryDimension] Offset([int]$offset) {
        $this.Uri = $this.Uri + '&offset={0}' -f $offset
        return $this
    }

    [SFxQueryDimension] Limit([int]$limit) {
        $this.Uri = $this.Uri + '&limit={0}' -f $limit
        return $this
    }

}

# https://developers.signalfx.com/ingest_data_reference.html#operation/Send%20Custom%20Events
class SFxPostEvent : SFxClientIngest {

    SFxPostEvent([string]$eventType) :base('event', 'POST') {
        $this.Body.Add('eventType', $eventType)
        $this.Body.Add('timestamp', $this.GetTimeStamp())
        $this.Body.Add('category', 'USER_DEFINED')
    }

    [SFxPostEvent] SetCategory ([string]$category) {
        $valid = @("USER_DEFINED", "ALERT", "AUDIT", "JOB", "COLLECTED", "SERVICE_DISCOVERY", "EXCEPTION")
        if ($valid -notcontains $category) {
            throw "Invalid Category. Valid optiosn are [$($valid -join ', ')]"
        }
        $this.Body["category"] = $category
        return $this
    }

    [SFxPostEvent] AddDimension ([string]$key, [string]$value) {
        if ($this.Body.ContainsKey('dimensions')) {
            $this.Body.dimensions.Add($key, $value)
        }
        else {
            $this.Body.Add('dimensions', @{$key = $value })
        }
        return $this
    }

    [SFxPostEvent] AddProperty ([string]$key, [string]$value) {
        if ($this.Body.ContainsKey('properties')) {
            $this.Body.properties.Add($key, $value)
        }
        else {
            $this.Body.Add('properties', @{$key = $value })
        }
        return $this
    }
}

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

# https://developers.signalfx.com/incidents_reference.html#tag/Create-Single-Alert-Muting-Rule
class SFxNewAlertMuting : SFxClientApi {

    [datetime] hidden $StartTime
    [datetime] hidden $StopTime

    SFxNewAlertMuting([string]$description) : base('alertmuting', 'POST') {
        $this.Body.Add('description', $description)
        $this.SetStartTime()
        $this.SetStopTime('1h')
    }


    [SFxNewAlertMuting] AddFilter ([string]$key, [string]$value) {
        if ($this.Body.ContainsKey('filters')) {
            $this.Body.filters.Add($key, $value)
        }
        else {
            $this.Body.Add('filters', @{$key = $value })
        }
        return $this
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
}

# https://developers.signalfx.com/backfill_reference.html#tag/Backfill-MTS
class SFxBackfill : SFxClientBackfill {

    SFxBackfill($orgId, $metricName) {
        $this.Uri = $this.Uri + '?orgid={0}&metric={1}' -f $orgId, $metricName
    }

    [SFxBackfill] SetMetricType([string]$type) {
        $this.Uri = $this.Uri + '&metric_type={0}' -f $type
        return $this
    }

    [SFxBackfill] AddDimension ([string]$key, [string]$value) {
        $this.Uri = $this.Uri + '&sfxdim_{0}={1}' -f $key, $value
        return $this
    }

    [void] AddValue ([string]$timestamp, [int64]$value) {
        $this.Body.AppendFormat('{{"timestamp":{0},"value":{1}}} ', $timestamp, $value)
    }
}