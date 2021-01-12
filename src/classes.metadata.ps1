# https://developers.signalfx.com/metrics_metadata_reference.html#tag/Retrieve-Dimension-Metadata-Name-Value
class SFxGetDimension : SFxClientApi {

    SFxGetDimension([string]$key, [string]$value) : base('dimension', 'GET') {
        $this.Uri = $this.Uri + '/{0}/{1}' -f $key, $value
    }
}

# https://developers.signalfx.com/metrics_metadata_reference.html#operation/Retrieve%20Dimensions%20Query
class SFxQueryDimension : SFxClientApi {

    SFxQueryDimension([string]$query) : base('dimension', 'GET') {
        $this.Uri = $this.Uri + '?query={0}' -f $query
    }

    [SFxQueryDimension] OrderBy([string]$orderBy) {
        $this.Uri = $this.Uri + '&orderBy={0}' -f $orderBy
        return $this
    }

    [SFxQueryDimension] Offset([int]$offset) {
        $this.Uri = $this.Uri + '&offset={0}' -f $offset
        return $this
    }

    [SFxQueryDimension] Limit([int]$limit) {
        $this.Uri = $this.Uri + '&limit={0}' -f $limit
        return $this
    }

}

class SFxGetMetric : SFxClientApi {

    SFxGetMetric([string]$name) : base('metric', 'GET') {
        $this.Uri = $this.Uri + '/{0}' -f $name
    }
}

# https://developers.signalfx.com/metrics_metadata_reference.html#operation/Retrieve%20Dimensions%20Query
class SFxQueryMetric : SFxClientApi {

    SFxQueryMetric([string]$query) : base('metric', 'GET') {
        $this.Uri = $this.Uri + '?query={0}' -f $query
    }

    [SFxQueryDimension] OrderBy([string]$orderBy) {
        $this.Uri = $this.Uri + '&orderBy={0}' -f $orderBy
        return $this
    }

    [SFxQueryDimension] Offset([int]$offset) {
        $this.Uri = $this.Uri + '&offset={0}' -f $offset
        return $this
    }

    [SFxQueryDimension] Limit([int]$limit) {
        $this.Uri = $this.Uri + '&limit={0}' -f $limit
        return $this
    }

}

# https://dev.splunk.com/observability/reference/api/metrics_metadata/latest#endpoint-retrieve-mts-metadata-using-id
class SFxGetMetricTimeSeries : SFxClientApi {

    SFxGetMetricTimeSeries([string]$id) : base('metrictimeseries', 'GET') {
        $this.Uri = $this.Uri + '/{0}' -f $id
    }
}

# https://dev.splunk.com/observability/reference/api/metrics_metadata/latest#endpoint-retrieve-metric-timeseries-metadata
class SFxQueryMetricTimeSeries : SFxClientApi {

    SFxQueryMetricTimeSeries([string]$query) : base('metrictimeseries', 'GET') {
        $this.Uri = $this.Uri + '?query={0}' -f $query
    }

    [SFxQueryMetricTimeSeries] Offset([int]$offset) {
        $this.Uri = $this.Uri + '&offset={0}' -f $offset
        return $this
    }

    [SFxQueryMetricTimeSeries] Limit([int]$limit) {
        $this.Uri = $this.Uri + '&limit={0}' -f $limit
        return $this
    }

}
