$moduleManifestName = 'SQLMDR.psd1'
$moduleManifestPath = "$PSScriptRoot\..\$moduleManifestName"
Import-Module -FullyQualifiedName $moduleManifestPath -Force

Describe 'Set-MdrCommand Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        . .\Mocks.ps1

        $commands = @(
            [PSCustomObject] @{
                Module = 'Module1'
                Name = 'ServerCommand1'
                Category = 'Server'
                Enabled = $true
            },
            [PSCustomObject] @{
                Module = 'Module1'
                Name = 'ServerCommand2'
                Category = 'Server'
                Enabled = $true
            },
            [PSCustomObject] @{
                Module = 'Module1'
                Name = 'InstanceCommand1'
                Category = 'Instance'
                Enabled = $true
            },
            [PSCustomObject] @{
                Module = 'Module2'
                Name = 'DatabaseCommand1'
                Category = 'Database'
                Enabled = $true
            },
            [PSCustomObject] @{
                Module = 'Module2'
                Name = 'DisabledCommand1'
                Category = 'Server'
                Enabled = $false
            }
        )
        Set-PSFConfig -FullName 'sqlmdr.commands' -Value $commands

        It 'Sets by module' {

        }

        It 'Sets by an array of modules' {

        }

        It 'Sets by name' {

        }

        It 'Sets an array of names' {

        }

        It 'Sets by module and name' {

        }

        It 'Sets by pipeline from Get-MdrCommand' {

        }

        Context "Updates category" {
            It "By Name" {
                $commandName = 'ServerCommand1'
                $categoryName = 'Database'

                $command = Get-PSFConfig -FullName 'sqlmdr.commands'
                Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
                $command = $command.Value | Where-Object { $_.Name -eq $commandName }
                $command.Category | Should -Not -Be $categoryName

                Set-MdrCommand -Name 'ServerCommand1' -Category $categoryName
                Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

                $command = Get-PSFConfig -FullName 'sqlmdr.commands'
                $command = $command.Value | Where-Object { $_.Name -eq $commandName }
                $command.Category | Should -Be $categoryName
            }
        }

        Context "Updates state" {

        }
    }
}
