function Get-ReleaseType {
    <#
    .SYNOPSIS
        Gets the release type from the last commit message.
    .DESCRIPTION
        Gets the release type from the last commit message. The message should start with:

            - 'Major release'   : 'Major' release type
            - 'Minor release'   : 'Minor' release type
            - 'Release'         : 'Build' release type
            - None of the above : 'None' release type
    .EXAMPLE
        Get-ReleaseType -CommitMessage ''

        Gets' the release type ofr an empty commit message - this will be [ReleaseType]::None
    .OUTPUTS
        [ReleaseType]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
    .LINK
        Get-GitLastCommitMessage
    .LINK
        Get-GitLastCommitHash
    .LINK
        Get-GitBranchName
#>
    [OutputType([ReleaseType])]
    [CmdletBinding()]
    Param (
        # The commit message to be used to determine the release type.
        # The message should start with:
        #
        #  - 'Major release'   : [ReleaseType]::Major release type
        #  - 'Minor release'   : [ReleaseType]::Minor release type
        #  - 'Release'         : [ReleaseType]::Build release type
        #  - None of the above : [ReleaseType]::None release type
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$CommitMessage
    )

    switch -Regex ($CommitMessage) {
        '^Major release' {
            Write-Verbose "Commit message contains 'Major release'. ReleaseType is 'Major'."
            [ReleaseType]::Major
        }
        '^Minor release' {
            Write-Verbose "Commit message starts with 'Minor release'. Release type is 'Minor'."
            [ReleaseType]::Minor
        }
        '^Release' {
            Write-Verbose "Commit message contains 'Release'. Release type is 'Build'"
            [ReleaseType]::Build
        }
        default {
            Write-Verbose "Commit message does not contain any release types. Release type is 'None'"
            [ReleaseType]::None
        }
    }
}