function Add-SfxMetricData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [SfxPostDataPoint]
        $InputObject,

        [Parameter(Mandatory, Position = 0)]
        [long]
        $Value,

        [Parameter(Position = 1)]
        [hashtable]
        $Dimension
    )

    begin { }

    process {
        $InputObject.AddData($Value)

        if ($PSBoundParameters.ContainsKey('Dimension')) {
            $InputObject.AddData($Value, $Dimension)
        } else {
            $InputObject.AddData($Value)
        }

    }

    end { }
}