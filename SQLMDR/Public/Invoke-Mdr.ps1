function Invoke-Mdr {
    [CmdletBinding()]
    param (
        [Parameter()]
        $ComputerName,

        [Parameter()]
        $SqlInstance,

        [Parameter()]
        $Database
    )

    process {
        # get registered commands
        $serverCommands = Get-MdrCommand -Category 'Server' -Enabled
        $instanceCommands = Get-MdrCommand -Category 'Instance' -Enabled
        $databaseCommands = Get-MdrCommand -Category 'Database' -Enabled

        $servers = Get-MdrServer
        foreach ($server in $servers) {
            Write-PSFMessage -Level 'Verbose' -Message "Processing server $server"

            Invoke-MdrCommand -ComputerName $server -Command $serverCommands

            $instances = Get-MdrInstance -ComputerName $server
            foreach ($instance in $instances) {
                Write-PSFMessage -Level 'Verbose' -Message "Processing instance $instance"

                Invoke-MdrCommand -SqlInstance $instance -Command $instanceCommands

                $databases = Get-MdrDatabase -SqlInstance $instance
                foreach ($database in $databases) {
                    Write-PSFMessage -Level 'Verbose' -Message "Processing database $database"

                    Invoke-MdrCommand -SqlInstance $instance -Database $database -Command $databaseCommands
                }
            }
        }
    }
}