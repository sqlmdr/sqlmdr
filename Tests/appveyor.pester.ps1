<#

.SYNOPSIS
This script will invoke Pester tests, then serialize XML results and pull them in appveyor.yml

.PARAMETER Finalize
If Finalize is specified, we collect XML output, upload tests, and indicate build errors

.PARAMETER IncludeCoverage
Calculates coverage and sends it to codecov.io

#>
param(
    [switch] $Finalize,
    [switch] $IncludeCoverage
)

#Initialize some variables, move to the project root
$PSVersion = $PSVersionTable.PSVersion.Major
$TestFile = "TestResultsPS$PSVersion.xml"
$ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
$ModuleBase = "$ProjectRoot\SQLMDR"
Set-Location $ProjectRoot

function Get-CodecovReport($Results, $ModuleBase) {
    #handle coverage https://docs.codecov.io/reference#upload
    $report = @{'coverage' = @{}}
    #needs correct casing to do the replace
    $ModuleBase = (Resolve-Path $ModuleBase).Path
    # things we wanna a report for (and later backfill if not tested)
    $allfiles = Get-ChildItem -File -Path $ModuleBase -Filter '*.ps1'

    $missed = $results.CodeCoverage | Select-Object -ExpandProperty MissedCommands | Sort-Object -Property File, Line -Unique
    $hits = $results.CodeCoverage | Select-Object -ExpandProperty HitCommands | Sort-Object -Property File, Line -Unique
    $LineCount = @{}
    $hits | ForEach-Object {
        $filename = $_.File.Replace("$ModuleBase\", '').Replace('\', '/')
        if ($filename -notin $report['coverage'].Keys) {
            $report['coverage'][$filename] = @{}
            $LineCount[$filename] = (Get-Content $_.File -Raw | Measure-Object -Line).Lines
        }
        $report['coverage'][$filename][$_.Line] = 1
    }

    $missed | ForEach-Object {
        $filename = $_.File.Replace("$ModuleBase\", '').Replace('\', '/')
        if ($filename -notin $report['coverage'].Keys) {
            $report['coverage'][$filename] = @{}
            $LineCount[$filename] = (Get-Content $_.File | Measure-Object -Line).Lines
        }
        if ($_.Line -notin $report['coverage'][$filename].Keys) {
            #miss only if not already covered
            $report['coverage'][$filename][$_.Line] = 0
        }
    }

    $newreport = @{'coverage' = [ordered]@{}}
    foreach ($fname in $report['coverage'].Keys) {
        $Linecoverage = [ordered]@{}
        for ($i = 1; $i -le $LineCount[$fname]; $i++) {
            if ($i -in $report['coverage'][$fname].Keys) {
                $Linecoverage["$i"] = $report['coverage'][$fname][$i]
            }
        }
        $newreport['coverage'][$fname] = $Linecoverage
    }

    #backfill it
    foreach ($target in $allfiles) {
        $target_relative = $target.FullName.Replace("$ModuleBase\", '').Replace('\', '/')
        if ($target_relative -notin $newreport['coverage'].Keys) {
            $newreport['coverage'][$target_relative] = @{"1" = $null}
        }
    }
    $newreport
}

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

    if ($IncludeCoverage.IsPresent) {
        $codeCoveragePaths = Get-ChildItem $ModuleBase -File -Recurse -Include '*.ps1'

        $pesterParameters['CodeCoverage'] = $codeCoveragePaths
        $pesterParameters['CodeCoverageOutputFile'] = "$ProjectRoot\PesterCoverage$PSVersion.xml"
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

        if ($IncludeCoverage) {
            $codecovReport = Get-CodecovReport -Results $results -ModuleBase $ModuleBase
            $codecovReport | ConvertTo-Json -Depth 4 -Compress | Out-File -FilePath "$ProjectRoot\PesterResultsCoverage.json" -Encoding 'utf8'

            Write-Host -Object "appveyor.post: Sending coverage data" -ForeGroundColor DarkGreen
            Push-AppveyorArtifact "$ProjectRoot\PesterResultsCoverage.json" -FileName "PesterResultsCoverage"
            codecov -f "$ProjectRoot\PesterResultsCoverage.json" | Out-Null
        }
}