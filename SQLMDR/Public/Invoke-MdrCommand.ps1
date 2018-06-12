function Invoke-MdrCommand {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Server')]
        $ComputerName,

        [Parameter(ParameterSetName = 'Instance')]
        $SqlInstance,

        [Parameter(ParameterSetName = 'Database')]
        $Database,

        [Parameter()]
        [System.Management.Automation.FunctionInfo] $Command
    )


}