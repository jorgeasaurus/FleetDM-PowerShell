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

Describe 'Request and pagination fixes' -Tag 'Unit' {
    It 'serializes decimal numbers with a dot under a comma culture' {
        InModuleScope FleetDM-PowerShell {
            $previous = [System.Globalization.CultureInfo]::CurrentCulture
            [System.Globalization.CultureInfo]::CurrentCulture = [System.Globalization.CultureInfo]::GetCultureInfo('de-DE')
            try {
                $json = ConvertTo-FleetJson -InputObject @{ rate = [double]1.5 }
                $json | Should -Be '{"rate":1.5}'
            }
            finally {
                [System.Globalization.CultureInfo]::CurrentCulture = $previous
            }
        }
    }

    It 'keeps a one-element array as a JSON array' {
        InModuleScope FleetDM-PowerShell {
            Mock Invoke-RestMethod { return @{ ok = $true } }
            Invoke-FleetDMRequest -Endpoint 'reports/5/run' -Method POST -Body @{ host_ids = @(7) } | Out-Null
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                $Body -match '"host_ids":\[7\]'
            }
        }
    }

    It 'encodes query text without System.Object[] and skips nulls' {
        InModuleScope FleetDM-PowerShell {
            Mock Invoke-RestMethod { return @{ hosts = @() } }
            $query = @{
                query = 'ada lovelace'
                empty = $null
                ids = @(1, 2)
            }
            Invoke-FleetDMRequest -Endpoint 'hosts' -QueryParameters $query | Out-Null
            Should -Invoke Invoke-RestMethod -Times 1 -ParameterFilter {
                $text = $Uri.OriginalString
                $text -like '*query=ada%20lovelace*' -and
                $text -like '*ids=1,2*' -and
                $text -notlike '*empty=*' -and
                $text -notlike '*System.Object*'
            }
        }
    }

    It 'does not duplicate the page parameter while following pagination' {
        InModuleScope FleetDM-PowerShell {
            $script:calls = @()
            Mock Invoke-RestMethod {
                $script:calls += $Uri
                if ($Uri -like '*page=0*') {
                    return [PSCustomObject]@{
                        software_titles = @([PSCustomObject]@{ id = 1; name = 'Slack' })
                        meta = [PSCustomObject]@{ has_next_results = $true }
                    }
                }
                return [PSCustomObject]@{
                    software_titles = @([PSCustomObject]@{ id = 2; name = 'Zoom' })
                    meta = [PSCustomObject]@{ has_next_results = $false }
                }
            }

            $result = Invoke-FleetDMRequest -Endpoint 'software/titles' -QueryParameters @{ page = 9; per_page = 1 } -FollowPagination
            @($result).Count | Should -Be 2
            $result[0].name | Should -Be 'Slack'
            $first = $script:calls[0].OriginalString
            $first | Should -Match '(^|[?&])page=0($|&)'
            $first | Should -Not -Match '(^|[?&])page=9($|&)'
            [regex]::Matches($first, '(^|[?&])page=').Count | Should -Be 1
        }
    }

    It 'keeps requesting full pages when the response has no pagination metadata' {
        InModuleScope FleetDM-PowerShell {
            $script:metaFreePages = 0
            Mock Invoke-RestMethod {
                $script:metaFreePages++
                if ($Uri.OriginalString -like '*page=0*') {
                    return [PSCustomObject]@{
                        fleets = @(
                            [PSCustomObject]@{ id = 1; name = 'one' }
                            [PSCustomObject]@{ id = 2; name = 'two' }
                        )
                    }
                }
                if ($Uri.OriginalString -like '*page=1*') {
                    return [PSCustomObject]@{ fleets = @([PSCustomObject]@{ id = 3; name = 'three' }) }
                }
                throw "unexpected extra page: $Uri"
            }

            $result = @(Invoke-FleetDMRequest -Endpoint 'fleets' -QueryParameters @{ per_page = 2 } -FollowPagination)
            $result.Count | Should -Be 3
            $result[2].name | Should -Be 'three'
            $script:metaFreePages | Should -Be 2
        }
    }

    It 'does not keep a repeated full page' {
        InModuleScope FleetDM-PowerShell {
            Mock Invoke-RestMethod {
                return [PSCustomObject]@{
                    fleets = @(
                        [PSCustomObject]@{ id = 1; name = 'one' }
                        [PSCustomObject]@{ id = 2; name = 'two' }
                    )
                }
            }

            $result = @(Invoke-FleetDMRequest -Endpoint 'fleets' -QueryParameters @{ per_page = 2 } -FollowPagination)
            $result.Count | Should -Be 2
            @($result | Where-Object { $_.id -eq 1 }).Count | Should -Be 1
        }
    }

    It 'stops when a page is empty even if has_next_results stays true' {
        InModuleScope FleetDM-PowerShell {
            $script:pages = 0
            Mock Invoke-RestMethod {
                $script:pages++
                return [PSCustomObject]@{
                    hosts = @()
                    meta = [PSCustomObject]@{ has_next_results = $true }
                }
            }

            $result = @(Invoke-FleetDMRequest -Endpoint 'hosts' -FollowPagination)
            $script:pages | Should -Be 1
            $result.Count | Should -Be 0
        }
    }
}

