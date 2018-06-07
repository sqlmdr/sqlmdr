$requiredModules = @(
    'Pester',
    'PSFramework',
    'dbatools'
)

foreach ($requiredModule in $requiredModules) {
    $module = Get-Module -Name $requiredModule
    if (-not $module) {
        Write-Host -Object "Install $requiredModule" -ForegroundColor DarkGreen
        Install-Module -Name $requiredModule -Repository PSGallery | Out-Null
    } else {
        Write-Host -Object "$requiredModule is cached" -ForegroundColor DarkGreen
    }
}