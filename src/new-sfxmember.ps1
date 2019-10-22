function New-SFxMember {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Email,

        [Parameter(Position=1, ValueFromPipelineByPropertyName)]
        [string]
        $Fullname,

        [Parameter(Position=2, ValueFromPipelineByPropertyName)]
        [string]
        $Title,

        [Parameter(Position=3, ValueFromPipelineByPropertyName)]
        [string]
        $Phone,

        [Parameter(Position=4, ValueFromPipelineByPropertyName)]
        [switch]
        $Admin,

        [Parameter(Position = 5)]
        [string]
        $ApiToken
    )

    process {
        $request = [SFxInviteMember]::new($Email)

        if ($PSBoundParameters.ContainsKey('Fullname')) {
            $request.SetFullname($Fullname) | Out-Null
        }
        if ($PSBoundParameters.ContainsKey('Title')) {
            $request.SetTitle($Title) | Out-Null
        }
        if ($PSBoundParameters.ContainsKey('Phone')) {
            $request.SetPhone($Phone) | Out-Null
        }
        if ($Admin) {
            $request.SetAdmin() | Out-Null
        }
        if ($PSBoundParameters.ContainsKey('ApiToken')) {
            $request.SetToken($ApiToken) | Out-Null
        }

        Write-Information $request.Uri
        Write-Information $request.Body
        $request.Invoke()
    }

}