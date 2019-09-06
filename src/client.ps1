class SFxClient {
    [string]$Realm = 'us1'
    [string]$Uri
    [string]$Method
    [hashtable] hidden $Headers = @{}

    SFxClient($path, $method) {
        $this.Uri = 'https://api.{0}.signalfx.com/v2/{1}' -f $this.Realm, $path
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
        return Invoke-RestMethod -Uri $this.Uri -Headers $this.Headers -ContentType 'application/json' -Method $this.Method
    }
}

class SFxGetDimension : SFxClient {

    SFxGetDimension([string]$key, [string]$value) : base('dimension', 'GET') {
        $this.Uri = $this.Uri + '/{0}/{1}' -f $key, $value
    }
}