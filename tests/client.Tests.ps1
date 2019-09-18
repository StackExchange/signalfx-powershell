Describe "client" {

    . "$PSScriptRoot/../src/client.ps1"

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
}