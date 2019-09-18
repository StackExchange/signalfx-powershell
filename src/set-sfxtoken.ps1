<#
.SYNOPSIS
    Configure SignalFx API Tokens
.DESCRIPTION
    SignalFx REST requests use token-based authentication. SignalFx uses two types of tokens:

    Org tokens
    Known as Access Tokens in the SignalFx web UI, org tokens are long-lived organization-level
    tokens.

    Session tokens
    Known as User API Access Tokens in the SignalFx web UI, session tokens are short-lived
    user-level tokens.
.EXAMPLE
    PS C:\> Set-SFx-Token abc123
    Set $env:SFX_USER_TOKEN = 'abc123'
.EXAMPLE
    PS C:\> Set-SFx-Token -UserToken abc123 -OrgToken xyz890
    Set $env:SFX_USER_TOKEN = 'abc123' and $env:SFX_ACCESS_TOKEN = 'xyz890'
.INPUTS
    string
.NOTES
    To get the org token for your organization, go to the Organization Overview in the SignalFx web
    UI and click the Access Tokens option. SignalFx administrators can also get a new token or
     manage organization tokens in this location.

    To get a session token, go to your profile page to generate a User API Access Token.
#>
function Set-SFxToken {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias('SessionToken')]
        [string]
        $UserToken,

        [Parameter(Position = 1)]
        [Alias('AccessToken')]
        [string]
        $OrgToken
    )


    if ($PSBoundParameters.ContainsKey('UserToken')) {
        [Environment]::SetEnvironmentVariable('SFX_USER_TOKEN', $UserToken)
    }

    if ($PSBoundParameters.ContainsKey('OrgToken')) {
        [Environment]::SetEnvironmentVariable('SFX_ACCESS_TOKEN', $OrgToken)
    }

    <#     TODO: The endpoint https://api.{REALM}.signalfx.com/v2/session manages session tokens.
    You don’t need a token to create a session token, but you do need to specify the email
    and password of an organization member. #>
}