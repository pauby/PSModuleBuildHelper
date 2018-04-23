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

        Note the empty line between the versions and no empty line between the
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
        Project : PSModuleBuildHelper (https://github.com/pauby/psmodulebuildhelper)
        History : 1.0 - 06/04/18 - Initial release
                  1.1 - 21/04/18 - Rewrote the function as I could not find a good
                                   enough regex to do the job. It looks clunky but
                                   it works.
                  2.0 - 23/04/18 - The version number line is not included by
                                   default so added a parameter to include it. Fixed
                                   issue where newlines were being added at the end
                                   of the notes.
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
        $Version,

        # Include the line containing the version number in the notes
        [switch]
        $IncludeVersionLine
    )

    # number of matched lines
    $matched = 0

    # loop through each line in the $path until we find a matching 'v$Version'
    # one we do keep each line until we come to either a blank line or the end
    # of the file
    $content = (Get-Content -Path $Path).Trim()
    foreach ($line in $content) {
        if ($matched -gt 0) {
            if ([string]::ISNullOrEmpty($line)) {
                return $notes
            } 
            elseif ($matched -eq 1) {
                $notes += $line
            }
            else {
                $notes += "`r`n$line"
            }
            $matched++
        }
        else {
            if ($line -match "v$Version") {
                Write-Verbose "Found version '$Version' in '$Path'."
                $matched++

                if ($IncludeVersionLine.IsPresent) {
                    # remove any '#' from markdown
                    if ($line -match "^#*\s*(?<notes>.*)") {
                        $notes += $matches.notes
                    }
                    else {
                        $notes += $line
                    }

                    $notes += "`r`n"
                }
            }
        }
    }

    $notes
}