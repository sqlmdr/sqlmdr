$scriptsModules = Get-ChildItem -Include *.psd1, *.psm1, *.ps1 -Exclude *.Tests.ps1 -Recurse

Describe 'PSScriptAnalyzer' {
	Context "Checking files to test exist and Invoke-ScriptAnalyzer cmdLet is available" {
		It "Checking files exist to test." {
            $scriptsModules.Count | Should -BeGreaterThan 0
		}
		It "Checking Invoke-ScriptAnalyzer exists." {
			{ Get-Command Invoke-ScriptAnalyzer -ErrorAction Stop } | Should Not Throw
		}
	}

	$scriptAnalyzerRules = Get-ScriptAnalyzerRule

	forEach ($scriptModule in $scriptsModules) {
		switch -wildCard ($scriptModule) {
			'*.psm1' { $typeTesting = 'Module' }
			'*.ps1'  { $typeTesting = 'Script' }
			'*.psd1' { $typeTesting = 'Manifest' }
		}

        Context "$scriptModule conforms to Script Analyzer Rules" {
            foreach ($rule in $scriptAnalyzerRules) {
                It "$rule" {
                    (Invoke-ScriptAnalyzer -Path $scriptModule -IncludeRule $rule).Count | Should Be 0
                }
            }
        }
    }
}