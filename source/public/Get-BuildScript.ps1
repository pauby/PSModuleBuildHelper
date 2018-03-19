#.ExternalHelp PSModuleBuildHelper-help.xml

$script:ModuleBuildScriptFilename = 'Start-ModuleBuild.ps1'
function Get-BuildScript {
    <#
    .SYNOPSIS
        Provides the full path to the module build script.
    .DESCRIPTION
        Provides the full path to the module build script that is held in the module folder.
    .EXAMPLE
        Get-BuildScript

        Returns the path to the Start-ModuleBuild.ps1
    .OUTPUTS
        [System.IO.FileInfo]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : v1.0 - 15/03/18 - Initial release
    .LINK
    #>

    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    Param()

    $rootPath = $PSScriptRoot
    if ((Split-Path -Path $rootPath -Leaf) -eq 'public') {
        $rootPath = Split-Path -Path $PSScriptRoot -Parent
    }

    # returns a [System.IO.FileInfo] object
    Get-Item -Path (Join-Path -Path $rootPath -ChildPath $script:ModuleBuildScriptFilename)
}