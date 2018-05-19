@(
    @{
        Module = 'Module1'
        Name = 'ServerCommand1'
        Category = 'Server'
        Enabled = $true
    },
    @{
        Module = 'Module1'
        Name = 'ServerCommand2'
        Category = 'Server'
        Enabled = $true
    },
    @{
        Module = 'Module1'
        Name = 'InstanceCommand1'
        Category = 'Instance'
        Enabled = $true
    },
    @{
        Module = 'Module2'
        Name = 'DatabaseCommand1'
        Category = 'Database'
        Enabled = $true
    },
    @{
        Module = 'Module2'
        Name = 'DisabledCommand1'
        Category = 'Server'
        Enabled = $false
    }
)