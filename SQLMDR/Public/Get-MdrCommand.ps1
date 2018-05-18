function Get-MdrCommand {
    [CmdletBinding()]
    param (
        [string] $Module,

        [string[]] $Name,

        [ValidateSet('Server', 'Instance', 'Database')]
        [string] $Category,

        [switch] $Enabled
    )

    process {
        # get the existing registered commands
        $registeredCommands = Get-PSFConfig -FullName 'sqlmdr.commands'
        if (-not $registeredCommands) {
            Write-PSFMessage -Level 'Verbose' -Message ('No registered commands yet - initializing a new array')
            $registeredCommands = @()
        } else {
            $registeredCommands = $registeredCommands.Value
        }

        if ($Module) {
            $registeredCommands = $registeredCommands | Where-Object { $_.Module -in $Module }
        }

        if ($Name) {
            $registeredCommands = $registeredCommands | Where-Object { $_.Name -in $Name }
        }

        if ($Category) {
            $registeredCommands = $registeredCommands | Where-Object { $_.Category -in $Category }
        }

        if ($PSBoundParameters.ContainsKey('Enabled')) {
            $registeredCommands = $registeredCommands | Where-Object { $_.Enabled -eq $Enabled }
        }

        return $registeredCommands
    }
}