Mock -CommandName 'Get-PSFConfig' {
    if (-not $script:PesterPSFConfig -or $script:PesterPSFConfig -eq $null) {
        Write-Verbose 'PesterPSFConfig was not set. Initializing to blank hashtable.'
        $script:PesterPSFConfig = @{}
    }

    Write-Verbose ("Returning $FullName")
    return $script:PesterPSFConfig[$FullName]
}

Mock -CommandName 'Set-PSFConfig' {
    if (-not $script:PesterPSFConfig) {
        $script:PesterPSFConfig = @{}
    }

    if (-not $script:PesterPSFConfig.ContainsKey($FullName)) {
        $script:PesterPSFConfig[$FullName] = [PSCustomObject] @{
            FullName = $FullName
            Value = @()
        }
    }

    $script:PesterPSFConfig[$FullName].Value = $Value
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