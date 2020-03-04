function New-SfxMetric {
    [CmdletBinding()]
    param (
        [ValidateSet('Gauge', 'Counter', 'CumulativeCounter')]
        [Parameter(Position = 0, Mandatory)]
        [string]
        $Type,

        [ValidateLength(1,256)]
        [Parameter(Position = 1, Mandatory)]
        [string]
        $Metric,

        [Parameter(Position = 2)]
        [hashtable]
        $Dimension,

        [Parameter(Position = 3)]
        [string]
        $ApiToken

    )

    $sfxMetric = [SfxPostDataPoint]::new($Type, $Metric)

    if ($PSBoundParameters.ContainsKey('Dimension')) {
        Foreach ($key in $Dimension.Keys) {
            $sfxMetric.AddDimension($key, $Dimension[$key]) | Out-Null
        }
    }

    if ($PSBoundParameters.ContainsKey('ApiToken')) {
        $item.SetToken($ApiToken) | Out-Null
    }

    $sfxMetric | Write-Output
}