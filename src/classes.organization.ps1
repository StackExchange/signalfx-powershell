class SFxGetMember : SFxClientApi {
    $delimiter = '?'

    SFxGetMember() : base('organization/member', 'GET') {
    }

    [char] GetDelimiter() {
        if ($this.delimiter -eq '?') {
            $this.delimiter = '&'
            return '?'
        }

        return $this.delimiter
    }

    [SFxGetMember] Query([string]$query) {
        $this.Uri = $this.Uri + '{0}query={1}' -f $this.GetDelimiter(), $query
        return $this
    }

    [SFxGetMember] OrderBy([string]$orderBy) {
        $this.Uri = $this.Uri + '{0}orderBy={1}' -f $this.GetDelimiter(), $orderBy
        return $this
    }

    [SFxGetMember] Offset([int]$offset) {
        $this.Uri = $this.Uri + '{0}offset={1}' -f $this.GetDelimiter(), $offset
        return $this
    }

    [SFxGetMember] Limit([int]$limit) {
        $this.Uri = $this.Uri + '{0}limit={1}' -f $this.GetDelimiter(), $limit
        return $this
    }
}