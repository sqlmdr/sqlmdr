. "$PSScriptRoot\Header.ps1"

Describe 'Get-MdrInstance Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        . "$PSScriptRoot\Mocks.ps1"

        Context "Command Usage" {
            $command = Get-Command -Module 'SQLMDR' -Name 'Get-MdrInstance'

            It "Has a parameter for ComputerName" {
                $command.Parameters.ContainsKey('ComputerName')
            }
        }

        Context "Functionality" {
            It "Gets a list from CMS" {
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

                $instances = Get-MdrInstance
                $instances.Count | Should Be (Get-DbaRegisteredServer -SqlInstance 'FakeServer1').Count
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

                $instances = Get-MdrInstance
                $instances.Count | Should Be $csv.Count
                Assert-MockCalled -CommandName 'Get-Content' -Times 1
            }

            It "Filters by ComputerName" {
                $computerName = 'FakeServer3'
                $instances = Get-MdrInstance -ComputerName $computerName
                $instances.Count | Should Be ($csv | Where { $_ -like ($computerName + '*') }).Count
            }
        }
    }
}