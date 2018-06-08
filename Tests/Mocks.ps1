Mock -CommandName 'Get-PSFConfig' {
    Write-Verbose ('Mock Get-PSFConfig called')

    if (-not $global:PesterPSFConfig -or $global:PesterPSFConfig -eq $null) {
        Write-Verbose 'PesterPSFConfig was not set. Initializing to blank hashtable.'
        $global:PesterPSFConfig = @{}
    }

    Write-Verbose ("Returning $FullName")
    return $global:PesterPSFConfig[$FullName]
}

Mock -CommandName 'Set-PSFConfig' {
    Write-Verbose ('Mock Set-PSFConfig called')

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
    Write-Verbose ('Reset-MockCommands called')

    $mockCommands = Import-PowerShellDataFile -Path .\Tests\MockCommands.psd1
    $commands = @()
    foreach ($command in $mockCommands.Commands.GetEnumerator()) {
        $commands += [PSCustomObject] $command
    }
    Set-PSFConfig -FullName 'sqlmdr.commands' -Value $commands
}

Reset-MockCommands