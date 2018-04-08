#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-BuildReleaseNote {
    <#
    .SYNOPSIS
        Gets the release notes from a file.
    .DESCRIPTION
        Gets the release notes for this version from a file.

        The file can be in markdown format or normal text. The format MUST be:

            ## v0.2
            * Some release notes

            ## v0.0.5
            Some more release notes

        Or:

            v0.1
            Some release notes.

            v0.0.4
            Some more release notes

        Note the empty line bwteen the versions and no empty line between the
        version number and the release notes for that version.

        If using the markdown version (using ## at the start of the version
        number), they will be removed as the release notes shuld be simple text.
        Anything else will be retained.
    .EXAMPLE
        Get-BuildReleaseNote -Path 'CHANGELOG.md' -Version '0.0.2'

        Gets the build release notes for version 0.0.2 from CHANGELOG.md
    .OUTPUTS
        [String]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby) 
        History : 1.0 - 06/04/18 - Initial release
    .LINK
        Get-BuildEnvironment
    #>
    [OutputType([String])]
    [CmdletBinding()]
    Param (
        # The path to file containing the release notes.
        [Parameter(Mandatory)]
        [String]
        [ValidateScript( { Test-Path $_ })]
        $Path,

        # Version number to return the notes for.
        [Parameter(Mandatory)]
        [ValidateScript( { try { [version]$_ } catch { return $false } $true } )]
        [string]
        $Version
    )

    if ((Get-Content $Path -Raw) -match "(?ms)^#*\s*(?<ReleaseNotes>v$Version(.+?)\r\n\S*\r\n)") {
        Write-Verbose "Found release notes for version '$Version'"
        $matches.ReleaseNotes.Trim()
    }
    else {
        Write-Verbose "Didn't find release notes for version '$Version'"
        ''
    }
}