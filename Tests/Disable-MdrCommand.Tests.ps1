. "$PSScriptRoot\Header.ps1"

Describe 'Disable-MdrCommand Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        . "$PSScriptRoot\Mocks.ps1"

        It 'Disables by module' {
            $moduleName = 'DisableByModule'

            Disable-MdrCommand -Module $moduleName
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1

            $command = $command.Value | Where-Object { $_.Module -eq $moduleName }
            $command | Select-Object -ExpandProperty Enabled -Unique | Should -Be $false
        }

        It 'Disables by name' {
            Reset-MockCommand

            $commandName = 'ServerCommand1'

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Name -eq $commandName }
            $command.Enabled | Should -Be $true

            Disable-MdrCommand -Name $commandName
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Name -eq $commandName }
            $command.Enabled | Should -Be $false
        }

        It 'Disables an array of names' {
            Reset-MockCommand

            $commandName = @('ServerCommand1', 'ServerCommand2')

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Name -in $commandName }
            $command | Select-Object -ExpandProperty Enabled -Unique | Should -Be $true

            Disable-MdrCommand -Name $commandName
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Name -in $commandName }
            $command | Select-Object -ExpandProperty Enabled -Unique | Should -Be $false
        }

        It 'Disables by module and name' {
            Reset-MockCommand

            $moduleName = 'Module1'
            $commandName = 'ServerCommand1'

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Module -eq $moduleName -and $_.Name -eq $commandName }
            $command | Select-Object -ExpandProperty Enabled -Unique | Should -Be $true

            Disable-MdrCommand -Module $moduleName -Name $commandName
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $command = Get-PSFConfig -FullName 'sqlmdr.commands'
            $command = $command.Value | Where-Object { $_.Module -eq $moduleName -and $_.Name -eq $commandName }
            $command | Select-Object -ExpandProperty Enabled -Unique | Should -Be $false
        }

        It 'Disables by pipeline from Get-MdrCommand' {

        }
    }
}
