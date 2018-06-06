@{
    Commands = @(
        @{
            Module = 'Module1'
            Name = 'ServerCommand1'
            Category = 'Server'
            Frequency = 'Daily'
            Enabled = $true
        },
        @{
            Module = 'Module1'
            Name = 'ServerCommand2'
            Category = 'Server'
            Frequency = 'Daily'
            Enabled = $true
        },
        @{
            Module = 'Module1'
            Name = 'InstanceCommand1'
            Category = 'Instance'
            Frequency = 'Daily'
            Enabled = $true
        },
        @{
            Module = 'Module2'
            Name = 'DatabaseCommand1'
            Category = 'Database'
            Frequency = 'Hourly'
            Enabled = $true
        },
        @{
            Module = 'Module2'
            Name = 'DisabledCommand1'
            Category = 'Server'
            Frequency = 'Hourly'
            Enabled = $false
        },
        @{
            Module = 'Module2'
            Name = 'DisabledCommand2'
            Category = 'Server'
            Frequency = 'Monthly'
            Enabled = $false
        }
        @{
            Module = 'DisableByModule'
            Name = 'DisableByModuleCmd1'
            Category = 'Server'
            Frequency = 'Daily'
            Enabled = $true
        },
        @{
            Module = 'DisableByModule'
            Name = 'DisableByModuleCmd2'
            Category = 'Server'
            Frequency = 'Daily'
            Enabled = $true
        }
    )
}