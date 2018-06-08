Mock -CommandName 'Get-PSFConfig' {
    if (-not $global:PesterPSFConfig -or $global:PesterPSFConfig -eq $null) {
        $global:PesterPSFConfig = @{}
    }

    return $global:PesterPSFConfig[$FullName]
}

Mock -CommandName 'Set-PSFConfig' {
    if (-not $global:PesterPSFConfig) {
        $global:PesterPSFConfig = @{}
    }

    if (-not $global:PesterPSFConfig.ContainsKey($FullName)) {
        $global:PesterPSFConfig[$FullName] = [PSCustomObject] @{
            FullName = $FullName
            Value = @()
        }
    }

    $global:PesterPSFConfig[$FullName].Value = $Value
}

function Reset-MockCommands {
    $mockCommands = Import-PowerShellDataFile -Path .\Tests\MockCommands.psd1
    $commands = @()
    foreach ($command in $mockCommands.Commands.GetEnumerator()) {
        $commands += [PSCustomObject] $command
    }
    Set-PSFConfig -FullName 'sqlmdr.commands' -Value $commands
}

Reset-MockCommands