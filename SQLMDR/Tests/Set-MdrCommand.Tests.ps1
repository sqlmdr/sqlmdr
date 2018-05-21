. .\Header.ps1

Describe 'Set-MdrCommand Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        . .\Mocks.ps1

        It "Errors when using an invalid category" {
            { Set-MdrCommand -Name 'ServerCommand1' -Category 'Module1' } | Should Throw "Cannot validate argument on parameter 'Category'"
        }

        It "Errors when command isn't registered" {
            Reset-MockCommands

            { Set-MdrCommand -Name 'Get-ChildItem' -Category 'Server' } | Should Throw 'Command not registered'
        }

        Context "Updates category" {
            It "By module" {
                Reset-MockCommands

                $moduleName = 'Module1'
                $categoryName = 'Database'

                $command = Get-PSFConfig -FullName 'sqlmdr.commands'
                Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
                $command = $command.Value | Where-Object { $_.Module -eq $moduleName }
                $command.Category | Should -Not -Be $categoryName

                Set-MdrCommand -Module $moduleName -Category $categoryName
                Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

                $command = Get-PSFConfig -FullName 'sqlmdr.commands'
                $command = $command.Value | Where-Object { $_.Module -eq $moduleName }
                $command | Select-Object -ExpandProperty Category -Unique | Should -Be $categoryName
            }

            It "By name" {
                Reset-MockCommands

                $commandName = 'ServerCommand1'
                $categoryName = 'Database'

                $command = Get-PSFConfig -FullName 'sqlmdr.commands'
                Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
                $command = $command.Value | Where-Object { $_.Name -eq $commandName }
                $command.Category | Should -Not -Be $categoryName

                Set-MdrCommand -Name $commandName -Category $categoryName
                Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

                $command = Get-PSFConfig -FullName 'sqlmdr.commands'
                $command = $command.Value | Where-Object { $_.Name -eq $commandName }
                $command.Category | Should -Be $categoryName
            }

            It "By array of names" {
                Reset-MockCommands

                $commandName = @('ServerCommand1', 'ServerCommand2')
                $categoryName = 'Database'

                $command = Get-PSFConfig -FullName 'sqlmdr.commands'
                Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
                $command = $command.Value | Where-Object { $_.Name -in $commandName }
                $command.Category | Should -Not -Be $categoryName

                Set-MdrCommand -Name $commandName -Category $categoryName
                Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

                $command = Get-PSFConfig -FullName 'sqlmdr.commands'
                $command = $command.Value | Where-Object { $_.Name -in $commandName }
                $command | Select-Object -ExpandProperty Category -Unique | Should -Be $categoryName
            }

            It "By module and name" {
                Reset-MockCommands

                $moduleName = 'Module1'
                $commandName = 'ServerCommand1'
                $categoryName = 'Database'

                $command = Get-PSFConfig -FullName 'sqlmdr.commands'
                Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1
                $command = $command.Value | Where-Object { $_.Module -eq $moduleName -and $_.Name -eq $commandName }
                $command.Category | Should -Not -Be $categoryName

                Set-MdrCommand -Module $moduleName -Name $commandName -Category $categoryName
                Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

                $command = Get-PSFConfig -FullName 'sqlmdr.commands'
                $command = $command.Value | Where-Object { $_.Name -eq $commandName }
                $command.Category | Should -Be $categoryName
            }

            It "From pipeline" {

            }
        }

        Context "Enables" {
            It "By module" {
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

            It "By name" {
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

            It "By array of names" {
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

            It "By module and name" {
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

            It "From pipeline" {

            }
        }

        Context "Disables" {
            It "By module" {
                $moduleName = 'DisableByModule'

                Disable-MdrCommand -Module $moduleName
                Assert-MockCalled -CommandName 'Set-PSFConfig' -Times 1

                $command = Get-PSFConfig -FullName 'sqlmdr.commands'
                Assert-MockCalled -CommandName 'Get-PSFConfig' -Times 1

                $command = $command.Value | Where-Object { $_.Module -eq $moduleName }
                $command | Select-Object -ExpandProperty Enabled -Unique | Should -Be $false
            }

            It "By name" {
                Reset-MockCommands

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

            It "By array of names" {
                Reset-MockCommands

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

            It "By module and name" {
                Reset-MockCommands

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

            It "From pipeline" {

            }
        }
    }
}
