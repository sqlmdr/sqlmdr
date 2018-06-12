. "$PSScriptRoot\Header.ps1"

Describe 'Invoke-Mdr Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        . "$PSScriptRoot\Mocks.ps1"

        Context "Command Usage" {
            $command = Get-Command -Module 'SQLMDR' -Name 'Invoke-Mdr'

            It "Allows filtering to a specific server" {
                $command.Parameters.ContainsKey('ComputerName') | Should Be $true
            }

            It "Allows filtering to a specific instance" {
                $command.Parameters.ContainsKey('SqlInstance') | Should Be $true
            }

            It "Allows filtering to a specific database" {
                $command.Parameters.ContainsKey('Database') | Should Be $true
            }
        }

        Context "Functionality" {

        }
    }
}