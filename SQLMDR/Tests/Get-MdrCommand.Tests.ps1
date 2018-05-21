. .\Header.ps1

Describe 'Get-MdrCommand Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        . .\Mocks.ps1

        It 'Filters by module' {
            $commands = Get-MdrCommand -Module 'Module1'
            Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
            $modules = $commands | Select-Object -ExpandProperty Module -Unique
            $modules.Count | Should -Be 1
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

        It "Gets by frequency" {
            $frequencyName = 'Daily'
            $commands = Get-MdrCommand -Frequency $frequencyName
            $commands = $commands | Select-Object -ExpandProperty Frequency -Unique
            $commands.Count | Should -Be 1
            $commands | Should -Be $frequencyName
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
