Describe "Get-SFxDimensionMetaData" {

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

            It "Uses SFxGetDimension when given Key and Value parameters" {
                $parameterCollection = Get-SFxDimensionMetadata test_key test_value

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension/test_key/test_value'
                $parameterCollection.Method | Should -Be 'GET'
            }
        }

        Context "By Query" {

            It "Uses SFxQueryDimension when given Query parameter" {
                $parameterCollection = Get-SFxDimensionMetadata -Query test_query

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension?query=test_query'
                $parameterCollection.Method | Should -Be 'GET'
            }
        }

        Context 'By Query with JParameters' {
            It "SFxQueryDimension with OrderBy" {
                $parameterCollection = Get-SFxDimensionMetadata -Query test_query -OrderBy test_value

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension?query=test_query&orderBy=test_value'
            }

            It "SFxQueryDimension with Offset" {
                $parameterCollection = Get-SFxDimensionMetadata -Query test_query -Offset 1

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension?query=test_query&offset=1'
            }

            It "SFxQueryDimension with Limit" {
                $parameterCollection = Get-SFxDimensionMetadata -Query test_query -Limit 1

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension?query=test_query&limit=1'
            }
        }

        Context 'Set Token' {

            It "Should set User Token with KV" {
                $parameterCollection = Get-SFxDimensionMetadata -Key test_key -Value test_value -ApiToken test_token

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension/test_key/test_value'
                $parameterCollection.Headers.ContainsKey('X-SF-TOKEN') | Should -BeTrue
                $parameterCollection.Headers['X-SF-TOKEN'] | Should -Be test_token
                $parameterCollection.ContentType | Should -Be 'application/json'
            }

            It "Should set User Token with Query" {
                $parameterCollection = Get-SFxDimensionMetadata -Query test_query -ApiToken test_token

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/dimension?query=test_query'
                $parameterCollection.Headers.ContainsKey('X-SF-TOKEN') | Should -BeTrue
                $parameterCollection.Headers['X-SF-TOKEN'] | Should -Be test_token
                $parameterCollection.ContentType | Should -Be 'application/json'
            }
        }
    }

    Remove-Module signalfx-powershell
}
