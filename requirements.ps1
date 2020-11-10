#Requires -Module @{ ModuleName = 'Requirements'; RequiredVersion = '2.3.6' }

& {
    New-RequirementGroup -NameSpace "Pester" -ScriptBlock {
        @{
            Describe = "Get Pester Module"
            Test     = {
                $loadedModule = Get-Module -Name Pester -ListAvailable
                $loadedModule.Version -contains [version]"4.10.1"
            }
            Set      = {
                Install-Module -Name Pester -RequiredVersion 4.10.1 -Force
            }
        }
        @{
            Describe = "Load Pester Module"
            Test     = {
                $loadedModule = Get-Module -Name Pester
                $loadedModule.Version -eq [version]"4.10.1" -and $loadedModule.Count -eq 1
            }
            Set      = {
                Remove-Module -Name Pester -ErrorAction SilentlyContinue
                Import-Module -Name Pester -RequiredVersion 4.10.1
            }
        }
    }
} | Invoke-Requirement | Format-Checklist