#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-BuildPowerShellDetail {
    <#
    .SYNOPSIS
        Return the $PSVersionTable as an object.
    .DESCRIPTION
        Return the $PSVersionTable as an object.
    .EXAMPLE
        Get-BuildPowerShellDetail

        Returns the $PSVersionTable as a PSObject.
    .OUTPUTS
        [PSObject]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
    .LINK
        Get-BuildOperatingSystemDetail
    .LINK
        Get-BuildEnvironment
    .LINK
        Get-BuildEnvironmentDetail
#>

    [CmdletBinding()]
    [OutputType([PSObject])]
    Param ()

    New-Object -TypeName PSObject -Property $PSVersionTable
}