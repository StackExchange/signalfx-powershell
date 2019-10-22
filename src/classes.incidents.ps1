class SFxGetIncident : SFxClientAPI {
    SFxGetIncident() : base('incident', 'GET') { }

    [SFxGetIncident] IncludeResolved(){
        $this.Uri = $this.Uri + '{0}includeResolved=true' -f $this.GetDelimiter()
        return $this
    }

    [SFxGetIncident] Offset([int]$offset) {
        $this.Uri = $this.Uri + '{0}offset={1}' -f $this.GetDelimiter(), $offset
        return $this
    }

    [SFxGetIncident] Limit([int]$limit) {
        $this.Uri = $this.Uri + '{0}limit={1}' -f $this.GetDelimiter(), $limit
        return $this
    }
}

class SFxClearIncident : SFxClientAPI {
    SFxClearIncident([string]$Id) : base('incident', 'PUT') {
        $this.Uri = $this.Uri + '/{0}/clear' -f $Id
    }
}