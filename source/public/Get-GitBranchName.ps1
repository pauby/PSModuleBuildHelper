#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-GitBranchName {
    <#
    .SYNOPSIS
        Get the name of the current branch.
    .DESCRIPTION
        Get the name of the current branch.
    .EXAMPLE
        Get-GitBranchName

        Returns the current branch name for the current repo.
    .OUTPUTS
        [String]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
    .LINK
    #>

    [CmdletBinding()]
    [OutputType([String])]
    Param ()

    $branch = git rev-parse --abbrev-ref HEAD 2>&1
    if (-not $?) {
        throw 'Cannot determine the current git branch.'
    }

    $branch
}