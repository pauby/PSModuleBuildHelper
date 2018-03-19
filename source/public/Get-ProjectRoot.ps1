#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-ProjectRoot {
    <#
    .SYNOPSIS
        Gets the project root folder name.
    .DESCRIPTION
        Gets the project root folder name by looking for the git repo root
        folder. It uses the 'git' executable to do this so it must be installed.
    .EXAMPLE
        Get-ProjectRoot

        Returns the root folder for this project / git repository.
    .OUTPUTS
        [String]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release

        This function was lifted from the Indented.Build project
        (https://github.com/indented-automation/Indented.Build) and all credit
        for it should go to that project.
    .LINK
        Get-SourcePath
    #>
    [CmdletBinding()]
    [OutputType([String])]
    Param ()

    $path = git rev-parse --show-toplevel
    if ($null -eq $path) {
        throw 'Not a git repository - cannot provide project root'
    }
    else {
        (Get-Item $path).FullName
    }
}