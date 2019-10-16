Describe "Publish-SFxMetricBackfill" {

    Import-Module "$PSScriptRoot\..\src\signalfx-powershell.psd1" -Force

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

        Context 'With DateTime input objects' {

            $d = Get-Date -Day 15 -Month 10 -Year 2019 -Hour 15 -Minute 0 -Second 0 -Millisecond 1
            $timestamp = 1571166000001
            $data = for ($i = 0; $i -lt 360; $i++) {
                [PSCustomObject]@{TimeStamp=($d.AddMilliseconds($i*10000).ToUniversalTime()); Value=$i+1}
            }

            It 'Should create a valid QueryString' {
                $results = $data | Publish-SFxMetricBackfill -OrgId A-BC1 -Name test_name -Type counter -Dimension test_dimension

                $results.Uri | Should -Be 'https://backfill.us1.signalfx.com/v1/backfill?orgid=A-BC1&metric=test_name&metric_type=counter&sfxdim_test_dimension'
            }

            It 'Should pass Unix timestamp values' {

                $results = $data |
                    Select-Object -first 1 |
                    Publish-SFxMetricBackfill -OrgId A-BC1 -Name test_name -Type counter -Dimension test_dimension

                $object = $results.Body | ConvertFrom-Json
                $object.TimeStamp | Should -Be $timestamp
            }
        }

        Context 'With Unix timestamp input objects' {

            $d = Get-Date -Day 15 -Month 10 -Year 2019 -Hour 15 -Minute 0 -Second 0 -Millisecond 1
            $timestamp = 1571166000001
            $data = for ($i = 0; $i -lt 360; $i++) {
                [PSCustomObject]@{TimeStamp=([DateTimeOffset]::new($d.AddMilliseconds($i*10000).ToUniversalTime()).ToUnixTimeMilliseconds()); Value=$i+1}
            }

            It 'Should pass Unix timestamp values' {

                $results = $data |
                    Select-Object -first 1 |
                    Publish-SFxMetricBackfill -OrgId A-BC1 -Name test_name -Type counter -Dimension test_dimension

                $object = $results.Body | ConvertFrom-Json
                $object.TimeStamp | Should -Be $timestamp
            }
        }
    }

    Remove-Module signalfx-powershell
}