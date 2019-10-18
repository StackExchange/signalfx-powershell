# https://developers.signalfx.com/ingest_data_reference.html#operation/Send%20Custom%20Events
class SFxPostEvent : SFxClientIngest {

    SFxPostEvent([string]$eventType) :base('event', 'POST') {
        $this.Body.Add('eventType', $eventType)
        $this.Body.Add('timestamp', $this.GetTimeStamp())
        $this.Body.Add('category', 'USER_DEFINED')
    }

    [SFxPostEvent] SetCategory ([string]$category) {
        $valid = @("USER_DEFINED", "ALERT", "AUDIT", "JOB", "COLLECTED", "SERVICE_DISCOVERY", "EXCEPTION")
        if ($valid -notcontains $category) {
            throw "Invalid Category. Valid optiosn are [$($valid -join ', ')]"
        }
        $this.Body["category"] = $category
        return $this
    }

    [SFxPostEvent] AddDimension ([string]$key, [string]$value) {
        if ($this.Body.ContainsKey('dimensions')) {
            $this.Body.dimensions.Add($key, $value)
        }
        else {
            $this.Body.Add('dimensions', @{$key = $value })
        }
        return $this
    }

    [SFxPostEvent] AddProperty ([string]$key, [string]$value) {
        if ($this.Body.ContainsKey('properties')) {
            $this.Body.properties.Add($key, $value)
        }
        else {
            $this.Body.Add('properties', @{$key = $value })
        }
        return $this
    }
}
