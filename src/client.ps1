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

class SFxQueryDimension : SFxClient {

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