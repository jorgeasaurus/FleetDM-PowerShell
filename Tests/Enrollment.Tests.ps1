BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '../FleetDM-PowerShell.psd1'
    Import-Module $modulePath -Force
    InModuleScope FleetDM-PowerShell {
        $script:FleetDMConnection = @{
            BaseUri = 'https://test.fleetdm.example.com'
            Headers = @{ Authorization = 'Bearer test-token' }
            Version = '4.96.0'
        }
        $script:FleetDMWebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    }
    $script:TestRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("fleet-enroll-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $script:TestRoot | Out-Null
    $script:VppFile = Join-Path $script:TestRoot 'sToken_for_Acme.vpptoken'
    $script:DepProfile = Join-Path $script:TestRoot 'dep_profile.json'
    $script:BadJson = Join-Path $script:TestRoot 'bad.json'
    $script:ArrayJson = Join-Path $script:TestRoot 'array.json'
    $script:KeyFile = Join-Path $script:TestRoot 'key.json'
    [System.IO.File]::WriteAllText($script:VppFile, 'vpp-token-secret-data')
    [System.IO.File]::WriteAllText($script:DepProfile, "$([char]0xFEFF){`"is_mandatory`":true,`"skip_setup_items`":[`"Location`"]}", [System.Text.UTF8Encoding]::new($true))
    [System.IO.File]::WriteAllText($script:BadJson, '{ not json')
    [System.IO.File]::WriteAllText($script:ArrayJson, '[1,2]')
    [System.IO.File]::WriteAllText($script:KeyFile, '{"type":"service_account","private_key_id":"kid-1","private_key":"-----BEGIN PRIVATE KEY-----\nPK-SECRET-VALUE\n-----END PRIVATE KEY-----\n","client_email":"sa@example.iam.gserviceaccount.com"}')
    $script:Tenant = 'fec37e96-3615-4e37-8fac-445d5328af3c'
    $script:Client = '8c8e3fd4-9b2c-4d3e-8f10-2233445566aa'
}

AfterAll {
    Remove-Item -LiteralPath $script:TestRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Describe 'Apple Business and VPP tokens' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Form, $Body)
            switch -Regex ($Endpoint) {
                '^ab_tokens$' { return [PSCustomObject]@{ ab_tokens = @([PSCustomObject]@{ id = 1; org_name = 'Acme' }); abm_tokens = @([PSCustomObject]@{ id = 1; org_name = 'Acme' }) } }
                '^vpp_tokens$' {
                    if ($Method -eq 'POST') { return [PSCustomObject]@{ token = [PSCustomObject]@{ id = 4; org_name = 'Acme'; fleets = $null } } }
                    return [PSCustomObject]@{ vpp_tokens = @([PSCustomObject]@{ id = 4; org_name = 'Acme' }) }
                }
                '^vpp_tokens/\d+/fleets$' { return [PSCustomObject]@{ token = [PSCustomObject]@{ id = 4; fleets = @() } } }
            }
        }
    }

    It 'lists AB tokens from ab_tokens without duplicates' {
        $tokens = @(Get-FleetAppleBusinessToken)
        $tokens.Count | Should -Be 1
        $tokens[0].PSObject.TypeNames | Should -Contain 'FleetDM.AppleBusinessToken'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter { $Endpoint -eq 'ab_tokens' -and $Method -eq 'GET' }
    }

    It 'falls back to abm_tokens on an older server' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell { return [PSCustomObject]@{ abm_tokens = @([PSCustomObject]@{ id = 2; org_name = 'Old' }) } }
        (@(Get-FleetAppleBusinessToken))[0].org_name | Should -Be 'Old'
    }

    It 'lists VPP tokens and uploads one as a multipart token file' {
        (@(Get-FleetVppToken))[0].PSObject.TypeNames | Should -Contain 'FleetDM.VppToken'
        $added = Add-FleetVppToken -Path $script:VppFile -Confirm:$false
        $added.id | Should -Be 4
        $added.PSObject.TypeNames | Should -Contain 'FleetDM.VppToken'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'vpp_tokens' -and $Method -eq 'POST' -and $Form.token.FileName -eq 'sToken_for_Acme.vpptoken' -and
            [System.Text.Encoding]::UTF8.GetString($Form.token.Bytes) -eq 'vpp-token-secret-data'
        }
    }

    It 'assigns specific fleets, all fleets, or none' {
        $updated = Add-FleetVppToken -Path $script:VppFile -Confirm:$false | Set-FleetVppTokenFleet -FleetId 1, 2, 2, 0 -Confirm:$false
        $updated.PSObject.TypeNames | Should -Contain 'FleetDM.VppToken'
        Set-FleetVppTokenFleet -Id 4 -AllFleets -Confirm:$false | Out-Null
        Set-FleetVppTokenFleet -Id 4 -NoFleet -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'vpp_tokens/4/fleets' -and $Method -eq 'PATCH' -and (@($Body.fleets) -join ',') -eq '1,2,0'
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Body -and $Body.ContainsKey('fleets') -and $Body.fleets -is [array] -and $Body.fleets.Count -eq 0
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Body -and $Body.ContainsKey('fleets') -and $null -eq $Body.fleets
        }
    }

    It 'rejects an empty fleet list instead of assigning every fleet' {
        { Set-FleetVppTokenFleet -Id 4 -FleetId @() -Confirm:$false } | Should -Throw '*Pass -AllFleets*'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'sends nothing with -WhatIf' {
        Add-FleetVppToken -Path $script:VppFile -WhatIf
        Set-FleetVppTokenFleet -Id 4 -FleetId 1 -WhatIf
        Set-FleetVppTokenFleet -Id 4 -NoFleet -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }
}

