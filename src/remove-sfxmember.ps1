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

        if ($PSBoundParameters.ContainsKey('Id')) {
            $request.RemoveMember($Id) | Out-Null
        }
        if ($PSBoundParameters.ContainsKey('ApiToken')) {
            $request.SetToken($ApiToken) | Out-Null
        }
        try {
        Write-Information $request.Uri
        $request.Invoke()
        } catch {
          Write-Host $_.Exception.Response.StatusCode.value__
          Write-Host $_.Exception.Response.StatusDescription
        }
    }

}
