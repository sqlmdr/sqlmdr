function Register-MdrCommand {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Module,

        [Parameter()]
        [string] $Name,

        [Parameter()]
        [ValidateSetAttribute('Server', 'Instance', 'Database')]
        [string] $Category
    )

    process {

    }
}