function Remove-SFxMember {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Id,

        [Parameter(Position = 1)]
        [string]
        $ApiToken
    )

    process {
        $request = [SFxRemoveMember]::new($Id)

        if ($PSBoundParameters.ContainsKey('ApiToken')) {
            $request.SetToken($ApiToken) | Out-Null
        }
        try {
            Write-Information $request.Uri
            $request.Invoke()
        } catch {
            Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
            Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        }
    }

}
