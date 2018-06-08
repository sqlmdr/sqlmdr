function Register-MdrCommand {
    [CmdletBinding()]
    param (
        [string] $Module,

        [string[]] $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Server', 'Instance', 'Database')]
        [string] $Category,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Hourly', 'Daily', 'Weekly', 'Monthly')]
        [string] $Frequency,

        [switch] $Disable
    )

    process {
        # get the existing registered commands
        $registeredCommands = Get-MdrCommand
        if (-not $registeredCommands) {
            Write-PSFMessage -Level 'Verbose' -Message ('No registered commands yet - initializing a new array')
            $registeredCommands = @()
        } else {
            $registeredCommands = $registeredCommands.Value
        }
        Write-PSFMessage -Level 'Verbose' -Message "Existing commands $($registeredCommands.Count)"

        $params = @{}
        if ($Module) {
            Write-PSFMessage -Level 'Verbose' -Message "Passed in module $Module"
            $params['Module'] = $Module
        }

        if ($Name) {
            Write-PSFMessage -Level 'Verbose' -Message "Passed in name $Name"
            $params['Name'] = $Name
        }

        # make sure it's not a duplicate
        $registeredCommand = Get-MdrCommand @params -Category $Category
        if ($registeredCommand) {
            throw ("Command is already registered")
        } else {
            Write-PSFMessage -Level 'Verbose' -Message 'Command not registered, OK to register'
        }

        # get the command from posh
        $commands = Get-Command @params -ErrorAction 'SilentlyContinue'
        if ($commands.Count -eq 0) {
            throw 'Unknown command'
        }

        Write-PSFMessage -Level 'Verbose' -Message "Found $($commands.Count) matching commands"

        # create the registered command objects
        $newRegisteredCommands = @()
        foreach ($command in $commands) {
            if ($Disable.IsPresent) {
                $enabled = $false
            } else {
                $enabled = $true
            }

            Write-Verbose ('Command module: ' + $command.Module)
            Write-Verbose ('Command module name: ' + $command.Module.Name)

            $newRegisteredCommands += [PSCustomObject] @{
                Module = $command.Module.Name
                Name = $command.Name
                Category = $Category
                Frequency = $Frequency
                Enabled = $enabled
            }
        }

        # save the registered commands
        Write-PSFMessage -Level 'Verbose' -Message "Registering $($newRegisteredCommands.Name -join ', ')"

        $null = Set-PSFConfig -FullName 'sqlmdr.commands' -Value ($registeredCommands + $newRegisteredCommands)

        return $newRegisteredCommands
    }
}