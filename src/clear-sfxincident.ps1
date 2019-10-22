function Clear-SFxIncident {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('incidentId')]
        [string]
        $Id,

        [Parameter(Position = 1)]
        [string]
        $ApiToken
    )

    process {
        $request = [SFxClearIncident]::new($Id)

        if ($PSBoundParameters.ContainsKey('ApiToken')) {
            $request.SetToken($ApiToken) | Out-Null
        }

        Write-Information $request.Uri
        $request.Invoke()
    }

}