Describe 'Host, removal, and software fixes' -Tag 'Unit' {
    BeforeEach {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method, $QueryParameters, $Body)
            return @{
                Endpoint = $Endpoint
                Method = $Method
                QueryParameters = $QueryParameters
                Body = $Body
                hosts = @([PSCustomObject]@{ id = 1; hostname = 'a' })
                host = [PSCustomObject]@{ id = 1; hostname = 'a' }
            }
        }
    }

    It 'accepts IncludeSoftware together with a host id' {
        { Get-FleetHost -Id 1 -IncludeSoftware } | Should -Not -Throw
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'hosts/1'
        }
    }

    It 'sends order_key and not the unmapped orderkey parameter' {
        Get-FleetHost -OrderKey hostname | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $QueryParameters.order_key -eq 'hostname' -and
            -not $QueryParameters.ContainsKey('orderkey')
        }
    }

    It 'loads label members from the label hosts endpoint' {
        Get-FleetHost -Label 6 | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'labels/6/hosts' -and
            -not $QueryParameters.ContainsKey('label_name')
        }
    }

    It 'requires OSName and OSVersion together' {
        { Get-FleetHost -OSName 'macOS' } | Should -Throw '*OSName and OSVersion*'
    }

    It 'sends fleet_id for the Premium fleet filter' {
        Get-FleetHost -FleetId 0 | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $QueryParameters.fleet_id -eq 0
        }
    }

    It 'formats After as a UTC timestamp' {
        $stamp = [datetime]::new(2024, 5, 1, 12, 0, 0, [DateTimeKind]::Utc)
        Get-FleetHost -After $stamp | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $QueryParameters.after -eq '2024-05-01T12:00:00Z'
        }
    }

    It 'does not delete a host when Force is combined with WhatIf' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method)
            if ($Method -eq 'DELETE') { throw 'DELETE should not be called with WhatIf' }
            return @{ host = [PSCustomObject]@{ id = 1; hostname = 'a' } }
        }

        { Remove-FleetHost -Id 1 -Force -WhatIf } | Should -Not -Throw
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -Times 0 -ParameterFilter {
            $Method -eq 'DELETE'
        }
    }

    It 'lists software versions from the current endpoint' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            return @{
                software = @(
                    [PSCustomObject]@{ id = 1; name = 'Chrome'; version = '1'; hosts_count = 1; vulnerabilities = @() }
                )
            }
        }
        Get-FleetSoftware -Page 0 | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'software/versions'
        }
    }

    It 'runs a saved report on the reports endpoint' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            return @{
                query_id = 5
                targeted_host_count = 1
                responded_host_count = 1
                results = @(@{ host_id = 1; rows = @(); error = $null })
            }
        }
        Invoke-FleetSavedQuery -QueryId 5 -HostId 1 | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'reports/5/run' -and $Body.host_ids -contains 1
        }
    }

    It 'deletes a temporary report by id rather than by name' {
        Mock Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell {
            param($Endpoint, $Method)
            if ($Endpoint -eq 'reports' -and $Method -eq 'POST') {
                return @{ query = @{ id = 44; name = 'temp' } }
            }
            if ($Endpoint -eq 'reports/44/run') {
                return @{
                    query_id = 44
                    targeted_host_count = 1
                    responded_host_count = 1
                    results = @()
                }
            }
            return $null
        }
        Mock Invoke-FleetSavedQuery -ModuleName FleetDM-PowerShell {
            return [PSCustomObject]@{ Results = @() }
        }

        Invoke-FleetQuery -Query 'SELECT 1;' -HostId 3 | Out-Null
        Should -Invoke Invoke-FleetDMRequest -ModuleName FleetDM-PowerShell -ParameterFilter {
            $Endpoint -eq 'reports/id/44' -and $Method -eq 'DELETE'
        }
    }
}

