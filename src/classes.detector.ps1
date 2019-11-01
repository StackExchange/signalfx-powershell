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

class SFxDetectorNotification {}
class SFxDetectorEmailNotification : SFxDetectorNotification{
    [string]$email = [string]::Empty
    [string]$type

    SFxDetectorEmailNotification() {
        $this.type = 'Email'
    }
}

class SFxDetectorRule {
    [string]$description = [string]::Empty
    [string]$detectLabel = [string]::Empty
    [bool]$disabled
    [SFxDetectorNotification[]]$notifications
    [string]$parameterizedBody = [string]::Empty
    [string]$parameterizedSubject = [string]::Empty
    [string]$runbookUrl = [string]::Empty
    [string]$severity = [string]::Empty

    [void] Critical() {
        $this.severity = 'Critical'
    }

    [void] Warning() {
        $this.severity = 'Warning'
    }

    [void] Major() {
        $this.severity = 'Major'
    }

    [void] Minor() {
        $this.severity = 'Minor'
    }

    [void] Info() {
        $this.severity = 'Info'
    }

    SFxDetectorRule() {
        $this.notifications += [SFxDetectorEmailNotification]::new()
        $this.Critical()
    }


}

class SFxTime {
    [int64]$end
    [int64]$range
    [int64]$start
    [string]$type

    SFxTime() {
        $this.end = 0
        $this.range = 0
        $this.start = 0
        $this.type = 'relative'
    }

    [void] Absolute() {
        $this.Type = 'absolute'
    }

    [void] Relative() {
        $this.Type = 'relative'
    }
}
class SFxDetectorVisualizationOptions {
    [bool]$disableSampling
    [bool]$showDataMarkers
    [bool]$showEventLines
    [SFxTime]$time

    SFxDetectorVisualizationOptions() {
        $this.disableSampling = $false
        $this.showDataMarkers = $false
        $this.showEventLines = $false
        $this.time = [SFxTime]::new()
    }
}

class SFxDetector {
    [string]$name = [string]::Empty
    [string]$programText = [string]::Empty
    [string]$description = [string]::Empty
    [int]$maxDelay

    [hashtable] $authorizedWriters = @{}
    [hashtable]$customProperties = @{}

    #[hashtable]$labelResolution = @{}


    [string]$packageSpecifications = [string]::Empty

    [SFxDetectorRule[]]$rules
    [string[]]$tags = @([string]::Empty)
    [string[]]$teams = @()
    [string]$timezone

    SFxDetector([string]$name, [string]$programText) {
        $this.authorizedWriters.Add('teams',@())
        $this.authorizedWriters.Add('users',@())
        $this.timezone = 'UTC'
        $this.name = $name
        $this.programText = $programText
        $this.rules = [SFxDetectorRule]::new()
    }

    [void] AddAuthorizedTeam($id) {
        $this.authorizedWriters['teams'] += $id
    }

    [void] AddAuthorizedUser($id) {
        $this.authorizedWriters['users'] += $id
    }

    [void] AddLabelResoltion([string]$property, [int]$value) {
        $this.labelResolution.Add($property, $value)
    }
}

class SFxNewDetector : SFxClientApi {
    hidden [SFxDetector]$Body

    SFxNewDetector([string]$name, [string]$programText) :base('detector', 'POST') {
        $this.Body = [SFxDetector]::new($name, $programText)

    }

    [SFxNewDetector] AddAuthorizedWriterTeam([string[]]$id) {
        foreach ($i in $id) {
            $this.Body.authorizedWriters['teams'] += $i
        }
        return $this
    }

    [SFxNewDetector] AddAuthorizedWriterUser([string[]]$id) {
        foreach ($i in $id) {
            $this.Body.authorizedWriters['users'] += $i
        }
        return $this
    }

    [SFxNewDetector] SetDescription([string]$description) {
        $this.Body.description = $description
        return $this
    }
}
