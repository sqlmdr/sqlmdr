. "$PSScriptRoot\Header.ps1"

Describe 'Get-MdrDatabase Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        . "$PSScriptRoot\Mocks.ps1"

        Context "Command Usage" {
            $command = Get-Command -Module 'SQLMDR' -Name 'Get-MdrDatabase'

            It "Has a parameter for ComputerName" {
                $command.Parameters.ContainsKey('ComputerName') | Should Be $true
            }

            It "Has a parameter for SqlInstance" {
                $command.Parameters.ContainsKey('SqlInstance') | Should Be $true
            }
        }

        Context "Functionality" {
            $fakeDatabases = @(
                [PSCustomObject] @{
                    ComputerName = 'FakeServer1'
                    SqlInstance = 'FakeServer1'
                    Name = 'FakeDatabase1'
                },
                [PSCustomObject] @{
                    ComputerName = 'FakeServer1'
                    SqlInstance = 'FakeServer1'
                    Name = 'FakeDatabase2'
                },
                [PSCustomObject] @{
                    ComputerName = 'FakeServer1'
                    SqlInstance = 'FakeServer1'
                    Name = 'FakeDatabase3'
                },
                [PSCustomObject] @{
                    ComputerName = 'FakeServer2'
                    SqlInstance = 'FakeServer2'
                    Name = 'FakeDatabase4'
                },
                [PSCustomObject] @{
                    ComputerName = 'FakeServer2'
                    SqlInstance = 'FakeServer2\FakeInstance2'
                    Name = 'FakeDatabase5'
                }
            )

            It "Filters by ComputerName" {
                Mock -CommandName 'Get-DbaDatabase' -ParameterFilter { 'FakeServer1' -eq $SqlInstance } {
                    return $fakeDatabases | Where-Object {
                        $_.ComputerName -eq 'FakeServer1'
                    }
                }
                Mock -CommandName 'Get-MdrInstance' -ParameterFilter { $ComputerName -eq 'FakeServer1' } {
                    return @(
                        [PSCustomObject] @{
                            ComputerName = 'FakeServer1'
                            SqlInstance = 'FakeServer1'
                        }
                    )
                }

                $computerName = 'FakeServer1'
                $databases = Get-MdrDatabase -ComputerName $computerName
                Assert-MockCalled -CommandName 'Get-MdrInstance' -Times 1
                Assert-MockCalled -CommandName 'Get-DbaDatabase' -Times 1

                $filteredFakeDatabases = $fakeDatabases | Where-Object {
                    $_.ComputerName -eq $computerName
                }

                $databases.Count | Should Be $filteredFakeDatabases.Count
            }

            It "Filters by SqlInstance" {
                Mock -CommandName 'Get-DbaDatabase' -ParameterFilter { 'FakeServer2\FakeInstance2' -eq $SqlInstance } {
                    return $fakeDatabases | Where-Object {
                        $_.SqlInstance -eq 'FakeServer2\FakeInstance2'
                    }
                }
                Mock -CommandName 'Get-MdrInstance' -ParameterFilter { $SqlInstance -eq 'FakeServer2\FakeInstance2' } {
                    return @(
                        [PSCustomObject] @{
                            ComputerName = 'FakeServer2'
                            SqlInstance = 'FakeServer2\FakeInstance2'
                        }
                    )
                }

                $sqlInstance = 'FakeServer2\FakeInstance2'
                $databases = Get-MdrDatabase -SqlInstance $sqlInstance
                Assert-MockCalled -CommandName 'Get-MdrInstance' -Times 1
                Assert-MockCalled -CommandName 'Get-DbaDatabase' -Times 1

                $filteredFakeDatabases = $fakeDatabases | Where-Object {
                    $_.SqlInstance -eq $sqlInstance
                }

                $databases.Count | Should Be $filteredFakeDatabases.Count
            }
        }
    }
}