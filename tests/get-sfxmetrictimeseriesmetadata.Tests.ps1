Describe "Get-SFxMetricTimeSeriesMetaData" {

    Import-Module "$PSScriptRoot\..\src\signalfx-powershell.psd1"

    InModuleScope -ModuleName 'signalfx-powershell' {

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

        Context "By Key-Value" {

            It "Uses SFxGetMetricTimeSeries when given Id parameter" {
                $parameterCollection = Get-SFxMetricTimeSeriesMetadata test_id

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/MetricTimeSeries/test_id'
                $parameterCollection.Method | Should -Be 'GET'
            }
        }

        Context "By Query" {

            It "Uses SFxQueryMetricTimeSeries when given Query parameter" {
                $parameterCollection = Get-SFxMetricTimeSeriesMetadata -Query test_query

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/MetricTimeSeries?query=test_query'
                $parameterCollection.Method | Should -Be 'GET'
            }
        }

        Context 'By Query with Parameters' {

            It "SFxQueryMetricTimeSeries with Offset" {
                $parameterCollection = Get-SFxMetricTimeSeriesMetadata -Query test_query -Offset 1

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/MetricTimeSeries?query=test_query&offset=1'
            }

            It "SFxQueryMetricTimeSeries with Limit" {
                $parameterCollection = Get-SFxMetricTimeSeriesMetadata -Query test_query -Limit 1

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/MetricTimeSeries?query=test_query&limit=1'
            }
        }

        Context 'Set Token' {

            It "Should set User Token with Id" {
                $parameterCollection = Get-SFxMetricTimeSeriesMetadata -Key test_id -ApiToken test_token

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/MetricTimeSeries/test_id'
                $parameterCollection.Headers.ContainsKey('X-SF-TOKEN') | Should -BeTrue
                $parameterCollection.Headers['X-SF-TOKEN'] | Should -Be test_token
                $parameterCollection.ContentType | Should -Be 'application/json'
            }

            It "Should set User Token with Query" {
                $parameterCollection = Get-SFxMetricTimeSeriesMetadata -Query test_query -ApiToken test_token

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/MetricTimeSeries?query=test_query'
                $parameterCollection.Headers.ContainsKey('X-SF-TOKEN') | Should -BeTrue
                $parameterCollection.Headers['X-SF-TOKEN'] | Should -Be test_token
                $parameterCollection.ContentType | Should -Be 'application/json'
            }
        }
    }

    Remove-Module signalfx-powershell
}
