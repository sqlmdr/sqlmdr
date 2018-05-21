. .\Header.ps1

Describe 'Enable-MdrCommand Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        . .\Mocks.ps1

        It 'Enables by module' {
            $moduleName = 'Module2'

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Module -eq $moduleName }
            $command | Select-Object -ExpandProperty Enabled -Unique | Should -Not -Be $true

            Enable-MdrCommand -Module $moduleName
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Module -eq $moduleName }
            $command | Select-Object -ExpandProperty Enabled -Unique | Should -Be $true
        }

        It 'Enables by name' {
            Reset-MockCommands

            $commandName = 'DisabledCommand1'

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Name -eq $commandName }
            $command.Enabled | Should -Be $false

            Enable-MdrCommand -Name $commandName
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Name -eq $commandName }
            $command.Enabled | Should -Be $true
        }

        It 'Enables an array of names' {
            Reset-MockCommands

            $commandName = @('DisabledCommand1', 'DisabledCommand2')

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Name -in $commandName }
            $command | Select-Object -ExpandProperty Enabled -Unique | Should -Be $false

            Enable-MdrCommand -Name $commandName
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Name -in $commandName }
            $command | Select-Object -ExpandProperty Enabled -Unique | Should -Be $true
        }

        It 'Enables by module and name' {
            Reset-MockCommands

            $moduleName = 'Module2'
            $commandName = 'DisabledCommand1'

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Module -eq $moduleName -and $_.Name -eq $commandName }
            $command | Select-Object -ExpandProperty Enabled -Unique | Should -Be $false

            Enable-MdrCommand -Module $moduleName -Name $commandName
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Module -eq $moduleName -and $_.Name -eq $commandName }
            $command | Select-Object -ExpandProperty Enabled -Unique | Should -Be $true
        }

        It 'Enables by pipeline from Get-MdrCommand' {

        }
    }
}
