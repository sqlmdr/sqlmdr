. "$PSScriptRoot\Header.ps1"

Describe 'Get-MdrServer Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        . "$PSScriptRoot\Mocks.ps1"

        Context "Command Usage" {
        }

        Context "Functionality" {
            It "Gets a unique servers list from CMS" {
                $fakeServers = @(
                    [PSCustomObject] @{
                        Name = 'FakeServer1'
                        ServerName = 'FakeServer1'
                    },
                    [PSCustomObject] @{
                        Name = 'FakeServer2'
                        ServerName = 'FakeServer2'
                    },
                    [PSCustomObject] @{
                        Name = 'FakeServer3'
                        ServerName = 'FakeServer3'
                    },
                    [PSCustomObject] @{
                        Name = 'FakeServer3\FakeInstance2'
                        ServerName = 'FakeServer3\FakeInstance2'
                    }
                )

                Mock -CommandName 'Get-DbaRegisteredServer' { return $fakeServers }
                Mock -CommandName 'Connect-DbaInstance' { return $true }

                Set-MdrServerSource -SourceType 'CMS' -CmsServer 'FakeServer1'
                Assert-MockCalled -CommandName 'Connect-DbaInstance' -Times 1
                Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

                $servers = Get-MdrServer
                $servers.Count | Should Be ((Get-DbaRegisteredServer -SqlInstance 'FakeServer1').Count - 1)
                Assert-MockCalled -CommandName 'Get-DbaRegisteredServer' -Times 1
            }

            It "Gets a unique servers list from CSV" {
                $csv = @(
                    'FakeServer1',
                    'FakeServer2',
                    'FakeServer3',
                    'FakeServer3\FakeInstance2'
                )

                $path = 'C:\MadeUpFile.csv'

                Mock -CommandName 'Test-Path' { return $true }
                Mock -CommandName Get-Content -ParameterFilter { $Path -eq 'C:\MadeUpFile.csv' } {
                    return $csv
                }

                Set-MdrServerSource -SourceType 'CSV' -FilePath $path
                Assert-MockCalled -CommandName 'Test-Path' -Times 1
                Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

                $servers = Get-MdrServer
                $servers.Count | Should Be ($csv.Count - 1)
                Assert-MockCalled -CommandName 'Get-Content' -Times 1
            }
        }
    }
}