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
    $delimiter = '?'

    SFxClientApi ($path, $method) : base ('api', $path, $method) {
        if ([Environment]::GetEnvironmentVariables().Contains('SFX_USER_TOKEN')) {
            $this.SetToken([Environment]::GetEnvironmentVariable('SFX_USER_TOKEN'))
        }
    }

    [char] GetDelimiter() {
        if ($this.delimiter -eq '?') {
            $this.delimiter = '&'
            return '?'
        }

        return $this.delimiter
    }

    [object] Invoke() {

        $parameters = @{
            Uri         = $this.Uri
            Headers     = $this.Headers
            ContentType = 'application/json'
            Method      = $this.Method
        }

        if ($this.Body.Count -gt 0) {
            $parameters["Body"] = $this.Body | ConvertTo-Json
        }

        #try {
            return Invoke-RestMethod @parameters# -ErrorAction Stop
        #} catch {
        #    Throw ("StatusCode: {0}{1}StatusDescription: {2}" -f $_.Exception.Response.StatusCode.value__, [Environment]::NewLine, $_.Exception.Message  )
        #    return $null
        #}
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