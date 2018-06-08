try {
    Write-Output "Installing SQLMDR"
    Import-Module .\SQLMDR\SQLMDR.psd1
    Write-Output "Installed SQLMDR"
}
catch {
    Write-Error "Failed to Import SQLMDR $($_)"
}

$testResults = Invoke-Pester .\Tests `
    -ExcludeTag Integration,IntegrationTests `
    -Show None `
    -OutputFile .\Test-Pester.XML `
    -OutputFormat NUnitXml `
    -PassThru
if ($testResults.failedCount -ne 0) {
    Write-Error "Pester returned errors"
}