Describe "Add-SFxMetricData" {

    Import-Module "$PSScriptRoot\..\src\signalfx-powershell.psd1" -Force

    InModuleScope -ModuleName 'signalfx-powershell' {

        Context 'Add a metric without Dimensions' {

            It 'Should add a value to object from Pipeline' {
                $testmetric = New-SfxMetric -Type Gauge -Metric test.metric
                $it = $testmetric | Add-SfxMetricData 1

                $it.Data | Should -HaveCount 1
                $it.Data.metric | Should -Be 'test.metric'
                $it.Data.timestamp | Should -BeGreaterThan 1583351218758
                $it.Data.dimensions | Should -BeNullOrEmpty
                $it.Data.value | Should -Be 1
            }

            It 'Should add a value to object as Parameter' {
                $testmetric = New-SfxMetric -Type Gauge -Metric test.metric
                $it = Add-SfxMetricData -InputObject $testmetric -Value 2

                $it.Data | Should -HaveCount 1
                $it.Data.metric | Should -Be 'test.metric'
                $it.Data.timestamp | Should -BeGreaterThan 1583351218758
                $it.Data.dimensions | Should -BeNullOrEmpty
                $it.Data.value | Should -Be 2
            }

            It 'Should add multiple recordings' {
                $testmetric = New-SfxMetric -Type Gauge -Metric test.metric
                $it = $testmetric | Add-SfxMetricData 1 | Add-SfxMetricData 2

                $it.Data | Should -HaveCount 2
                $it.Data[0].metric | Should -Be 'test.metric'
                $it.Data[0].timestamp | Should -BeGreaterThan 1583351218758
                $it.Data[0].dimensions | Should -BeNullOrEmpty
                $it.Data[0].value | Should -Be 1

                $it.Data[1].metric | Should -Be 'test.metric'
                $it.Data[1].timestamp | Should -BeGreaterOrEqual $it.Data[0].timestamp
                $it.Data[1].dimensions | Should -BeNullOrEmpty
                $it.Data[1].value | Should -Be 2
            }
        }

        Context 'Add a metric with Dimensions' {

            It 'Should add a value to object from Pipeline' {
                $testmetric = New-SfxMetric -Type Gauge -Metric test.metric
                $it = $testmetric | Add-SfxMetricData -Value 1 -Dimension @{host='test_host'}

                $it.Data | Should -HaveCount 1
                $it.Data.metric | Should -Be 'test.metric'
                $it.Data.timestamp | Should -BeGreaterThan 1583351218758
                $it.Data.dimensions | Should -HaveCount 1
                $it.Data.dimensions['host'] | Should -Be 'test_host'
                $it.Data.value | Should -Be 1
            }

            It 'Should add multiple recordings with different dimensions' {
                $testmetric = New-SfxMetric -Type Gauge -Metric test.metric
                $it = $testmetric | Add-SfxMetricData 1 @{host='test_host'} | Add-SfxMetricData 2 @{host='test_host2'}

                $it.Data | Should -HaveCount 2
                $it.Data[0].metric | Should -Be 'test.metric'
                $it.Data[0].timestamp | Should -BeGreaterThan 1583351218758
                $it.Data[0].dimensions | Should -HaveCount 1
                $it.Data[0].dimensions['host'] | Should -Be 'test_host'
                $it.Data[0].value | Should -Be 1

                $it.Data[1].metric | Should -Be 'test.metric'
                $it.Data[1].timestamp | Should -BeGreaterOrEqual $it.Data[0].timestamp
                $it.Data[1].dimensions | Should -HaveCount 1
                $it.Data[1].dimensions['host'] | Should -Be 'test_host2'
                $it.Data[1].value | Should -Be 2
            }
        }
    }

    Remove-Module signalfx-powershell
}