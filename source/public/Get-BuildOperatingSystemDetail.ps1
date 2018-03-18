#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-BuildOperatingSystemDetail {
    <#
    .SYNOPSIS
        Gets the operating system of the build system.
    .DESCRIPTION
        Gets the operating system of the build system in the following formt:

            - OSName - name of the operating system (Microsoft Windows 10 Pro)
            - OSArchitecture - x86 or x64 (64-bit)
            - Version - Version number (10.0.16299)

        The function is essentially a wrapper around Get-CimInstance
        win32_operatingsystem.
    .EXAMPLE
        Get-BuildOperatingSystem

        Returns the name, architecture and version of the current operating system.
    .OUTPUTS
        [PSObject]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
    .LINK
        Get-BuildPowerShellDetail
    .LINK
        Get-BuildEnvironment
    .LINK
        Get-BuildSystemEnvironment
    #>
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param ()

    Get-CimInstance -ClassName win32_operatingsystem -Property Caption, OSArchitecture, Version | `
        Select-Object -Property @{l = 'OSName'; e = {$_.Caption} }, OSArchitecture, Version
}
