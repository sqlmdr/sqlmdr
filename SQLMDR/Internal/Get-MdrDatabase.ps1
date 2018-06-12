function Get-MdrDatabase {
    [CmdletBinding()]
    param (
        [Parameter()]
        $ComputerName,

        [Parameter()]
        $SqlInstance
    )

    $instances = Get-MdrInstance @PSBoundParameters
    $databases = Get-DbaDatabase -SqlInstance $instances.SqlInstance

    return $databases
}