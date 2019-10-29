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

            $PSBoundParameters.Add('accessToken', 'test_token')
            return $PSBoundParameters
        }
    }

    Context 'With Credential' {

        It 'Should create properly formated Body' -Skip {
            $password = ConvertTo-SecureString -String 'TestPass' -AsPlainText -Force
            $cred = New-Object pscredential -ArgumentList 'TestUser', $password

            $request = New-SFxSessionToken -Credential $cred
            $request.Body | Should -Match '"email": "TestUser"'
            $request.Body | Should -Match '"password": "TestPass"'
        }
    }
}