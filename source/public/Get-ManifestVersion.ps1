#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-ManifestVersion {
    <#
    .SYNOPSIS
        Gets the version from the module manifest.
    .DESCRIPTION
        Gets the version from the module manifest.
    .EXAMPLE
        Get-ManifestVersion -Path 'c:\temp\mymodule.psd1'
    .OUTPUTS
        [Version]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
    .LINK
        Get-PowerShellGalleryVersion
    .LINK
        Get-NextReleaseVersion
    .LINK
        Get-ChangelogVersion
    #>
    [OutputType([Version])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path -Path $_})]
        [string]$Path
    )

    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }

    # get the version from the manifest
    try {
        Write-Verbose "Getting the version from the manifest at '$Path'."
        [version](Get-MetaData -Path $Path -PropertyName ModuleVersion -ErrorAction Stop)
    }
    catch {
        [version]'0.0.0'
    }
}