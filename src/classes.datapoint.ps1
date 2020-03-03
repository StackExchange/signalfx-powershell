class SfxDataPoint {
    [hashtable]$dimensions
    [string]$metric
    [long]$timestamp
    [long]$value

    SfxDataPoint([hashtable]$dimensions, [string]$metric, [long]$value) {
        $this.dimensions = $dimensions
        $this.metric = $metric
        $this.value = $value
        $this.timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    }
}

# https://developers.signalfx.com/ingest_data_reference.html#operation/Send%20Metrics
class SfxPostDataPoint : SFxClientIngest {
    [string]$Type
    [string]$Metric
    [hashtable]$Dimensions
    [SfxDataPoint[]]$Data

    SfxPostDataPoint([string]$type, [string]$name) : base('datapoint', 'POST'){
        $this.Type = $type
        $this.Metric = $name
        $this.Dimensions = @{}
    }

    [SfxPostDataPoint] AddDimension ([string]$key, [string]$value) {
        $this.Dimensions.Add($key, $value)

        return $this
    }

    [SfxPostDataPoint] AddData ([long]$value) {
        $this.Data += [SfxDataPoint]::new($this.Dimensions, $this.Metric, $value)

        return $this
    }

    [object] Invoke() {

        $datahash = @{"$($this.type)" = $this.Data}

        $parameters = @{
            Uri         = $this.Uri
            Headers     = $this.Headers
            ContentType = 'application/json'
            Method      = $this.Method
            Body        = $datahash | ConvertTo-Json -Depth 3
        }

        return Invoke-RestMethod @parameters
    }
}