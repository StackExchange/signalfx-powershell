Describe "New-SFxMetric" {

    Import-Module "$PSScriptRoot\..\src\signalfx-powershell.psd1" -Force

    InModuleScope -ModuleName 'signalfx-powershell' {

        Context 'Basic Gauge' {
            $it = New-SfxMetric -Type Gauge -Metric test.metric

            It 'Should return a SfxPostDataPoint object' {
                $it.GetType().Name | Should -Be 'SfxPostDataPoint'
                $it.Type | Should -Be 'Gauge'
                $it.Metric | Should -Be 'test.metric'
                $it.Dimensions.Count | Should -Be 0
            }
        }

        Context 'Counter with Parameters' {
            $it = New-SfxMetric -Type Counter -Metric test.metric -Dimension @{host='test_host'}

            It 'Should have additional properties' {
                $it.GetType().Name | Should -Be 'SfxPostDataPoint'
                $it.Type | Should -Be 'Counter'
                $it.Metric | Should -Be 'test.metric'
                $it.Dimensions.Count | Should -Be 1
                $it.Dimensions['host'] | Should -Be 'test_host'
            }
        }
    }

    Remove-Module signalfx-powershell
}