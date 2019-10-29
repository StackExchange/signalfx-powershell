# https://developers.signalfx.com/sessiontokens_reference.html#operation/Create%20Session%20Token
class GetSFxSessionToken : SFxClientIngest {
    GetSFxSessionToken([pscredential]$credential) : base('session', 'POST') {
        $this.Body.Add('email', $credential.UserName)
        $this.Body.Add('password', $credential.GetNetworkCredential().Password)
        $this.Endpoint = 'api'

        $this.ConstructUri()
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

        try {
            return Invoke-RestMethod @parameters
        } catch {
              Write-Error ("StatusCode: {0}{1}StatusDescription: {2}" -f $_.Exception.Response.StatusCode.value__, [Environment]::NewLine ,$_.Exception.Response.StatusDescription)
          return $null
        }
    }
}