Describe 'VPP fleet assignment on the wire' -Tag 'Unit' {
    It 'sends fleets as [] for all fleets and null for none on the wire' {
        InModuleScope FleetDM-PowerShell {
            $script:wireBodies = @()
            Mock Invoke-RestMethod {
                $script:wireBodies += $Body
                return [PSCustomObject]@{ token = [PSCustomObject]@{ id = 4 } }
            }
            Set-FleetVppTokenFleet -Id 4 -AllFleets -Confirm:$false | Out-Null
            Set-FleetVppTokenFleet -Id 4 -NoFleet -Confirm:$false | Out-Null
            Set-FleetVppTokenFleet -Id 4 -FleetId 3 -Confirm:$false | Out-Null
            $script:wireBodies[0] | Should -BeExactly '{"fleets":[]}'
            $script:wireBodies[1] | Should -BeExactly '{"fleets":null}'
            $script:wireBodies[2] | Should -BeExactly '{"fleets":[3]}'
        }
    }
}

Describe 'Automatic enrollment profiles' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Body, $QueryParameters)
            return [PSCustomObject]@{ fleet_id = 2; name = 'dep_profile.json'; enrollment_profile = [PSCustomObject]@{ is_mandatory = $true } }
        }
    }

    It 'gets a fleet profile, the unassigned profile, and the default profile' {
        (Get-FleetEnrollmentProfile -FleetId 2).PSObject.TypeNames | Should -Contain 'FleetDM.EnrollmentProfile'
        Get-FleetEnrollmentProfile | Out-Null
        Get-FleetEnrollmentProfile -Default | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'enrollment_profiles/automatic' -and $QueryParameters.fleet_id -eq 2
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'enrollment_profiles/automatic' -and $QueryParameters.Count -eq 0
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'enrollment_profiles/automatic/default'
        }
    }

    It 'sets a profile from a JSON file with a byte order mark' {
        $set = Set-FleetEnrollmentProfile -Path $script:DepProfile -FleetId 2 -Confirm:$false
        $set.PSObject.TypeNames | Should -Contain 'FleetDM.EnrollmentProfile'
        Set-FleetEnrollmentProfile -Path $script:DepProfile -Name 'Custom' -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'enrollment_profiles/automatic' -and $Method -eq 'POST' -and $Body.fleet_id -eq 2 -and
            $Body.name -eq 'dep_profile.json' -and $Body.enrollment_profile.is_mandatory -eq $true -and
            $Body.enrollment_profile.skip_setup_items -is [System.Array] -and
            $Body.enrollment_profile.skip_setup_items.Count -eq 1 -and
            $Body.enrollment_profile.skip_setup_items[0] -eq 'Location'
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Body.name -eq 'Custom' -and -not $Body.ContainsKey('fleet_id')
        }
    }

    It 'rejects a file that is not a JSON object' {
        { Set-FleetEnrollmentProfile -Path $script:BadJson -Confirm:$false } | Should -Throw '*is not valid JSON*'
        { Set-FleetEnrollmentProfile -Path $script:ArrayJson -Confirm:$false } | Should -Throw '*must be a JSON object*'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'deletes a fleet profile and the unassigned profile' {
        (Remove-FleetEnrollmentProfile -FleetId 2 -Force).FleetId | Should -Be 2
        (Remove-FleetEnrollmentProfile -Confirm:$false).FleetId | Should -BeNullOrEmpty
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'enrollment_profiles/automatic' -and $Method -eq 'DELETE' -and $QueryParameters.fleet_id -eq 2
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'DELETE' -and $QueryParameters.Count -eq 0
        }
    }

    It 'sends nothing with -WhatIf' {
        Set-FleetEnrollmentProfile -Path $script:DepProfile -WhatIf
        Remove-FleetEnrollmentProfile -FleetId 2 -Force -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }
}

