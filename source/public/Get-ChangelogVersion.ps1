#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-ChangelogVersion {
    <#
    .SYNOPSIS
        Gets the version from the changelog.
    .DESCRIPTION
        Gets the version from the changelog. 
    .EXAMPLE
        Get-ChangelogVersion -Path 'c:\mymodule\chaneglog.md'

        This will return the first version listed in your changelog that matches the default regular expression.
    .EXAMPLE
        'Value1', 'Value2' | <FUNCTION>
    .INPUTS
        [String]
    .OUTPUTS
        [PSObject]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
    .LINK
        Get-PowerShellGalleryVersion
    .LINK
        Get-NextReleaseVersion
    #>

    [OutputType([Version])]
    [CmdletBinding()]
    Param (
        # Path to the changelog.
        [Parameter(Mandatory)]
        [ValidateScript ( { Test-Path $_ } )]
        [string]
        $Path,

        # Regular expression to match the version. This assumes that the format
        # of your changelog (in Markdown) versions are:
        #
        # 'hash'hash' v1.0.0 Some text
        # 'hash'hash' v0.9.0 Some more text
        #
        # This will then return the version as 1.0.0. Note that becasue the help
        # files are in Markdown I cannot type a double hash (which is a pound in
        # the US). So 'hash' is '#'
        [string]
        $VersionRegex = '##\s+v(\d+\.\d+\.\d+)'
    )

    # get the version from the changelog.md if we have one
    switch -Regex -File ($Path) {
        $VersionRegex {
            return [version]$Matches[1]
        }
    } # end switch

    # if we get here we did not find the version
    [version]'0.0.0'
}