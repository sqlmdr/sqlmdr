$moduleManifestName = 'SQLMDR.psd1'
$moduleManifestPath = "$PSScriptRoot\..\$moduleManifestName"
Import-Module -FullyQualifiedName $moduleManifestPath -Force

Describe 'Set-MdrCommand Tests' {
    InModuleScope -ModuleName 'SQLMDR' {
        # WE NEED TO GENERATE THIS, DON'T JUST RETURN STATIC STUFF ALL THE TIME
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

        Mock -CommandName 'Set-PSFConfig' {
            if (-not $script:PesterPSFConfig) {
                $script:PesterPSFConfig = @{}
            }

            if (-not $script:PesterPSFConfig.ContainsKey($FullName)) {
                $script:PesterPSFConfig[$FullName] = [PSCustomObject] @{
                    FullName = $FullName
                    Value = @()
                    Description = ''
                }
            }

            $script:PesterPSFConfig[$FullName].Value += $Value
        }

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
                $command.Cateogry | Should -Be $categoryName
            }
        }

        Context "Updates state" {

        }
    }
}
