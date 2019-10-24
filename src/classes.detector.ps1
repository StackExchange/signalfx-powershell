#https://developers.signalfx.com/detectors_reference.html#operation/Retrieve Detectors Query
class SFxQueryDetector : SFxClientApi {

    SFxQueryDetector([string]$name) : base('detector', 'GET') {
        $this.Uri = $this.Uri + '?name={0}' -f $name
    }

    [SFxQueryDetector] Id([string]$id) {
        $this.Uri = $this.Uri + '&id={0}' -f $id
        return $this
    }

    [SFxQueryDetector] Tags([string]$tag) {
        $this.Uri = $this.Uri + '&tags={0}' -f $tag
        return $this
    }

    [SFxQueryDetector] Offset([int]$offset) {
        $this.Uri = $this.Uri + '&offset={0}' -f $offset
        return $this
    }

    [SFxQueryDetector] Limit([int]$limit) {
        $this.Uri = $this.Uri + '&limit={0}' -f $limit
        return $this
    }
}
