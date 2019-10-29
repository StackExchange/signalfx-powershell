Describe "New-SFxSessionToken" {

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
    }

    Context 'With Credential' {

        Mock -CommandName Select-Object {
            Write-Output 'Test_Token'
        }

        It 'Should create properly formated Body' {
            $password = ConvertTo-SecureString -String 'TestPass' -AsPlainText -Force
            $cred = New-Object pscredential -ArgumentList 'TestUser', $password

            $request = New-SFxSessionToken -Credential $cred
            $request.Body | Should -Match '"email": "TestUser"'
            $request.Body | Should -Match '"password": "TestPass"'
        }
    }
}