Describe 'Automatic enrollment profile on the wire' -Tag 'Unit' {
    It 'sends a one-element skip_setup_items list as a JSON array' {
        InModuleScope FleetDM-PowerShell -ArgumentList $script:DepProfile {
            param($ProfilePath)
            Mock Invoke-RestMethod {
                $script:EnrollmentWire = $Body
                return [PSCustomObject]@{ fleet_id = 2; name = 'dep_profile.json' }
            }
            Set-FleetEnrollmentProfile -Path $ProfilePath -FleetId 2 -Confirm:$false | Out-Null
            $script:EnrollmentWire | Should -Match '"skip_setup_items":\["Location"\]'
            $script:EnrollmentWire | Should -Not -Match '"skip_setup_items":"Location"'
        }
    }
}

Describe 'Google conditional access' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Body)
            if ($Method -eq 'DELETE') { return $null }
            return [PSCustomObject]@{ customer_id = 'C01234abc'; admin_email = 'a@example.com'; service_account_key_configured = $true; state = 'connected' }
        }
    }

    It 'gets the settings' {
        (Get-FleetGoogleConditionalAccess).PSObject.TypeNames | Should -Contain 'FleetDM.GoogleConditionalAccess'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter { $Endpoint -eq 'conditional_access/google' -and $Method -eq 'GET' }
    }

    It 'connects with POST and the parsed service account key' {
        $result = Set-FleetGoogleConditionalAccess -Connect -CustomerId 'C01234abc' -AdminEmail 'a@example.com' -ServiceAccountKeyPath $script:KeyFile -Confirm:$false
        $result.state | Should -Be 'connected'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq 'conditional_access/google' -and $Method -eq 'POST' -and $Body.customer_id -eq 'C01234abc' -and
            $Body.admin_email -eq 'a@example.com' -and $Body.service_account_key.private_key -like '*PK-SECRET-VALUE*'
        }
    }

    It 'patches only the supplied fields and retries with an empty body' {
        Set-FleetGoogleConditionalAccess -AdminEmail 'new@example.com' -Confirm:$false | Out-Null
        Set-FleetGoogleConditionalAccess -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'PATCH' -and ($Body.Keys -join ',') -eq 'admin_email'
        }
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $Method -eq 'PATCH' -and $Body.Count -eq 0
        }
    }

    It 'requires all three values to connect and rejects a bad key or customer id' {
        $parameters = (Get-Command Set-FleetGoogleConditionalAccess).Parameters
        foreach ($name in 'CustomerId', 'AdminEmail', 'ServiceAccountKeyPath') {
            $parameters[$name].ParameterSets['Connect'].IsMandatory | Should -BeTrue
            $parameters[$name].ParameterSets['Update'].IsMandatory | Should -BeFalse
        }
        { Set-FleetGoogleConditionalAccess -CustomerId '01234' -Confirm:$false } | Should -Throw '*CustomerId*'
        { Set-FleetGoogleConditionalAccess -ServiceAccountKeyPath $script:BadJson -Confirm:$false } | Should -Throw '*is not valid JSON*'
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }

    It 'disconnects Google' {
        (Remove-FleetGoogleConditionalAccess -Force).Status | Should -Be 'Removed'
        Remove-FleetGoogleConditionalAccess -Confirm:$false | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 2 -Exactly -ParameterFilter { $Method -eq 'DELETE' }
    }

    It 'sends nothing with -WhatIf' {
        Set-FleetGoogleConditionalAccess -Connect -CustomerId 'C1' -AdminEmail 'a@example.com' -ServiceAccountKeyPath $script:KeyFile -WhatIf
        Set-FleetGoogleConditionalAccess -AdminEmail 'a@example.com' -WhatIf
        Remove-FleetGoogleConditionalAccess -Force -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }
}