Describe 'Premium HTTP errors' -Tag 'Unit' {
    It 'reports HTTP 402 as a Fleet Premium license error' {
        $port = Get-Random -Minimum 20000 -Maximum 45000
        $listener = [System.Net.HttpListener]::new()
        $listener.Prefixes.Add("http://127.0.0.1:$port/")
        $listener.Start()

        $runspace = [runspacefactory]::CreateRunspace()
        $runspace.Open()
        $worker = [powershell]::Create()
        $worker.Runspace = $runspace
        $null = $worker.AddScript({
            param($HttpListener)
            $context = $HttpListener.GetContext()
            $payload = '{"message":"Requires Fleet Premium license","errors":[{"reason":"premium license"}]}'
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
            $context.Response.StatusCode = 402
            $context.Response.ContentType = 'application/json'
            $context.Response.ContentLength64 = $bytes.Length
            $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
            $context.Response.OutputStream.Close()
        }).AddArgument($listener)
        $handle = $worker.BeginInvoke()

        InModuleScope FleetDM-PowerShell {
            $script:FleetDMConnection = @{
                BaseUri = $null
                Headers = @{ Authorization = 'Bearer test-token' }
                Version = '4.67.0'
            }
            $script:FleetDMWebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        }
        # The listener port is applied from this test scope through a module variable set below.
        InModuleScope FleetDM-PowerShell -ArgumentList "http://127.0.0.1:$port" {
            param($Base)
            $script:FleetDMConnection.BaseUri = $Base
        }

        try {
            { Get-FleetTeam -ErrorAction Stop } | Should -Throw '*Fleet Premium*'
        }
        finally {
            $listener.Stop()
            $listener.Close()
            $worker.EndInvoke($handle) | Out-Null
            $worker.Dispose()
            $runspace.Close()
            InModuleScope FleetDM-PowerShell {
                $script:FleetDMConnection.BaseUri = 'https://test.fleetdm.example.com'
            }
        }
    }

    It 'reports HTTP 403 license text as Fleet Premium and leaves other 403s as access denied' {
        InModuleScope FleetDM-PowerShell {
            Mock Invoke-RestMethod {
                $response = [PSCustomObject]@{
                    StatusCode = 403
                    StatusDescription = 'Requires Fleet Premium license'
                }
                $ex = New-Object System.Exception 'Requires Fleet Premium license'
                $ex | Add-Member -NotePropertyName Response -NotePropertyValue $response -Force
                throw $ex
            }
            { Invoke-FleetDMRequest -Endpoint 'fleets' } | Should -Throw '*Fleet Premium*'

            Mock Invoke-RestMethod {
                $response = [PSCustomObject]@{
                    StatusCode = 403
                    StatusDescription = 'Forbidden'
                }
                $ex = New-Object System.Exception 'Forbidden'
                $ex | Add-Member -NotePropertyName Response -NotePropertyValue $response -Force
                throw $ex
            }
            { Invoke-FleetDMRequest -Endpoint 'fleets' } | Should -Throw '*Access denied*'
        }
    }
}
