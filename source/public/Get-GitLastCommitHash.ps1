#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-GitLastCommitHash {
    <#
    .SYNOPSIS
        Gets the hash of the last commit.
    .DESCRIPTION
        Gets the hash of the last commit.
    .EXAMPLE
        Get-GitLastCommitHash

        Gets the hash of hte last commit for the current branch and repo.
    .OUTPUTS
        [String]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
    .LINK
    #>

    [CmdletBinding()]
    [OutputType([String])]
    param ()

    $hash = git log -1 --pretty=%H 2>&1
    if (-not $?) {
        throw 'There are no commits.'
    }
    else {
        ($hash | Where-Object { $_ } | Out-String).Trim()
    }
}