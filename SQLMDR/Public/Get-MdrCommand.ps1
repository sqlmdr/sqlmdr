function Get-MdrCommand {
    [CmdletBinding()]
    param (
        [string] $Module,

        [string[]] $Name,

        [ValidateSet('Server', 'Instance', 'Database')]
        [string] $Category
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
            $registeredCommands = $registeredCommands | Where-Object { $_.Module -eq $Module }
        }

        if ($Name) {
            $registeredCommands = $registeredCommands | Where-Object { $_.Name -in $Name }
        }

        if ($Category) {
            $registeredCommands = $registeredCommands | Where-Object { $_.Category -eq $Category }
        }

        return $registeredCommands
    }
}