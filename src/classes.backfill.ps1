# https://developers.signalfx.com/backfill_reference.html#tag/Backfill-MTS
class SFxBackfill : SFxClientBackfill {

    SFxBackfill($orgId, $metricName) {
        $this.Uri = $this.Uri + '?orgid={0}&metric={1}' -f $orgId, $metricName
    }

    [SFxBackfill] SetMetricType([string]$type) {
        $this.Uri = $this.Uri + '&metric_type={0}' -f $type
        return $this
    }

    [SFxBackfill] AddDimension ([string]$key, [string]$value) {
        $this.Uri = $this.Uri + '&sfxdim_{0}={1}' -f $key, $value
        return $this
    }

    [void] AddValue ([string]$timestamp, [int64]$value) {
        $this.Body.AppendFormat('{{"timestamp":{0},"value":{1}}} ', $timestamp, $value)
    }
}