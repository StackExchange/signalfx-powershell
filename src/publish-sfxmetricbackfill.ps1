<#
.SYNOPSIS
    Sends historical MTS to SignalFx
.DESCRIPTION
    Sends historical MTS to SignalFx, overwriting any existing datapoints for the same time period.
.PARAMETER OrgId
    The SignalFx ID for the organization that should receive the incoming data
.PARAMETER Name
    The name of the metric in the MTS that you're backfilling
.PARAMETER Type
    The metric type for the metric you're backfilling.
.PARAMETER Dimension
    Designates one or mroe of the dimension names that identify the MTS you're backfilling, up to
    the limit of 36 dimensions. Note: You must specify all the dimensions associated with the MTS.
    If you don't, the backfill creates a new MTS based on the dimensions you specify.
.PARAMETER ApiToken
    Authentication token
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    String, DateTime
.OUTPUTS

.NOTES
    A single call to /backfill can only refer to a single MTS specified by its metric type, metric
    name, and dimensions.

    Use the API in "bulk" mode. It's designed to accept thousands of datapoints in each call, such
    as 1 hour of points with a resolution of one second or one day of points with a resolution of
    one minute.

    Timestamps for each datapoint must be monotonically ascending.

    A single call to /backfill must contain one or more hour-long groups of datapoints, with each
    hour starting one millisecond after the top of the hour and ending exactly at the top of the
    following hour.

    Avoid large gaps in the data, because the provided data replaces all of the data in the
    equivalent time period of existing data. For example, if you have one hundred datapoints for an
    MTS over one hour, and you backfill with 20 datapoints for the same MTS over the same hour, you're left with 20 datapoints.

    NOTE: /backfill doesn't support the built-in sf_hires dimension that marks datapoints as high resolution.
#>
function Publish-SFxMetricBackfill {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory)]
        [string]
        $OrgId,

        [Parameter(Position=1, Mandatory)]
        [string]
        $Name,

        [Parameter(Position=2, Mandatory)]
        [ValidateSet('gauge','counter','cumulative_counter')]
        [string]
        $Type,

        [Parameter(Position=3, Mandatory)]
        [string[]]
        $Dimension,

        [Parameter(Position = 4)]
        [string]
        $ApiToken,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [datetime]
        $Timestamp,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [int64]
        $Value
    )

    begin {
        $request = [SFxBackfill]::new($OrgId, $Name).SetMetricType($Type)

        Foreach ($d in $Dimension) {
            $request.AddDimension($d) | Out-Null
        }

        if ($PSBoundParameters.ContainsKey('ApiToken')) {
            $request.SetToken($ApiToken) | Out-Null
        }
    }

    process {
        $unixtime = $request.GetTimeStamp($Timestamp)
        $request.AddValue($unixtime, $Value)
    }

    end {
        Write-Information ("Request URI: {0}" -f $request.Uri)
        #$request.Invoke()
    }
}