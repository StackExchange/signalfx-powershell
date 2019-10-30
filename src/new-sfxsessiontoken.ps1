<#
.SYNOPSIS
    Creates a session token
.DESCRIPTION
    Creates a session token (referred to as an User API Access Token in the web UI) that provides
    authentication for other SignalFx API calls.
.PARAMETER Credential
    The email address you used to join the organization for which you want a session token.
    The password you provided to SignalFx when you accepted an invitation to join an organization.
    If you're using an external protocol such as SAML or LDAP to connect to SignalFx, you can't use
    that protocol's credentials.
.EXAMPLE
    PS C:\> Get-SFxSessionToken -Credential (Get-Credential)

    abc123-zyx098
.INPUTS
    pscredential
.OUTPUTS
    string
.NOTES
    You can't use a session token for authenticating a /datapoint, /backfill, or /event API call.
    These APIs require an org token (referred to as an access token in the web UI.)
#>
function New-SFxSessionToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0)]
        [pscredential]
        $Credential,

        [Parameter(Position = 1)]
        [string]
        $ApiToken
    )

    $request = [GetSFxSessionToken]::new($Credential)

    if ($PSBoundParameters.ContainsKey('ApiToken')) {
        $request.SetToken($ApiToken) | Out-Null
    }

    Write-Information $request.Uri
    $result = $request.Invoke()
    Write-Information ($result | Format-List | Out-String)

    $result | Select-Object -ExpandProperty accessToken
}