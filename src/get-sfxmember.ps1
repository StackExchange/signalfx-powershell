function Get-SFxMember {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Query,

        [Parameter(Position = 1)]
        [string]
        $OrderBy,

        [Parameter(Position = 2)]
        [int]
        $Limit,

        [Parameter(Position = 3)]
        [string]
        $ApiToken
    )

    $request = [SFxGetMember]::new()

    if ($PSBoundParameters.ContainsKey('Query')) {
        $request.Query($Query) | Out-Null
    }
    if ($PSBoundParameters.ContainsKey('OrderBy')) {
        $request.OrderBy($OrderBy) | Out-Null
    }
    if ($PSBoundParameters.ContainsKey('Limit')) {
        $request.Limit($Limit) | Out-Null
    }

    if ($PSBoundParameters.ContainsKey('ApiToken')) {
        $request.SetToken($ApiToken) | Out-Null
    }

    Write-Information $request.Uri
    $request.Invoke()
}