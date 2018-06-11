. "$PSScriptRoot\Header.ps1"

Describe 'Set-MdrServerSource Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        . "$PSScriptRoot\Mocks.ps1"

        Context "Command Usage" {
            $command = Get-Command -Module 'SQLMDR' -Name 'Set-MdrServerSource'

            It "Has a SourceType parameter" {
                $command.Parameters.ContainsKey('SourceType') | Should Be $true
            }

            It "Only allows CMS/CSV SourceType" {
                $validValues = $command.Parameters['SourceType'].Attributes.ValidValues
                $validValues.Count | Should Be 2
                $validValues.Contains('CMS') | Should Be $true
                $validValues.Contains('CSV') | Should Be $true
            }

            It "Has a CMS parameter set" {
                $command.ParameterSets.Name.Contains('CMS') | Should Be $true
            }

            It "Has a CmsServer parameter" {
                $command.Parameters.ContainsKey('CmsServer') | Should Be $true
            }

            It "Only allows valid SQL Servers for CmsServer" {
                Mock Connect-DbaInstance { throw "Could not connect" }

                { Set-MdrServerSource -SourceType 'CMS' -CmsServer 'FakeServer1' } | Should Throw

                Assert-MockCalled -CommandName 'Connect-DbaInstance' -Times 1
            }

            It "Should allow an array of CMS Servers" {
                $command.Parameters['CmsServer'].ParameterType.BaseType.Name | Should Be 'Array'
            }

            It "Doesn't allow FilePath with CMS parameter set" {
                { Set-MdrServerSource -SourceType 'CMS' -FilePath 'C:\MadeUpFile.csv' } | Should Throw
            }

            It "Has a CSV parameter set" {
                $command.ParameterSets.Name.Contains('CSV') | Should Be $true
            }

            It "Has a FilePath parameter" {
                $command.Parameters.ContainsKey('FilePath') | Should Be $true
            }

            It "Doesn't allow CmsServer with CSV parameter set" {
                { Set-MdrServerSource -SourceType 'CSV' -CmsServer 'FakeServer1' } | Should Throw
            }

            It "Only allows valid CSV files for FilePath" {
                Mock Test-Path { throw "Could not find file" }

                { Set-MdrServerSource -SourceType 'CSV' -FilePath 'C:\MadeUpFile.txt' } | Should Throw

                Assert-MockCalled -CommandName 'Test-Path' -Times 1
            }
        }

        Context "Functionality" {
            It "Sets configs for using CMS" {
                Mock -CommandName 'Connect-DbaInstance' { return $true }

                Set-MdrServerSource -SourceType 'CMS' -CmsServer 'FakeServer1'
                Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

                $config = Get-PSFConfig -FullName 'sqlmdr.server.source'
                $config.Value | Should Be 'FakeServer1'
                Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1

                $config = Get-PSFConfig -FullName 'sqlmdr.server.type'
                $config.Value | Should Be 'CMS'
                Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
            }

            It "Sets configs for using CSV" {
                Mock -CommandName 'Test-Path' { return $true }

                Set-MdrServerSource -SourceType 'CSV' -FilePath 'C:\MadeUpFile.csv'
                Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

                $config = Get-PSFConfig -FullName 'sqlmdr.server.source'
                $config.Value | Should Be 'C:\MadeUpFile.csv'
                Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1

                $config = Get-PSFConfig -FullName 'sqlmdr.server.type'
                $config.Value | Should Be 'CSV'
                Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
            }
        }
    }
}