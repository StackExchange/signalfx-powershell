Describe "New-SFxMember" {

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

        Context 'With Parameters' {
            It 'Should create properly formated Body (non-Admin)' {
                $request = New-SFxMember -Email test@test -FullName 'Test Name' -Title 'Junior Architect I' -Phone '123-456-7890'
                $request.Body | Should -Match '"email": "test@test"'
                $request.Body | Should -Match '"fullName": "Test Name"'
                $request.Body | Should -Match '"title": "Junior Architect I"'
                $request.Body | Should -Match '"phone": "123-456-7890"'
                $request.Body | Should -Match '"admin": "false"'
            }

            It 'Should create properly formated Body (Admin)' {
                $request = New-SFxMember -Email test@test -FullName 'Test Name' -Title 'Junior Architect I' -Phone '123-456-7890' -Admin
                $request.Body | Should -Match '"email": "test@test"'
                $request.Body | Should -Match '"fullName": "Test Name"'
                $request.Body | Should -Match '"title": "Junior Architect I"'
                $request.Body | Should -Match '"phone": "123-456-7890"'
                $request.Body | Should -Match '"admin": "true"'
            }
        }

        Context 'With Pipeline' {
            It 'Should create properly formated Body (non-Admin)' {
                $objects = [PSCustomObject]@{
                    Email = 'test@test'
                    FullName = 'Test Name'
                    Title = 'Junior Architect I'
                    Phone = '123-456-7890'
                }

                $request = $objects | New-SFxMember
                $request.Body | Should -Match '"email": "test@test"'
                $request.Body | Should -Match '"fullName": "Test Name"'
                $request.Body | Should -Match '"title": "Junior Architect I"'
                $request.Body | Should -Match '"phone": "123-456-7890"'
                $request.Body | Should -Match '"admin": "false"'
            }

            It 'Should create properly formated Body with only Email' {
                $objects = [PSCustomObject]@{
                    Email = 'test@test'
                }

                $request = $objects | New-SFxMember
                $request.Body | Should -Match '"email": "test@test"'
                $request.Body | Should -Match '"fullName": ""'
                $request.Body | Should -Match '"title": ""'
                $request.Body | Should -Match '"phone": ""'
                $request.Body | Should -Match '"admin": "false"'
            }

            It 'Should create properly formated Body (Admin)' {
                $objects = [PSCustomObject]@{
                    Email = 'test@test'
                    FullName = 'Test Name'
                    Title = 'Junior Architect I'
                    Phone = '123-456-7890'
                    Admin = $true
                }
                $request = $objects | New-SFxMember
                $request.Body | Should -Match '"email": "test@test"'
                $request.Body | Should -Match '"fullName": "Test Name"'
                $request.Body | Should -Match '"title": "Junior Architect I"'
                $request.Body | Should -Match '"phone": "123-456-7890"'
                $request.Body | Should -Match '"admin": "true"'
            }

            It 'Should accept multiple pipeline objects' {
                $objects =@([PSCustomObject]@{Email = 'test@test'}, [PSCustomObject]@{Email = 'test2@test2'})

                $request = $objects | New-SFxMember
                $request.Count | Should -Be 2
                $request[0].Body | Should -Match '"email": "test@test"'
                $request[0].Body | Should -Match '"fullName": ""'
                $request[0].Body | Should -Match '"title": ""'
                $request[0].Body | Should -Match '"phone": ""'
                $request[0].Body | Should -Match '"admin": "false"'
                $request[1].Body | Should -Match '"email": "test2@test2"'
                $request[1].Body | Should -Match '"fullName": ""'
                $request[1].Body | Should -Match '"title": ""'
                $request[1].Body | Should -Match '"phone": ""'
                $request[1].Body | Should -Match '"admin": "false"'
            }
        }
    }
}