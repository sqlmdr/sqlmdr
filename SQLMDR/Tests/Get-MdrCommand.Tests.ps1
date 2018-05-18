$moduleManifestName = 'SQLMDR.psd1'
$moduleManifestPath = "$PSScriptRoot\..\$moduleManifestName"
Import-Module -FullyQualifiedName $moduleManifestPath -Force

Describe 'Get-MdrCommand Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        Mock -CommandName 'Get-PSFConfig' {
            return [PSCustomObject] @{
                FullName = 'sqlmdr.commands'
                Value = @(
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
                Description = ''
            }
        }

        It 'Filters by module' {
            $commands = Get-MdrCommand -Module 'Module1'
            Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
            $modules = $commands | Select-Object -ExpandProperty Module -Unique
            $modules.Count | Should -Be 1
        }

        It 'Filters by an array of modules' {
            $moduleNames = @('Module1', 'Module2')
            $commands = Get-MdrCommand -Module $moduleName
            Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
            $modules = $commands | Select-Object -ExpandProperty Module -Unique
            $modules.Count | Should -Be $moduleNames.Count
        }

        It 'Gets by name' {
            $commandName = 'ServerCommand1'
            $commands = Get-MdrCommand -Name $commandName
            Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
            $commands.Name | Should -Be $commandName
        }

        It 'Gets an array of names' {
            $commandNames = @('ServerCommand1', 'ServerCommand2')
            $commands = Get-MdrCommand -Name $commandNames
            Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
            $commands.Count | Should -Be $commandNames.Count
        }

        It 'Gets by module and name' {
            $moduleName = 'Module1'
            $commandName = 'ServerCommand1'
            $commands = Get-MdrCommand -Module $moduleName -Name $commandName
            Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
            $commands.Module | Should -Be $moduleName
            $commands.Name | Should -Be $commandName
        }

        It 'Gets by category' {
            $categoryName = 'Server'
            $commands = Get-MdrCommand -Category $categoryName
            Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
            $categories = $commands | Select-Object -ExpandProperty Category -Unique
            $categories.Count | Should -Be 1
            $categories | Should Be $categoryName
        }

        It 'Gets by state (enabled/disabled)' {
            $enabled = $false
            $commands = Get-MdrCommand -Enabled:$enabled
            Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
            $states = $commands | Select-Object -ExpandProperty Enabled -Unique
            $states | Should Be $enabled
        }
    }
}
