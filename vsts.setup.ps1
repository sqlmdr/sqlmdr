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
        Install-Module -Name $requiredModule -Repository PSGallery -Scope CurrentUser -SkipPublisherCheck -Force | Out-Null
    } else {
        Write-Host -Object "$requiredModule is cached" -ForegroundColor DarkGreen
        Import-Module -Name $requiredModule -Force
    }
}

# Add current folder to PSModulePath
try {
    Write-Output "Adding local folder to PSModulePath"
    $ENV:PSModulePath = $ENV:PSModulePath + ";$pwd"
    Write-Output "Added local folder to PSModulePath"
    $ENV:PSModulePath.Split(';')
}
catch {
    Write-Error "Failed to add $pwd to PSModulePath - $_"
}

Write-Host -Object "Set StrictMode to 3.0" -ForegroundColor DarkGreen
Set-StrictMode -Version 3.0