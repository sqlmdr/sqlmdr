. "$PSScriptRoot\Header.ps1"

Describe 'Register-MdrCommand Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        . "$PSScriptRoot\Mocks.ps1"

        It 'Registers by module' {
            $VerbosePreference = 'Continue'
            $global:PesterPSFConfig = $null

            $moduleName = 'Microsoft.PowerShell.Management'
            $commands = Get-Command -Module $moduleName
            $null = Register-MdrCommand -Module $moduleName -Category 'Server' -Frequency 'Daily'

            Assert-MockCalled -CommandName 'Get-PSFConfig'
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $registeredCommands = Get-PSFConfig -FullName 'sqlmdr.commands'
            Assert-MockCalled -CommandName 'Get-PSFConfig'
            Write-Verbose $registeredCommands.Value.Count
            $registeredCommands.Value | % { Write-Verbose $_.Name }
            $registeredCommands = $registeredCommands.Value | Where-Object {
                $_.Module -eq $moduleName -and
                $_.Category -eq 'Server' -and
                $_.Frequency -eq 'Daily'
            }

            $registeredCommands.Count | Should -BeExactly $commands.Count
        }

        It 'Registers by name' {
            $script:PesterPSFConfig = $null

            $commandName = 'Get-ChildItem'
            $null = Register-MdrCommand -Name $commandName -Category 'Server' -Frequency 'Daily'

            Assert-MockCalled -CommandName 'Get-PSFConfig'
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $registeredCommand = Get-PSFConfig -FullName 'sqlmdr.commands'
            Assert-MockCalled -CommandName 'Get-PSFConfig'
            $registeredCommand = $registeredCommand.Value | Where-Object {
                $_.Name -eq $commandName -and
                $_.Category -eq 'Server' -and
                $_.Frequency -eq 'Daily'
            }

            $registeredCommand.Name | Should -BeExactly $commandName
        }

        It 'Registers an array of names' {
            $script:PesterPSFConfig = $null

            $commands = @('Get-ChildItem', 'Get-Location')
            $null = Register-MdrCommand -Name $commands -Category 'Server' -Frequency 'Daily'

            Assert-MockCalled -CommandName 'Get-PSFConfig'
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $registeredCommands = Get-PSFConfig -FullName 'sqlmdr.commands'
            Assert-MockCalled -CommandName 'Get-PSFConfig'
            $registeredCommands = $registeredCommands.Value | Where-Object {
                $_.Name -in $commands -and
                $_.Category -eq 'Server' -and
                $_.Frequency -eq 'Daily'
            }

            $registeredCommands.Count | Should -BeExactly 2
        }

        It 'Registers by module and name' {
            $script:PesterPSFConfig = $null

            $null = Register-MdrCommand -Module 'Microsoft.PowerShell.Management' -Name 'Get-ChildItem' -Category 'Server' -Frequency 'Daily'

            Assert-MockCalled -CommandName 'Get-PSFConfig'
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $registeredCommands = Get-PSFConfig -FullName 'sqlmdr.commands'
            Assert-MockCalled -CommandName 'Get-PSFConfig'
            $registeredCommand = $registeredCommands.Value | Where-Object {
                $_.Module -eq 'Microsoft.PowerShell.Management' -and
                $_.Name -eq 'Get-ChildItem' -and
                $_.Category -eq 'Server' -and
                $_.Frequency -eq 'Daily'
            }

            $registeredCommand | Should -Not -BeNullOrEmpty
        }

        It 'Registers in a disabled state' {
            $script:PesterPSFConfig = $null

            $commandName = 'Get-ChildItem'
            $null = Register-MdrCommand -Name $commandName -Category 'Server' -Frequency 'Daily' -Disable

            Assert-MockCalled -CommandName 'Get-PSFConfig'
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

            $registeredCommand = Get-PSFConfig -FullName 'sqlmdr.commands'
            Assert-MockCalled -CommandName 'Get-PSFConfig'
            $registeredCommand = $registeredCommand.Value | Where-Object {
                $_.Name -eq $commandName -and
                $_.Category -eq 'Server' -and
                $_.Frequency -eq 'Daily'
            }

            $registeredCommand.Enabled | Should -Be $false
        }

        It 'Prevents registering the same command multiple times' {
            $script:PesterPSFConfig = $null

            Register-MdrCommand -Module 'Microsoft.PowerShell.Management' -Name 'Get-ChildItem' -Category 'Server' -Frequency 'Daily'
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1
            Assert-MockCalled -CommandName 'Get-PSFConfig'
            { Register-MdrCommand -Module 'Microsoft.PowerShell.Management' -Name 'Get-ChildItem' -Category 'Server' -Frequency 'Daily' } | Should Throw
            Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1
            Assert-MockCalled -CommandName 'Get-PSFConfig'
        }

        It 'Prevents registering unknown commands' {
            $script:PesterPSFConfig = $null

            { Register-MdrCommand -Name 'Get-UnknownCommandIMadeUp' -Category 'Server' -Frequency 'Daily' } | Should Throw 'Unknown command'
        }

    }
}