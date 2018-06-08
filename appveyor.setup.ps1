$requiredModules = @(
    'Pester',
    'PSFramework',
    'dbatools',
    'PSScriptAnalyzer'
)

foreach ($requiredModule in $requiredModules) {
    $module = Get-Module -Name $requiredModule -ListAvailable
    if (-not $module) {
        Write-Host -Object "Install $requiredModule" -ForegroundColor DarkGreen
        Install-Module -Name $requiredModule -Repository PSGallery -Scope CurrentUser -Confirm:$false -Force | Out-Null
    } else {
        Write-Host -Object "$requiredModule is cached" -ForegroundColor DarkGreen
        Import-Module -Name $requiredModule -Force
    }
}

Write-Host -Object "Set StrictMode to 3.0" -ForegroundColor DarkGreen
Set-StrictMode -Version 3.0