#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-PowerShellGalleryVersion {
    <#
    .SYNOPSIS
        Gets the version of the module in the POwerShell Gallery.
    .DESCRIPTION
        Gets the version of the module in the POwerShell Gallery.
    .EXAMPLE
        Get-PowerShellGalleryVersion -Name 'MyModule'

        Gets the latest version of the module 'mymodule' listed in the PowerShell Gallery.
    .OUTPUTS
        [Version]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
    .LINK
        Get-NextReleaseVersion
    .LINK
        Get-ManifestVersion
    .LINK
        Get-ChangelogVersion
    #>
    [OutputType([Version])]
    [CmdletBinding()]
    Param (
        # Name of the module.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )

    # get the version from the PowerShell Gallery
    try {
        Write-Verbose "Getting the latest version of '$Name' from the PowerShell Gallery."
        [version](Find-Module -Name $Name -ErrorAction Stop).Version
    }
    catch {
        Write-Verbose "Did not find module '$Name' in the PowerShell Gallery."
        [version]'0.0.0'
    }
}