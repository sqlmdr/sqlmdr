function Get-MdrInstance {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $ComputerName,

        [Parameter()]
        [string] $SqlInstance
    )

    $type = Get-PSFConfig -FullName 'sqlmdr.server.type'
    $source = Get-PSFConfig -FullName 'sqlmdr.server.source'
    Write-PSFMessage -Level 'Verbose' -Message "Getting instances from [$($type.Value)] $($source.Value)"

    $instances = switch ($type.Value) {
        'CSV' {
            $data = Get-Content -Path $source.Value
            foreach ($row in $data) {
                $temp = $row.Split('\')
                if ($temp.Count -gt 1) {
                    [PSCustomObject] @{
                        ComputerName = $temp[0]
                        SqlInstance = $temp[1]
                    }
                }
                else {
                    [PSCustomObject] @{
                        ComputerName = $temp[0]
                        SqlInstance = $temp[0]
                    }
                }
            }
        }

        'CMS' {
            $registeredinstances = Get-DbaRegisteredServer -SqlInstance $source.Value
            foreach ($registeredServer in $registeredinstances) {
                $temp = $registeredServer.ServerName.Split('\')
                if ($temp.Count -gt 1) {
                    [PSCustomObject] @{
                        ComputerName = $temp[0]
                        SqlInstance = $temp[1]
                    }
                }
                else {
                    [PSCustomObject] @{
                        ComputerName = $temp[0]
                        SqlInstance = $temp[0]
                    }
                }
            }
        }
    }

    if ($PSBoundParameters.ContainsKey('ComputerName')) {
        Write-PSFMessage -Level 'Verbose' -Message "Filtering list of instances to ComputerName = $ComputerName"
        $instances = $instances | Where-Object { $_.ComputerName -eq $ComputerName }
    }

    if ($PSBoundParameters.ContainsKey('SqlInstance')) {
        Write-PSFMessage -Level 'Verbose' -Message "Filtering list of instances to SqlInstance = $SqlInstance"
        $instances = $instances | Where-Object { $_.SqlInstance -eq $SqlInstance }
    }

    return $instances
}