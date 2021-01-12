<#
.SYNOPSIS
    Retrieves metadata for the MTS
.DESCRIPTION
    Retrieves metadata for the MTS specified by the ID query parameter
.PARAMETER Id
    ID of the MTS for which you want metadata
.PARAMETER Query
    Search criteria.
.PARAMETER Offset
    Object in the result set at which the API should start returning results to you. If omitted, the
    API starts at the first result in the set. API Default: 0
.PARAMETER Limit
    Number of results to return from the set of all metrics that match the query.
.PARAMETER ApiToken
    Authentication token
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    String
.OUTPUTS
    Object
#>
function Get-SFxMetricTimeSeriesMetadata {
    [CmdletBinding(DefaultParameterSetName = "Id")]
    param (
        [Parameter(Position = 0, Mandatory, ParameterSetName = "Id")]
        [string]
        $Id,


        [Parameter(Position = 0, Mandatory, ParameterSetName = "Query")]
        [string]
        $Query,

        [Parameter(Position = 1, ParameterSetName = "Query")]
        [int]
        $Offset,

        [Parameter(Position = 2, ParameterSetName = "Query")]
        [int]
        $Limit,

        [Parameter(Position = 1, ParameterSetName = "Id")]
        [Parameter(Position = 3, ParameterSetName = "Query")]
        [string]
        $ApiToken
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Id" {
                $request = [SFxGetMetricTimeSeries]::new($Id)
            }
            "Query" {
                $request = [SFxQueryMetricTimeSeries]::new($Query)
                if ($PSBoundParameters.ContainsKey('Offset')) {
                    $request.Offset($Offset) | Out-Null
                }
                if ($PSBoundParameters.ContainsKey('Limit')) {
                    $request.Limit($Limit) | Out-Null
                }
            }
        }

        if ($PSBoundParameters.ContainsKey('ApiToken')) {
            $request.SetToken($ApiToken) | Out-Null
        }

        $request.Invoke()
    }
}