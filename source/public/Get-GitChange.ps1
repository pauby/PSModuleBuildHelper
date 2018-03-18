#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-GitChange {
    <#
    .SYNOPSIS
        Gets the git unstaged changed files in the local
    .DESCRIPTION
        Gets a list of hte changed files in the local repository. Only the file
        names are returned not their change status (deleted, modified, unstaged
        etc.)
    .EXAMPLE
        Get-GitChange

        Gets the lilst of git changed files in the current repository.
    .OUTPUTS
        [String[]]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby) History : 1.0 -
        15/03/18 - Initial release
    .LINK
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "", Justification = "This will eventually be rewritten")]
    [CmdletBinding()]
    [OutputType([String[]])]
    Param ()

    # todo this really needs rewritten to use something other than the local git command
    @(Invoke-Expression -Command 'git status -s') | ForEach-Object { 
        if ($_ -match '\S*$') { 
            $matches[0] 
        }
    }
}