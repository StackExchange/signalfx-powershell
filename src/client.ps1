class SFxClient {
    [string]$Realm = 'us1'
    [string]$Uri
    [string]$Method
    [hashtable] hidden $Headers = @{}
    [hashtable] hidden $Body = @{}

    SFxClient($endpoint, $path, $method) {
        if (Test-Path Env:\SFX_REALM) {
            $this.SetRealm($env:SFX_REALM)
        }
        $this.Uri = 'https://{0}.{1}.signalfx.com/v2/{2}' -f $endpoint, $this.Realm, $path
        $this.Method = $method
    }

    [SFxClient] SetRealm([string]$realm) {
        $this.Realm = $realm
        return $this
    }

    [SFxClient] SetToken([string]$token) {
        if ($this.Headers.ContainsKey('X-SF-TOKEN')) {
            $this.Headers['X-SF-TOKEN'] = $token
        } else {
            $this.Headers.Add('X-SF-TOKEN', $token)
        }
        return $this
    }

    [object] Invoke() {

        $parameters = @{
            Uri = $this.Uri
            Headers = $this.Headers
            ContentType = 'application/json'
            Method = $this.Method
        }

        if ($this.Body.Count -gt 0) {
            $parameters["Body"] = '[{0}]' -f ($this.body | ConvertTo-Json)
        }

        return Invoke-RestMethod @parameters
    }

    [int64] GetTimeStamp() {
        return [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
    }
}

class SFxClientApi : SFxClient {
    SFxClientApi ($path, $method) : base ('api', $path, $method) {
        if (Test-Path Env:\SFX_USER_TOKEN) {
            $this.SetToken($env:SFX_USER_TOKEN)
        }
    }
}

class SFxClientIngest : SFxClient {
    SFxClientIngest ($path, $method) : base ('ingest', $path, $method) {
        if (Test-Path Env:\SFX_ACCESS_TOKEN) {
            $this.SetToken($env:SFX_ACCESS_TOKEN)
        }
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
        $this.Uri = $this.Uri + '&orderBy={10}' -f $orderBy
        return $this
    }

    [SFxQueryDimension] Offset([string]$offset) {
        $this.Uri = $this.Uri + '&offset={10}' -f $offset
        return $this
    }

    [SFxQueryDimension] Limit([string]$limit) {
        $this.Uri = $this.Uri + '&limit={10}' -f $limit
        return $this
    }

}

# https://developers.signalfx.com/ingest_data_reference.html#operation/Send%20Custom%20Events
class SFxPostEvent : SFxClientIngest {

    SFxPostEvent([string]$eventType) :base('event', 'POST') {
        $this.body.Add('eventType', $eventType)
        $this.body.Add('timestamp', $this.GetTimeStamp())
        $this.body.Add('category', 'USER_DEFINED')
    }

    [SFxPostEvent] SetCategory ([string]$category) {
        $this.body["category"] = $category
        return $this
    }

    [SFxPostEvent] AddDimension ([string]$key, [string]$value) {
        if ($this.body.ContainsKey('dimensions')) {
            $this.body.dimensions.Add($key, $value)
        } else {
            $this.body.Add('dimensions', @{$key = $value})
        }
        return $this
    }

    [SFxPostEvent] AddProperty ([string]$key, [string]$value) {
        if ($this.body.ContainsKey('properties')) {
            $this.body.properties.Add($key, $value)
        } else {
            $this.body.Add('properties', @{$key = $value})
        }
        return $this
    }
}