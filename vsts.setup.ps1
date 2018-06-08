try {
    Write-Host -Object "Install NuGet Provider" -ForegroundColor DarkGreen
    Install-PackageProvider NuGet -Scope CurrentUser -Force | Out-Null
}
catch {
    Write-Error "Failed to install NuGet - $_"
}

$requiredModules = @(
    'Pester',
    'PSFramework',
    'dbatools',
    'PSScriptAnalyzer'
)

foreach ($requiredModule in $requiredModules) {
    $module = Get-Module -Name $requiredModule -ListAvailable
    if (-not $module) {
        try {
            Write-Host -Object "Install $requiredModule" -ForegroundColor DarkGreen
            Install-Module -Name $requiredModule -Repository PSGallery -Scope CurrentUser -Force | Out-Null
        }
        catch {
            Write-Error "Failed to install $requiredModule - $_"
        }
    } else {
        try {
            Write-Host -Object "$requiredModule is cached" -ForegroundColor DarkGreen
            Import-Module -Name $requiredModule -Force
        }
        catch {
            Write-Error "Failed to import $requiredModule - $_"
        }
    }
}

# Add current folder to PSModulePath
try {
    Write-Output "Add local folder to PSModulePath"
    $ENV:PSModulePath = $ENV:PSModulePath + ";$pwd"
}
catch {
    Write-Error "Failed to add $pwd to PSModulePath - $_"
}

Write-Host -Object "Set StrictMode to 3.0" -ForegroundColor DarkGreen
Set-StrictMode -Version 3.0