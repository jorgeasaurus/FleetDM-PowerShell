BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '../FleetDM-PowerShell.psd1'
    Import-Module $modulePath -Force
    InModuleScope FleetDM-PowerShell {
        $script:FleetDMConnection = @{
            BaseUri = 'https://test.fleetdm.example.com'
            Headers = @{ Authorization = 'Bearer test-token' }
            Version = '4.67.0'
        }
        $script:FleetDMWebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    }
}

Describe 'New-FleetUser' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Body)
            return @{
                Endpoint = $Endpoint
                Method = $Method
                Body = $Body
                user = [PSCustomObject]@{
                    id = 4
                    name = $Body.name
                    email = $Body.email
                    api_only = $Body.api_only
                    global_role = $Body.global_role
                }
                token = 'api-token'
            }
        }
    }

    It 'creates an API-only global admin and returns the token' {
        $password = ConvertTo-SecureString 'example-password' -AsPlainText -Force
        $user = New-FleetUser -Name 'module-test' -Email 'api@example.com' -Password $password -ApiOnly -GlobalRole admin -Confirm:$false

        $user.name | Should -Be 'module-test'
        $user.email | Should -Be 'api@example.com'
        $user.Token | Should -Be 'api-token'
        $user.PSObject.TypeNames | Should -Contain 'FleetDM.User'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'users/admin' -and
            $Method -eq 'POST' -and
            $Body.name -eq 'module-test' -and
            $Body.email -eq 'api@example.com' -and
            $Body.password -eq 'example-password' -and
            $Body.api_only -eq $true -and
            $Body.admin_forced_password_reset -eq $false -and
            $Body.global_role -eq 'admin'
        }
    }
}
