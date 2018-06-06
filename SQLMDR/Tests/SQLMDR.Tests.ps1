$ModuleManifestName = 'SQLMDR.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

Describe 'Module Manifest Tests' {
    Context 'Strict mode' {
        Set-StrictMode -Version 3.0

        It 'Should load' {
            $Module = Get-Module $ENV:BHProjectName
            $Module.Name | Should be $ENV:BHProjectName
        }
    }

    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}