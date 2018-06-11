function Get-MdrInstance {
    $type = Get-PSFConfig -FullName 'sqlmdr.server.type'
    $source = Get-PSFConfig -FullName 'sqlmdr.server.source'
    Write-PSFMessage -Level 'Verbose' -Message "Getting instances from [$($type.Value)] $($source.Value)"

    $servers = switch ($type.Value) {
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
            $registeredServers = Get-DbaRegisteredServer -SqlInstance $source.Value
            foreach ($registeredServer in $registeredServers) {
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

    return $servers
}