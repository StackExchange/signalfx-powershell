function Get-SFxMetricMetadata {
    [CmdletBinding(DefaultParameterSetName = "Metric")]
    param (
        [Parameter(Position = 0, Mandatory, ParameterSetName = "Metric")]
        [string]
        $Metric,

        [Parameter(Position = 0, Mandatory, ParameterSetName = "Query")]
        [string]
        $Query,

        [Parameter(Position = 1, ParameterSetName = "Query")]
        [string]
        $OrderBy,

        [Parameter(Position = 2, ParameterSetName = "Query")]
        [int]
        $Offset,

        [Parameter(Position = 3, ParameterSetName = "Query")]
        [int]
        $Limit,

        [Parameter(Position = 2, ParameterSetName = "Metric")]
        [Parameter(Position = 4, ParameterSetName = "Query")]
        [string]
        $ApiToken
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Metric" {
                $request = [SFxGetMetric]::new($Metric)
            }
            "Query" {
                $request = [SFxQueryMetric]::new($Query)
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