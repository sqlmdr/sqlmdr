function Enable-MdrCommand {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Module,

        [Parameter()]
        [string] $Name
    )

    process {
        Set-MdrCommand @PSBoundParameters -Enable
    }
}