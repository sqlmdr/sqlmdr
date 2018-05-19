Mock -CommandName 'Get-PSFConfig' {
    if (-not $script:PesterPSFConfig -or $script:PesterPSFConfig -eq $null) {
        $script:PesterPSFConfig = @{}
    }

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

    $script:PesterPSFConfig[$FullName].Value += $Value
}