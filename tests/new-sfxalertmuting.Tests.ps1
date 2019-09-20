Describe "New-SFxAlertMuting" {

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

        Context 'With defaults' {

            It "Uses SFxQueryDimension when given Query parameter" {
                $request = New-SFxAlertMuting -Description test_mute

                $request.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting'
                $request.Method | Should -Be 'POST'
                $request.Body | Should -Match '"description": "test_mute"'
                $request.Body | Should -Match '"startTime": \d{13}'
                $request.Body | Should -Match '"stopTime": \d{13}'
            }
        }

        Context 'Paramters' {

            It 'Should set Filter' {
                $request = New-SFxAlertMuting -Description test_mute -Filter @{'test_key'='test_value'}

                $request.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting'
                $request.Body | Should -Match '"test_key": "test_value"'
            }

            $testDate = Get-Date '2022-01-02 03:04:05-0:00'
            $testUnixStartTimeValue = 1641092645000
            $testUnixEndTimeValue = 1641092705000

            It 'Should set StartTime' {
                $request = New-SFxAlertMuting -Description test_mute -StartTime $testDate

                $request.Body | Should -Match "`"startTime`": $testUnixStartTimeValue"
            }

            It 'Should set stopTime via Duration' {
                $request = New-SFxAlertMuting -Description test_mute -StartTime $testDate -Duration 1m

                $request.Body | Should -Match "`"stopTime`": $testUnixEndTimeValue"
            }

            It 'Should Throw with a StartTime in the past' {
                {New-SFxAlertMuting -Description test_mute -StartTime (Get-Date).AddDays(-1) } | Should -Throw
            }

            It 'Should Throw with back Duration string' {
                {New-SFxAlertMuting -Description test_mute -Duration 1Z} | Should -Throw
            }
        }

        Context 'Set Token' {

            It "Should set User Token" {
                $request = New-SFxAlertMuting -Description test_mute -ApiToken test_token

                $request.Uri | Should -Be 'https://api.us1.signalfx.com/v2/alertmuting'
                $request.Headers.ContainsKey('X-SF-TOKEN') | Should -BeTrue
                $request.Headers['X-SF-TOKEN'] | Should -Be test_token
                $request.ContentType | Should -Be 'application/json'
            }
        }
    }

    Remove-Module signalfx-powershell
}

