Describe "Get-SFxAlertMuting" {

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

        Context "By ID" {

            It "Uses SFxGetDimension when given Id" {

            }
        }

        Context "By Query" {

            It "Uses SFxQueryDimension when given Query parameter" {
                $parameterCollection = Get-SFxAlertMuting -Query test_query

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting?query=test_query'
                $parameterCollection.Method | Should -Be 'GET'
            }
        }

        Context 'By Query with Parameters' {
            It "SFxQueryDimension with Include" {
                $parameterCollection = Get-SFxAlertMuting -Query test_query -Include 'All'

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting?query=test_query&include=All'
            }

            It "SFxQueryDimension with OrderBy" {
                $parameterCollection = Get-SFxAlertMuting -Query test_query -OrderBy test_value

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting?query=test_query&orderBy=test_value'
            }

            It "SFxQueryDimension with Offset" {
                $parameterCollection = Get-SFxAlertMuting -Query test_query -Offset 1

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting?query=test_query&offset=1'
            }

            It "SFxQueryDimension with Limit" {
                $parameterCollection = Get-SFxAlertMuting -Query test_query -Limit 1

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting?query=test_query&limit=1'
            }
        }

        Context 'Set Token' {

            It "Should set User Token with Id" {

            }

            It "Should set User Token with Query" {
                $parameterCollection = Get-SFxAlertMuting -Query test_query -ApiToken test_token

                $parameterCollection.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting?query=test_query'
                $parameterCollection.Headers.ContainsKey('X-SF-TOKEN') | Should -BeTrue
                $parameterCollection.Headers['X-SF-TOKEN'] | Should -Be test_token
                $parameterCollection.ContentType | Should -Be 'application/json'
            }
        }
    }

    Remove-Module signalfx-powershell
}
