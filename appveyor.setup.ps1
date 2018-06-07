$requiredModules = @(
    'Pester',
    'PSFramework',
    'dbatools'
)

foreach ($requiredModule in $requiredModules) {
    Write-Host -Object "Install $requiredModule" -ForegroundColor DarkGreen
    Install-Module -Name $requiredModule -Repository PSGallery | Out-Null
}