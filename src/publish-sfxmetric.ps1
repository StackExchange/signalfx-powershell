function Publish-SfxMetric {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [SfxPostDataPoint[]]
        $InputObject,

        [Parameter(Position = 1)]
        [string]
        $ApiToken
    )

    begin {

    }

    process {
        foreach ($item in $InputObject) {

            if ($PSBoundParameters.ContainsKey('ApiToken')) {
                $item.SetToken($ApiToken) | Out-Null
            }

            $item.Invoke()
        }
    }

    end {

    }
}