Describe 'Microsoft Graph credentials' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $Body)
            if ($Method -eq 'PUT') { return $null }
            return [PSCustomObject]@{ microsoft_graph_credentials = @([PSCustomObject]@{ tenant_id = 'fec37e96-3615-4e37-8fac-445d5328af3c'; credential_invalid = $false }) }
        }
        $script:Secret = ConvertTo-SecureString 'iL78Q~graph-secret' -AsPlainText -Force
    }

    It 'lists credentials' {
        (@(Get-FleetMicrosoftGraphCredential))[0].PSObject.TypeNames | Should -Contain 'FleetDM.MicrosoftGraphCredential'
    }

    It 'puts one credential with its secret and a dry run flag' {
        $result = Set-FleetMicrosoftGraphCredential -TenantId $script:Tenant -ClientId $script:Client -ClientSecret $script:Secret -DryRun -Confirm:$false
        $result.Status | Should -Be 'Validated'
        $result.SecretSent | Should -BeTrue
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 1 -Exactly -ParameterFilter {
            $credential = $Body.microsoft_graph_credentials[0]
            $Endpoint -eq 'microsoft_graph_credentials' -and $Method -eq 'PUT' -and $Body.dry_run -eq $true -and
            $Body.microsoft_graph_credentials.Count -eq 1 -and $credential.tenant_id -eq 'fec37e96-3615-4e37-8fac-445d5328af3c' -and
            $credential.client_id -eq '8c8e3fd4-9b2c-4d3e-8f10-2233445566aa' -and $credential.client_secret -eq 'iL78Q~graph-secret'
        }
    }

    It 'keeps the stored secret when ClientSecret is omitted' {
        $result = Set-FleetMicrosoftGraphCredential -TenantId $script:Tenant -ClientId $script:Client -Confirm:$false
        $result.Status | Should -Be 'Saved'
        $result.SecretSent | Should -BeFalse
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            -not $Body.microsoft_graph_credentials[0].ContainsKey('client_secret') -and -not $Body.ContainsKey('dry_run')
        }
    }

    It 'clears every credential with an empty list' {
        $result = Set-FleetMicrosoftGraphCredential -Clear -Confirm:$false
        $result.Status | Should -Be 'Cleared'
        $result.TenantId | Should -BeNullOrEmpty
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Body.microsoft_graph_credentials -is [array] -and $Body.microsoft_graph_credentials.Count -eq 0
        }
    }

    It 'rejects ids that are not GUIDs and sends nothing with -WhatIf' {
        { Set-FleetMicrosoftGraphCredential -TenantId 'contoso' -ClientId $script:Client -Confirm:$false } | Should -Throw '*TenantId*'
        Set-FleetMicrosoftGraphCredential -TenantId $script:Tenant -ClientId $script:Client -WhatIf
        Set-FleetMicrosoftGraphCredential -Clear -WhatIf
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0
    }
}

Describe 'Credential redaction in verbose logs' -Tag 'Unit' {
    It 'redacts service_account_key, private_key, and client_secret at any depth' {
        InModuleScope FleetDM-PowerShell {
            $text = Get-FleetRedactedLogText -Text @{
                service_account_key = @{ private_key = 'PK-1'; client_email = 'sa@example.com' }
                nested = @{ inner = @{ private_key = 'PK-2'; client_secret = 'CS-1' } }
                list = @(@{ client_secret = 'CS-2' })
            }
            $text | Should -Not -Match 'PK-1|PK-2|CS-1|CS-2|sa@example.com'
            $text | Should -Match '"service_account_key":"\[REDACTED\]"'
            Get-FleetRedactedLogText -Text '{"private_key":"PK-3","x":{"client_secret":"CS-3"}}' | Should -Not -Match 'PK-3|CS-3'
            Get-FleetRedactedLogText -Text 'https://f/x?client_secret=CS-4&a=1' | Should -Not -Match 'CS-4'
            Get-FleetRedactedLogText -Text '@{private_key=PK-5; a=1}' | Should -Not -Match 'PK-5'
            Test-FleetSecretLogName -Name 'Client_Secret' | Should -BeTrue
            Test-FleetSecretLogName -Name 'client_id' | Should -BeFalse
        }
    }

    It 'keeps the Google key and Graph secret out of the request verbose stream' {
        $key = $script:KeyFile
        $tenant = $script:Tenant
        $client = $script:Client
        InModuleScope FleetDM-PowerShell -Parameters @{ Key = $key; Tenant = $tenant; Client = $client } {
            param($Key, $Tenant, $Client)
            Mock Invoke-RestMethod { return [PSCustomObject]@{ state = 'connected' } }
            $google = Set-FleetGoogleConditionalAccess -Connect -CustomerId 'C01234abc' -AdminEmail 'a@example.com' -ServiceAccountKeyPath $Key -Confirm:$false -Verbose 4>&1
            $secret = ConvertTo-SecureString 'iL78Q~graph-secret' -AsPlainText -Force
            $graph = Set-FleetMicrosoftGraphCredential -TenantId $Tenant -ClientId $Client -ClientSecret $secret -Confirm:$false -Verbose 4>&1
            $logText = (@($google) + @($graph) | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }) -join "`n"
            $logText | Should -Match 'Request body'
            $logText | Should -Not -Match 'PK-SECRET-VALUE|kid-1|iL78Q~graph-secret'
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Body -like '*PK-SECRET-VALUE*' }
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter { $Body -like '*iL78Q~graph-secret*' }
        }
    }
}
