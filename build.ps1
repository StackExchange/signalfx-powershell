[CmdletBinding()]
param (
    [switch]$Clean,
    [switch]$Build,
    [switch]$Test,
    [switch]$CI,
    [switch]$Bootstrap
)

function Bootstrap {
    Write-Host "`n`r--- Bootstrap ---"
    & "$PSScriptRoot\requirements.ps1"
}

function Clean {
    Write-Host "`n`r--- Clean ---"
    if (Test-Path "$PSScriptRoot\release") {
        Remove-Item "$PSScriptRoot\release" -Recurse -Force
    }
}

function Build {
    Write-Host "`n`r--- Build ---"
    $manifestTemplate = Import-PowerShellDataFile -Path "$PSScriptRoot\src\signalfx-powershell.psd1"
    New-Item -Name release -Path $PSScriptRoot -ItemType Directory | Out-Null
    New-Item -Name signalfx -Path "$PSScriptRoot\release\" -ItemType Directory | Out-Null

    Write-Host "`n`r--- Build Module ---"
    Get-Content -Path "$PSScriptRoot\src\classes.clients.ps1" -Raw | Set-Content -Path "$PSScriptRoot\release\signalfx\signalfx.psm1" -Force
    Get-ChildItem -Path "$PSScriptRoot\src\" -filter "classes*" | Where-Object Name -ne 'classes.clients.ps1' | ForEach-Object {
        Get-Content -Path $_.FullName -Raw | Add-Content -Path "$PSScriptRoot\release\signalfx\signalfx.psm1"
    }
    Get-Item "$PSScriptRoot\release\signalfx\signalfx.psm1" | Select-Object -Property Name, Length, LastWriteTime | Out-String

    Get-ChildItem -Path "$PSScriptRoot\src\" -filter "*.ps1" | Where-Object Name -notlike 'classes.*.ps1' | ForEach-Object {
        Get-Content -Path $_.FullName -Raw | Add-Content -Path "$PSScriptRoot\release\signalfx\signalfx.psm1"
    }

    Write-Host "`n`r--- Build Manifest ---"
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

    Get-Item "$PSScriptRoot\release\signalfx\signalfx.psd1" | Select-Object -Property Name, Length, LastWriteTime | Out-String
}

function Test {
    param (
        [switch]$EnableExit
    )
    Write-Host "`n`r--- Test ---"
    Invoke-Pester -Path "$PSScriptRoot\tests" -Show Failed,Summary -EnableExit:$EnableExit
}

if ($Bootstrap) {
    Bootstrap
}

if ($Build) {
    if ($Clean) {
        Clean
    }
    Build
}

if ($Test) {
    Test -EnableExit:$CI
}