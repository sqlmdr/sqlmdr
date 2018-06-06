$moduleManifestName = 'SQLMDR\SQLMDR.psd1'
$moduleManifestPath = "$PSscriptRoot\..\$moduleManifestName"
Import-Module -FullyQualifiedName $moduleManifestPath -Force