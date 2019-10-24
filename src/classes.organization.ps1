# https://developers.signalfx.com/organizations_reference.html#tag/Retrieve-Organization-Members
class SFxGetMember : SFxClientApi {
    SFxGetMember() : base('organization/member', 'GET') {
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

# https://developers.signalfx.com/organizations_reference.html#tag/Invite-Member
class SFxInviteMember : SFxClientApi {
    SFxInviteMember([string]$email) : base('organization/member', 'POST') {
        $this.Body.Add('email', $email)
        $this.Body.Add('admin', 'false')
        $this.Body.Add('fullName', [string]::Empty)
        $this.Body.Add('phone', [string]::Empty)
        $this.Body.Add('title', [string]::Empty)
    }

    [SFxInviteMember] SetAdmin() {
        $this.Body['admin'] = 'true'
        return $this
    }

    [SFxInviteMember] SetFullName([string]$name) {
        $this.Body['fullName'] = $name
        return $this
    }

    [SFxInviteMember] SetPhone([string]$phone) {
        $this.Body['phone'] = $phone
        return $this
    }

    [SFxInviteMember] SetTitle([string]$title) {
        $this.Body['title'] = $title
        return $this
    }

    [object] Invoke() {

        $parameters = @{
            Uri         = $this.Uri
            Headers     = $this.Headers
            ContentType = 'application/json'
            Method      = $this.Method
        }

        if ($this.Body.Count -gt 0) {
            $parameters["Body"] = $this.Body | ConvertTo-Json
        }

        try {
            return Invoke-RestMethod @parameters
        } catch {
              Write-Error "StatusCode: {0}{1}StatusDescription: {2}" $_.Exception.Response.StatusCode.value__, [Environment]::NewLine ,$_.Exception.Response.StatusDescription
          return $null
        }
    }
}

# https://developers.signalfx.com/organizations_reference.html#tag/Delete-Member-Using-ID
class SFxRemoveMember : SFxClientApi {
    SFxRemoveMember([string]$id) : base('organization/member', 'DELETE') {
        $this.Uri = $this.Uri + '/{0}' -f $id
    }
}
