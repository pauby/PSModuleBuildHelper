#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-BuildSystemEnvironment {
    <#
    .SYNOPSIS
        Get the current build system environment variables.
    .DESCRIPTION
        Get the current build system environment variables. Primarily for use in a
        CI / CD build environments where it is useful to see.

        There is a default set of keywords that are searched for which can be
        replaced.

        The following CI / CD systems are supported:

            - AppVeyor
            - Unknown (retrieves ALL of the current environment variables)

        The data is returned as a PSObject.
    .EXAMPLE
        Get-BuildSystemEnvironment

        Returns the environment variables for the current build environment.
    .OUTPUTS
        [PSObject]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
    .LINK
        Get-BuildSystem
    .LINK
        Get-BuildEnvironment
    #>

    [CmdletBinding()]
    [OutputType([PSObject])]
    Param ()

    $envVars = switch (Get-BuildSystem) {
        'AppVeyor' {
            Get-Item env:APPVEYOR*
        }
        'Unknown' {
            Get-Item env:*
        }
    }

    # return the environment as an object
    $envObject = New-Object -TypeName psobject
    $envVars.GetEnumerator() | ForEach-Object { 
        $envObject | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value 
    } 
    $envObject
}