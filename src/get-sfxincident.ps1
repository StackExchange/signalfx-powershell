function Get-SFxIncident {
    [CmdletBinding()]
    param (

        [Parameter(Position = 0)]
        [int]
        $Offset,

        [Parameter(Position = 1)]
        [int]
        $Limit,

        [Parameter(Position = 2)]
        [string]
        $ApiToken,

        [Parameter()]
        [Switch]
        $IncludeResolved
    )

    $request = [SFxGetIncident]::new()

    if ($PSBoundParameters.ContainsKey('Offset')) {
        $request.Offset($Offset) | Out-Null
    }
    if ($PSBoundParameters.ContainsKey('Limit')) {
        $request.Limit($Limit) | Out-Null
    }
    if ($PSBoundParameters.ContainsKey('ApiToken')) {
        $request.SetToken($ApiToken) | Out-Null
    }
    if ($IncludeResolved) {
        $request.IncludeResolved() | Out-Null
    }

    Write-Information $request.Uri
    $request.Invoke()
}