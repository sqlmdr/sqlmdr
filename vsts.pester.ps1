try {
    Write-Output "Installing SQLMDR"
    Import-Module .\SQLMDR\SQLMDR.psd1
    Write-Output "Installed SQLMDR"
}
catch {
    Write-Error "Failed to Install SQLMDR $($_)"
}
$TestResults = Invoke-Pester .\Tests -ExcludeTag Integration,IntegrationTests -Show None -OutputFile $(Build.SourcesDirectory)\Test-Pester.XML -OutputFormat NUnitXml -PassThru

if ($TestResults.failedCount -ne 0) {
    Write-Error "Pester returned errors"
}