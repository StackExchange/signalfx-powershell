#https://developers.signalfx.com/detectors_reference.html#operation/Retrieve Detectors Query
class SFxQueryDetector : SFxClientApi {

    SFxQueryDetector([string]$name) : base('detector', 'GET') {
        $this.Uri = $this.Uri + '?name={0}' -f $name
    }

    [SFxQueryAlertMuting] Id([string]$id) {
        $this.Uri = $this.Uri + '&id={0}' -f $id
        return $this
    }

    [SFxQueryAlertMuting] Tags([string]$tag) {
        $this.Uri = $this.Uri + '&tags={0}' -f $tag
        return $this
    }

    [SFxQueryAlertMuting] Offset([int]$offset) {
        $this.Uri = $this.Uri + '&offset={0}' -f $offset
        return $this
    }

    [SFxQueryAlertMuting] Limit([int]$limit) {
        $this.Uri = $this.Uri + '&limit={0}' -f $limit
        return $this
    }
}
