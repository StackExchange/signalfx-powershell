<#
.SYNOPSIS
    Configured the SignalFx Realm
.DESCRIPTION
    A realm is a self-contained deployment of SignalFx that hosts your organization. The API
    endpoint for a realm contains a realm-specific path segment. For example:

    For the us1 realm, the endpoint for sending metrics is https://ingest.us1.signalfx.com/v2.
    For the eu0 realm, the endpoint for sending metrics is https://ingest.eu0.signalfx.com/v2
.EXAMPLE
    PS C:\> Set-SFxRealm eu0
    This sets the API endpoign to https://{api|ingest}.eu0.signalfx.com/v2.
.INPUTS
    string
.NOTES
    To find the name of your realm, go to your profile page in the web UI.
#>
function Set-SFxRealm {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [ValidateSet('eu0', 'us0', 'us1')]
        [string]
        $Realm
    )

    $env:SFX_REALM = $Realm
}