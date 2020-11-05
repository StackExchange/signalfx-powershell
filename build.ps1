#Requires -Module @{ ModuleName = 'Requirements'; RequiredVersion = '2.3.6' }

$build = & {
    New-RequirementGroup -NameSpace "Build" -ScriptBlock {
        @{
            Describe = "Clean"
            Test     = { $false -eq (Test-Path "$PSScriptRoot\release") }
            Set      = { Remove-Item "$PSScriptRoot\release" -Recurse -Force }
        }
        @{
            Describe = "Build"
            Test     = { Test-Path "$PSScriptRoot\release\signalfx" }
            Set      = {
                $manifestTemplate = Import-PowerShellDataFile -Path "$PSScriptRoot\src\signalfx-powershell.psd1"
                New-Item -Name release -Path $PSScriptRoot -ItemType Directory
                New-Item -Name signalfx -Path "$PSScriptRoot\release\" -ItemType Directory

                Get-Content -Path "$PSScriptRoot\src\classes.clients.ps1" -Raw | Set-Content -Path "$PSScriptRoot\release\signalfx\signalfx.psm1" -Force
                Get-ChildItem -Path "$PSScriptRoot\src\" -filter "classes*" | Where-Object Name -ne 'classes.clients.ps1' | ForEach-Object {
                    Get-Content -Path $_.FullName -Raw | Add-Content -Path "$PSScriptRoot\release\signalfx\signalfx.psm1"
                }

                Get-ChildItem -Path "$PSScriptRoot\src\" -filter "*.ps1" | Where-Object Name -notlike 'classes.*.ps1' | ForEach-Object {
                    Get-Content -Path $_.FullName -Raw | Add-Content -Path "$PSScriptRoot\release\signalfx\signalfx.psm1"
                }


                $moduleParams = @{
                    GUID                     = $manifestTemplate.GUID
                    ModuleVersion            = $manifestTemplate.ModuleVersion
                    Author                   = $manifestTemplate.Author
                    Description              = $manifestTemplate.Description
                    Copyright                = $manifestTemplate.Copyright
                    CompanyName              = $manifestTemplate.CompanyName
                    RootModule               = "signalfx.psm1"
                    FunctionsToExport        = $manifestTemplate.FunctionsToExport
                    CmdletsToExport          = ''
                    VariablesToExport        = ''
                    AliasesToExport          = ''
                    RequireLicenseAcceptance = $manifestTemplate.PrivateData.PSData.RequireLicenseAcceptance
                    ProjectUri               = $manifestTemplate.PrivateData.PSData.ProjectUri
                    LicenseUri               = $manifestTemplate.PrivateData.PSData.LicenseUri
                    Tags                     = @('signalfx', 'api')
                }
                New-ModuleManifest -Path "$PSScriptRoot\release\signalfx\signalfx.psd1" @moduleParams
            }
        }
    }
    New-RequirementGroup -NameSpace "Test" -ScriptBlock {
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
        @{
            Describe = "Invoke-Pester"
            Test     = {
                Write-Host ''
                $results = Invoke-Pester -Path "$PSScriptRoot\tests" -Show Failed,Summary -PassThru
                $results.FailedCount -eq 0
            }
        }
    }
}
$build | Invoke-Requirement | Format-Checklist