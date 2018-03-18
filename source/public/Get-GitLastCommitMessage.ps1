#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-GitLastCommitMessage {
    <#
    .SYNOPSIS
        Getsh the last Git commit message.
    .DESCRIPTION
        Gets the last Git commit message. If there are no messages to retrieve
        then it will throw and exception.

        Uses the 'git' command to retrieve the messages so this must be
        installed.
    .EXAMPLE
        Get-GitLastCommitMessage

        Returns the last commit message for the current branch and repo.
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

    $message = git log -1 --pretty=%B 2>&1
    if (-not $?) {
        throw 'There are no commit messages.'
    }
    else {
        ($message | Where-Object { $_ } | Out-String).Trim()
    }
}