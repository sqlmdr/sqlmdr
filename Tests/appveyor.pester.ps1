param(
    [switch] $CodeCoverage,
    [switch] $Finalize
)

#Initialize some variables, move to the project root
$PSVersion = $PSVersionTable.PSVersion.Major
$TestFile = "TestResultsPS$PSVersion.xml"
$ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
Set-Location $ProjectRoot

# install required modules
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
        Install-Module -Name $requiredModule -Repository PSGallery -Force | Out-Null
        Import-Module -Name $requiredModule -Force
    } else {
        Write-Host -Object "$requiredModule is cached" -ForegroundColor DarkGreen
        Import-Module -Name $requiredModule -Force
    }
}

#Run a test with the current version of PowerShell
if(-not $Finalize)
{
    "`n`tSTATUS: Testing with PowerShell $PSVersion`n"

    $pesterParameters = @{
        Path = "$ProjectRoot\Tests"
        OutputFormat = 'NUnitXml'
        OutputFile = "$ProjectRoot\$TestFile"
        PassThru = $true
    }

    if ($CodeCoverage.IsPresent) {
        $codeCoveragePaths = @(
            "$ProjectRoot\SQLMDR"
        )

        $pesterParameters['CodeCoverage'] = $codeCoveragePaths
    }

    Invoke-Pester @pesterParameters |
        Export-Clixml -Path "$ProjectRoot\PesterResults$PSVersion.xml"
}

#If finalize is specified, check for failures and
else
{
    #Show status...
        $AllFiles = Get-ChildItem -Path $ProjectRoot\*Results*.xml | Select-Object -ExpandProperty FullName
        "`n`tSTATUS: Finalizing results`n"
        "COLLATING FILES:`n$($AllFiles | Out-String)"

    #Upload results for test page
        Get-ChildItem -Path "$ProjectRoot\TestResultsPS*.xml" | Foreach-Object {

            $Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
            $Source = $_.FullName

            "UPLOADING FILES: $Address $Source"

            (New-Object 'System.Net.WebClient').UploadFile( $Address, $Source )
        }

    #What failed?
        $Results = @( Get-ChildItem -Path "$ProjectRoot\PesterResults*.xml" | Import-Clixml )

        $FailedCount = $Results |
            Select-Object -ExpandProperty FailedCount |
            Measure-Object -Sum |
            Select-Object -ExpandProperty Sum

        if ($FailedCount -gt 0) {

            $FailedItems = $Results |
                Select-Object -ExpandProperty TestResult |
                Where-Object {$_.Passed -notlike $True}

            "FAILED TESTS SUMMARY:`n"
            $FailedItems | ForEach-Object {
                $Test = $_
                [pscustomobject]@{
                    Describe = $Test.Describe
                    Context = $Test.Context
                    Name = "It $($Test.Name)"
                    Result = $Test.Result
                }
            } |
                Sort-Object Describe, Context, Name, Result |
                Format-List

            throw "$FailedCount tests failed."
        }
}