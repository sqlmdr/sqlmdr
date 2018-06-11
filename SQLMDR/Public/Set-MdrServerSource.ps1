function Set-MdrServerSource {
    [CmdletBinding(DefaultParameterSetName = 'CMS')]
    param (
        [ValidateSet('CMS', 'CSV')]
        [string] $SourceType,

        [Parameter(ParameterSetName = 'CMS')]
        [ValidateScript({ Connect-DbaInstance -SqlInstance $_ })]
        [string[]] $CmsServer,

        [Parameter(ParameterSetName = 'CSV')]
        [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
        [string] $FilePath
    )

    process {
        Set-PSFConfig -FullName 'sqlmdr.server.type' -Value $SourceType

        switch ($PSCmdlet.ParameterSetName) {
            'CMS' {
                $source = $CmsServer
            }

            'CSV' {
                $source = $FilePath
            }
        }

        Set-PSFConfig -FullName 'sqlmdr.server.source' -Value $source
    }
}