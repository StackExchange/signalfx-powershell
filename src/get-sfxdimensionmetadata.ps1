<#
.SYNOPSIS
    Retrieves metadata for a dimension and value
.DESCRIPTION
    Retrieves the metadata for the dimension and value specified in the key and value path
    parameters
.PARAMETER Key
    Dimension name
.PARAMETER Value
    Dimension value
.PARAMETER Query
    Metric name search string. The string always starts with name:. You have the following search
    options:

    To search by metric name, use name:<metric_name>. This returns all of the metadata for that
    metric. To search for names using wildcards, use * as the wildcard character. For example, to
    search for all the metrics that start with cpu., use name:cpu.*. This returns metadata for
    cpu.utilization, cpu.num_cores, and so forth.
.PARAMETER OrderBy
    Result object property on which the API should sort the results. This must be a property of the
    metrics metadata object.
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
.NOTES
    Retrieves metadata objects for which the metrics name matches the search criteria.

    The API first collects all of the matching results. This is known as the result set. Depending
    on the values you specify for offset and limit, the number of metadata objects in the response
    body can be smaller than than the result set. For example, if you specify offset=0 (the default)
    and limit=50, and the API finds 100 matches, you only receive the first 50 results.
#>
function Get-SFxDimensionMetadata {
    [CmdletBinding(DefaultParameterSetName = "KV")]
    param (
        [Parameter(Position=0, Mandatory, ParameterSetName="KV")]
        [string]
        $Key,

        [Parameter(Position=1, Mandatory, ParameterSetName="KV")]
        [string]
        $Value,

        [Parameter(Position=0, Mandatory, ParameterSetName="Query")]
        [string]
        $Query,

        [Parameter(Position=1, Mandatory, ParameterSetName="Query")]
        [string]
        $OrderBy,

        [Parameter(Position=2, Mandatory, ParameterSetName="Query")]
        [int]
        $Offset,

        [Parameter(Position=3, Mandatory, ParameterSetName="Query")]
        [int]
        $Limit,

        [Parameter(Position=2, ParameterSetName="KV")]
        [Parameter(Position=4, Mandatory, ParameterSetName="Query")]
        [string]
        $ApiToken
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "KV" {
                $request = [SFxGetDimension]::new($Key, $Value)
            }
            "Query" {
                $request = [SFxQueryDimension]::new($Query)
                if ($PSBoundParameters.ContainsKey('OrderBy')) {
                    $request.OrderBy($OrderBy) | Out-Null
                }
                if ($PSBoundParameters.ContainsKey('Offset')) {
                    $request.Offset($Offset) | Out-Null
                }
                if ($PSBoundParameters.ContainsKey('Limit')) {
                    $request.Limit($Limit)
                }
            }
        }

        if ($PSBoundParameters.ContainsKey('ApiToken')) {
            $request.SetToken($ApiToken)
        }

        $request.Invoke()
    }
}