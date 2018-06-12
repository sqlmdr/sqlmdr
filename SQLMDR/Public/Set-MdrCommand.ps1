<#
.SYNOPSIS
Updates settings for a registered command.

.DESCRIPTION
Updates settings for a command that has been previously registered with SQLMDR.

.PARAMETER Module
Enter the name of a module or snap-in.

.PARAMETER Name
Enter a name.

.PARAMETER Category
Parameter description

.PARAMETER Frequency
Parameter description

.PARAMETER Enable
Parameter description

.PARAMETER Disable
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Set-MdrCommand {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="Added tests, future implementation")]
    [CmdletBinding(DefaultParameterSetName = 'EnableCommand')]
    param (
        [Parameter()]
        [string] $Module,

        [Parameter()]
        [string[]] $Name,

        [Parameter()]
        [ValidateSet('Server', 'Database', 'Instance')]
        [string] $Category,

        [Parameter()]
        [ValidateSet('Hourly', 'Daily', 'Weekly', 'Monthly')]
        [string] $Frequency,

        [Parameter(ParameterSetName='EnableCommand')]
        [switch] $Enable,

        [Parameter(ParameterSetName='DisableCommand')]
        [switch] $Disable
    )

    process {
        $registeredCommands = Get-MdrCommand

        $params = @{}
        if ($Module) {
            $params['Module'] = $Module
        }
        if ($Name) {
            $params['Name'] = $Name
        }

        $updatedCommands = Get-MdrCommand @params
        if (-not $updatedCommands) {
            throw "Command not registered"
        }

        foreach ($updatedCommand in $updatedCommands) {
            $command = $registeredCommands | Where-Object {
                $_.Module -eq $updatedCommand.Module -and
                $_.Name -eq $updatedCommand.Name -and
                $_.Category -eq $updatedCommand.Category
            }

            if ($Category) {
                $command.Category = $Category
            }

            if ($Frequency) {
                $command.Frequency = $Frequency
            }

            if ($PSBoundParameters.ContainsKey('Enable')) {
                $command.Enabled = $true
            }

            if ($PSBoundParameters.ContainsKey('Disable')) {
                $command.Enabled = $false
            }
        }

        Set-PSFConfig -FullName 'sqlmdr.commands' -Value $registeredCommands
    }
}