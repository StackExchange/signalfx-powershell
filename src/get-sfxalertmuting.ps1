<#
.SYNOPSIS
    Retrieves alerting muting rules based on search criteria
.DESCRIPTION
    Retrieves alerting muting rules based on the query you specify in the query query parameter.
    This endpoint retrieves alert muting rules regardless of the version of the detector associated
    with the rule.
.PARAMETER Id
    SignalFx-assigned ID of an alerting muting rule
.PARAMETER Include
    Specifies the type of muting rules you want to retrieve. The allowed values are:
        Past
        Future
        Ongoing
        Open
        All
.PARAMETER Query
    Query that specifies the muting rules you want to retrieve.
.PARAMETER OrderBy
    The metadata property on which the API should sort the results. You don't have to include this
    property in the query, but the name must be a property of alert muting rules.
.PARAMETER Offset
    The result object in the result set at which the API should start returning results to you.
    If omitted, the API starts at the first result in the set.
.PARAMETER Limit
    The number of results to return from the result set.
.PARAMETER ApiToken
    Authentication token
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    String
.OUTPUTS
    Object
.NOTES
    Retrieves metadata objects for which the metrics name matches the search criteria.

    The API first collects all of the matching results. This is known as the result set. Depending
    on the values you specify for offset and limit, the number of metadata objects in the response
    body can be smaller than than the result set. For example, if you specify offset=0 (the default)
    and limit=50, and the API finds 100 matches, you only receive the first 50 results.
#>
function Get-SFxAlertMuting {
    [CmdletBinding(DefaultParameterSetName = "Query")]
    param (
        [Parameter(Position = 0, Mandatory, ParameterSetName = "ID")]
        [string]
        $Id,

        [Parameter(Position = 0, Mandatory, ParameterSetName = "Query")]
        [string]
        $Query,

        [Parameter(Position = 1, ParameterSetName = "Query")]
        [ValidateSet('Past','Future','Ongoing','Open','All')]
        [string]
        $Include = 'All',

        [Parameter(Position = 2, ParameterSetName = "Query")]
        [string]
        $OrderBy,

        [Parameter(Position = 3, ParameterSetName = "Query")]
        [int]
        $Offset,

        [Parameter(Position = 4, ParameterSetName = "Query")]
        [int]
        $Limit,

        [Parameter(Position = 2, ParameterSetName = "ID")]
        [Parameter(Position = 5, ParameterSetName = "Query")]
        [string]
        $ApiToken
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "ID" {
                Write-Warning "Not yet implemented"
            }
            "Query" {
                $request = [SFxQueryAlertMuting]::new($Query)
                if ($PSBoundParameters.ContainsKey('Include')) {
                    $request.Include($Include) | Out-Null
                }
                if ($PSBoundParameters.ContainsKey('OrderBy')) {
                    $request.OrderBy($OrderBy) | Out-Null
                }
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