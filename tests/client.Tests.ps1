Describe "client" {


    . "$PSScriptRoot/../src/classes.clients.ps1"
    . "$PSScriptRoot/../src/classes.metadata.ps1"
    . "$PSScriptRoot/../src/classes.events.ps1"
    . "$PSScriptRoot/../src/classes.alertmuting.ps1"
    . "$PSScriptRoot/../src/classes.backfill.ps1"

    Context "Base Class" {

        if ([Environment]::GetEnvironmentVariables().Contains('SFX_REALM')) {
            $this.SetRealm([Environment]::GetEnvironmentVariable('SFX_REALM'))
        }

        It 'Constructor should format $this.Uri' {
            $base = [SFxClient]::new('test_endpoint', 'test_path', 'test_method')
            $base.Uri | Should -Be 'https://test_endpoint.us1.signalfx.com/v2/test_path'
            $base.Method | Should -Be 'test_method'
        }

        It 'SetRealm should update Uri' {
            $base = [SFxClient]::new('test_endpoint', 'test_path', 'test_method')
            $base.SetRealm('test_realm')

            $base.Realm | Should -Be 'test_realm'
            $base.Uri | Should -Be 'https://test_endpoint.test_realm.signalfx.com/v2/test_path'
        }

        It 'SetToken should cet "X-SF-TOKEN" Headers' {
            $base = [SFxClient]::new('test_endpoint', 'test_path', 'test_method').SetToken('test_token')
            $base.Headers['X-SF-TOKEN'] | Should -Be 'test_token'
        }

        It 'SetToken should change "X-SF-TOKEN" Headers' {
            $base = [SFxClient]::new('test_endpoint', 'test_path', 'test_method').SetToken('test_token').SetToken('new_token')
            $base.Headers['X-SF-TOKEN'] | Should -Be 'new_token'
        }

        # TODO: Test SFxClient.Invoke Body formatting
    }

    Context 'API Client' {

        It 'Constructor should format $this.Uri' {
            $api = [SFxClientApi]::new('test_path', 'test_method')
            $api.Uri | Should -Be 'https://api.us1.signalfx.com/v2/test_path'
            $api.Method | Should -Be 'test_method'
        }

    }

    Context 'SFxGetDimension' {

        $getDimension = [SFxGetDimension]::new('test_key', 'test_value')

        It 'Constructor should format $this.Uri' {
            $getDimension.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension/test_key/test_value'
            $getDimension.Method | Should -Be 'GET'
        }

    }

    Context 'SFxQueryDimension' {

        It 'Constructor should format $this.Uri' {
            $queryDimension = [SFxQueryDimension]::new('test_query')
            $queryDimension.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension?query=test_query'
            $queryDimension.Method | Should -Be 'GET'
        }

        It 'OrderBy should add "orderBy" query' {
            $orderBy = [SFxQueryDimension]::new('test_query').OrderBy('test_key')
            $orderBy.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension?query=test_query&orderby=test_key'
        }

        It 'Offset should add "offset" query' {
            $offset = [SFxQueryDimension]::new('test_query').Offset(1)
            $offset.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension?query=test_query&offset=1'
        }

        It 'Limit should add "limit" query' {
            $limit = [SFxQueryDimension]::new('test_query').Limit(1)
            $limit.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension?query=test_query&limit=1'
        }

        It 'Should chain methods' {
            $chain = [SFxQueryDimension]::new('test_query').OrderBy('test_key').Offset(1).Limit(1)
            $chain.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension?query=test_query&orderby=test_key&offset=1&limit=1'
        }
    }
    
    Context 'SFxGetMetricTimeSeries' {

        $getMetricTimeSeries = [SFxGetMetricTimeSeries]::new('test_id')

        It 'Constructor should format $this.Uri' {
            $getMetricTimeSeries.Uri | Should -Be 'https://api.us1.signalfx.com/v2/metrictimeseries/test_id'
            $getMetricTimeSeries.Method | Should -Be 'GET'
        }

    }

    Context 'SFxQueryMetricTimeSeries' {

        It 'Constructor should format $this.Uri' {
            $queryMetricTimeSeries = [SFxQueryMetricTimeSeries]::new('test_query')
            $queryMetricTimeSeries.Uri | Should -Be 'https://api.us1.signalfx.com/v2/metrictimeseries?query=test_query'
            $queryMetricTimeSeries.Method | Should -Be 'GET'
        }

        It 'Offset should add "offset" query' {
            $offset = [SFxQueryMetricTimeSeries]::new('test_query').Offset(1)
            $offset.Uri | Should -Be 'https://api.us1.signalfx.com/v2/metrictimeseries?query=test_query&offset=1'
        }

        It 'Limit should add "limit" query' {
            $limit = [SFxQueryMetricTimeSeries]::new('test_query').Limit(1)
            $limit.Uri | Should -Be 'https://api.us1.signalfx.com/v2/metrictimeseries?query=test_query&limit=1'
        }

        It 'Should chain methods' {
            $chain = [SFxQueryMetricTimeSeries]::new('test_query').Offset(1).Limit(1)
            $chain.Uri | Should -Be 'https://api.us1.signalfx.com/v2/metrictimeseries?query=test_query&orderby=test_key&offset=1&limit=1'
        }
    }

    Context 'SFxPostEvent' {

        Mock -CommandName Invoke-RestMethod {
            param (
                [string]$Uri,
                [hashtable]$Headers,
                [string]$ContentType,
                [string]$Method,
                [string]$Body
            )

            return $PSBoundParameters
        }

        It 'Constructor should format $this.Uri and set minimum Body values' {
            $postEvent = [SFxPostEvent]::new('test_event')
            $postEvent.Uri | Should -Be 'https://ingest.us1.signalfx.com/v2/event'
            $postEvent.Method | Should -Be 'POST'

            $postEvent.Body.count | Should -Be 3
            $postEvent.Body['eventType'] | Should -Be 'test_event'
            $postEvent.Body.ContainsKey('timestamp') | Should -BeTrue
            $postEvent.Body['category'] | Should -Be 'USER_DEFINED'
        }

        It 'SetCategory should set Body["category"] value' {
            $postEvent = [SFxPostEvent]::new('test_event').SetCategory("AUDIT")

            $postEvent.Body['category'] | Should -Be 'AUDIT'
        }

        It 'SetCategory should set only accept allowed types' {
            $postEvent = [SFxPostEvent]::new('test_event').SetCategory("USER_DEFINED")
            $postEvent.Body['category'] | Should -Be 'USER_DEFINED'

            $postEvent = [SFxPostEvent]::new('test_event').SetCategory("ALERT")
            $postEvent.Body['category'] | Should -Be 'ALERT'

            $postEvent = [SFxPostEvent]::new('test_event').SetCategory("AUDIT")
            $postEvent.Body['category'] | Should -Be 'AUDIT'

            $postEvent = [SFxPostEvent]::new('test_event').SetCategory("JOB")
            $postEvent.Body['category'] | Should -Be 'JOB'

            $postEvent = [SFxPostEvent]::new('test_event').SetCategory("COLLECTED")
            $postEvent.Body['category'] | Should -Be 'COLLECTED'

            $postEvent = [SFxPostEvent]::new('test_event').SetCategory("SERVICE_DISCOVERY")
            $postEvent.Body['category'] | Should -Be 'SERVICE_DISCOVERY'

            $postEvent = [SFxPostEvent]::new('test_event').SetCategory("EXCEPTION")
            $postEvent.Body['category'] | Should -Be 'EXCEPTION'

            { [SFxPostEvent]::new('test_event').SetCategory("NOT_VALID") } | Should -Throw
        }

        It 'AddDimension should add a KV pair to Body["dimensions"]' {
            $postEvent = [SFxPostEvent]::new('test_event').AddDimension('test_key', 'test_value')

            $postEvent.Body['dimensions'].count | Should -Be 1
            $postEvent.Body['dimensions'].ContainsKey('test_key') | Should -BeTrue
            $postEvent.Body['dimensions']['test_key'] | Should -Be 'test_value'
        }

        It 'Multiple AddDimension should add to Body["dimensions"]' {
            $postEvent = [SFxPostEvent]::new('test_event').AddDimension('test_key', 'test_value')

            $postEvent.Body['dimensions'].count | Should -Be 1
            $postEvent.Body['dimensions'].ContainsKey('test_key') | Should -BeTrue
            $postEvent.Body['dimensions']['test_key'] | Should -Be 'test_value'

            $null = $postEvent.AddDimension('test_key2', 'test_value2')

            $postEvent.Body['dimensions'].count | Should -Be 2
            $postEvent.Body['dimensions'].ContainsKey('test_key') | Should -BeTrue
            $postEvent.Body['dimensions']['test_key'] | Should -Be 'test_value'
            $postEvent.Body['dimensions'].ContainsKey('test_key2') | Should -BeTrue
            $postEvent.Body['dimensions']['test_key2'] | Should -Be 'test_value2'
        }

        It 'AddProperty should add a KV pair to Body["properties"]' {
            $postEvent = [SFxPostEvent]::new('test_event').AddProperty('test_key', 'test_value')

            $postEvent.Body['properties'].count | Should -Be 1
            $postEvent.Body['properties'].ContainsKey('test_key') | Should -BeTrue
            $postEvent.Body['properties']['test_key'] | Should -Be 'test_value'

            $results = $postEvent.Invoke()

            $results.Body | Should -BeLike '*"test_key": "test_value"*'

        }

        It 'Multiple AddProperty should add to Body["properties"]' {
            $postEvent = [SFxPostEvent]::new('test_event').AddProperty('test_key', 'test_value')

            $postEvent.Body['properties'].count | Should -Be 1
            $postEvent.Body['properties'].ContainsKey('test_key') | Should -BeTrue
            $postEvent.Body['properties']['test_key'] | Should -Be 'test_value'

            $null = $postEvent.AddProperty('test_key2', 'test_value2')

            $postEvent.Body['properties'].count | Should -Be 2
            $postEvent.Body['properties'].ContainsKey('test_key') | Should -BeTrue
            $postEvent.Body['properties']['test_key'] | Should -Be 'test_value'
            $postEvent.Body['properties'].ContainsKey('test_key2') | Should -BeTrue
            $postEvent.Body['properties']['test_key2'] | Should -Be 'test_value2'

            $results = $postEvent.Invoke()

            $results.Body | Should -BeLike '*"test_key": "test_value"*'
            $results.Body | Should -BeLike '*"test_key2": "test_value2"*'
        }
    }

    Context 'SFxNewAlertMuting' {

        It 'Constructor should format $this.Uri' {
            $queryAlertMuting = [SFxQueryAlertMuting]::new('test_query')
            $queryAlertMuting.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting?query=test_query'
            $queryAlertMuting.Method | Should -Be 'GET'
        }

        It 'OrderBy should add "orderBy" query' {
            $orderBy = [SFxQueryAlertMuting]::new('test_query').OrderBy('test_key')
            $orderBy.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting?query=test_query&orderby=test_key'
        }

        It 'Offset should add "include" query' {
            $include = [SFxQueryAlertMuting]::new('test_query').Include('Open')
            $include.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting?query=test_query&include=Open'
        }

        It 'Offset should add "offset" query' {
            $offset = [SFxQueryAlertMuting]::new('test_query').Offset(1)
            $offset.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting?query=test_query&offset=1'
        }

        It 'Limit should add "limit" query' {
            $limit = [SFxQueryAlertMuting]::new('test_query').Limit(1)
            $limit.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting?query=test_query&limit=1'
        }

        It 'Should chain methods' {
            $chain = [SFxQueryAlertMuting]::new('test_query').OrderBy('test_key').Offset(1).Limit(1)
            $chain.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting?query=test_query&orderby=test_key&offset=1&limit=1'
        }
    }

    Context 'SFxNewAlertMuting' {

        Mock -CommandName Invoke-RestMethod {
            param (
                [string]$Uri,
                [hashtable]$Headers,
                [string]$ContentType,
                [string]$Method,
                [string]$Body
            )

            return $PSBoundParameters
        }

        $DiffMin = 60000
        $DiffHr = 3600000
        $DiffDay = 86400000

        $now = Get-Date

        It 'Constructor should format $this.Uri and set minimum Body values' {
            $postMuting = [SFxNewAlertMuting]::new('test_mute')
            $postMuting.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting'
            $postMuting.Method | Should -Be 'POST'

            $postMuting.Body.count | Should -Be 3
            $postMuting.Body['description'] | Should -Be 'test_mute'
            $postMuting.Body.ContainsKey('startTime') | Should -BeTrue
            $postMuting.Body.ContainsKey('stopTime') | Should -BeTrue
            $postMuting.Body['stopTime'] - $postMuting.Body['startTime'] | Should -Be $DiffHr
            $postMuting.Body.ContainsKey('filters') | Should -BeFalse
        }

        It 'AddFilter should add a KV pair to Body["filters"]' {
            $postMuting = [SFxNewAlertMuting]::new('test_mute').AddFilter('test_key', 'test_value')

            $postMuting.Body['filters'].count | Should -Be 1
            $postMuting.Body['filters'][0].NOT | Should -BeFalse
            $postMuting.Body['filters'][0].property | Should -Be 'test_key'
            $postMuting.Body['filters'][0].propertyValue | Should -Be 'test_value'
        }

        It 'Multiple AddFilter should add to Body["filters"]' {
            $postMuting = [SFxNewAlertMuting]::new('test_mute').AddFilter('test_key', 'test_value')

            $postMuting.Body['filters'].count | Should -Be 1
            $postMuting.Body['filters'][0].NOT | Should -BeFalse
            $postMuting.Body['filters'][0].property | Should -Be 'test_key'
            $postMuting.Body['filters'][0].propertyValue | Should -Be 'test_value'

            $null = $postMuting.AddFilter('test_key2', 'test_value2')

            $postMuting.Body['filters'].count | Should -Be 2
            $postMuting.Body['filters'][0].NOT | Should -BeFalse
            $postMuting.Body['filters'][0].property | Should -Be 'test_key'
            $postMuting.Body['filters'][0].propertyValue | Should -Be 'test_value'
            $postMuting.Body['filters'][1].NOT | Should -BeFalse
            $postMuting.Body['filters'][1].property | Should -Be 'test_key2'
            $postMuting.Body['filters'][1].propertyValue | Should -Be 'test_value2'
        }

        It 'StopTime should accept 1m' {
            $postMuting = [SFxNewAlertMuting]::new('test_mute').SetStartTime($now)
            $postMuting.SetStopTime('1m')

            $postMuting.Body['stopTime'] - $postMuting.Body['startTime'] | Should -Be $DiffMin
        }

        It 'StopTime should accept 1h' {
            $postMuting = [SFxNewAlertMuting]::new('test_mute').SetStartTime($now)
            $postMuting.SetStopTime('1h')

            $postMuting.Body['stopTime'] - $postMuting.Body['startTime'] | Should -Be $DiffHr
        }

        It 'StopTime should accept 1d' {
            $postMuting = [SFxNewAlertMuting]::new('test_mute').SetStartTime($now)
            $postMuting.SetStopTime('1d')

            $postMuting.Body['stopTime'] - $postMuting.Body['startTime'] | Should -Be $DiffDay
        }

        It 'StopTime should throw' {
            $postMuting = [SFxNewAlertMuting]::new('test_mute').SetStartTime($now)
            { $postMuting.SetStopTime('1z') } | Should -Throw
        }
    }

    Context 'Backfill' {

        Mock -CommandName Invoke-RestMethod {
            param (
                [string]$Uri,
                [hashtable]$Headers,
                [string]$ContentType,
                [string]$Method,
                [string]$Body
            )

            return $PSBoundParameters
        }

        $d = get-date -Date 1 -Month 1 -Year 1990 -Hour 12 -Minute 0 -Second 0
        $timestamp = 631213200000

        It 'Constructor should format $this.Uri' {
            $backfill = [SFxBackfill]::new('test_id', 'test_name')
            $backfill.Uri | Should -Be 'https://backfill.us1.signalfx.com/v1/backfill?orgid=test_id&metric=test_name'
            $backfill.Method | Should -Be 'POST'
        }

        It 'SetMetricType should add "metric_type" query' {
            $backfill = [SFxBackfill]::new('test_id', 'test_name').SetMetricType("gauge")
            $backfill.Uri | Should -Be 'https://backfill.us1.signalfx.com/v1/backfill?orgid=test_id&metric=test_name&metric_type=gauge'
        }

        It 'AddDimension should add "sfxdim_<name>" query' {
            $backfill = [SFxBackfill]::new('test_id', 'test_name').SetMetricType("gauge").AddDimension("test_name","astring")
            $backfill.Uri | Should -Be 'https://backfill.us1.signalfx.com/v1/backfill?orgid=test_id&metric=test_name&metric_type=gauge&sfxdim_test_name=astring'
        }

        It 'AddValue should add JSON object stream to Body' {
            $backfill = [SFxBackfill]::new('test_id', 'test_name').SetMetricType("gauge").AddDimension("test_name","astring")

            $backfill.AddValue($timestamp, 1)

            $backfill.Body.ToString() | Should -Be '{"timestamp":631213200000,"value":1} '
        }

        It 'JSON object stream should be whitespace delimited' {
            $backfill = [SFxBackfill]::new('test_id', 'test_name').SetMetricType("gauge").AddDimension("test_name","astring")

            $backfill.AddValue($timestamp, 1)
            $backfill.AddValue(($timestamp+1000), 2)

            $backfill.Body.ToString() | Should -Be '{"timestamp":631213200000,"value":1} {"timestamp":631213201000,"value":2} '
        }

        It 'AddValue should be fast for 360 entries' {
            $backfill = [SFxBackfill]::new('test_id', 'test_name').SetMetricType("gauge").AddDimension("test_name","astring")

            $timer = [System.Diagnostics.Stopwatch]::new()
            $timer.Start()
            for ($i = 0; $i -lt 360; $i++) {
                $backfill.AddValue(($timestamp+$i*1000), ($i+1))
            }
            $timer.Stop()

            $backfill.Body.Length | Should -BeGreaterThan 13320
            # This typically runs in 10ms on a workstation, but cane take more an a CI agent
            $timer.ElapsedMilliseconds | Should -BeLessThan 50
        }

    }
}
