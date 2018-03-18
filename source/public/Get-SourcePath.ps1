#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-SourcePath {
    <#
    .SYNOPSIS
        Gets the source path of the module.
    .DESCRIPTION
        Gets the source path of the module under the project root. The source
        path can be called any one of the following:

            - source
            - src
            - <NAME>\<NAME>.psd1

        Note that the last one is simply a parent folder whose name is the same
        name as the manifest within it.
    .EXAMPLE
        Get-SourcePath -Path 'c:\mymodule'

        Gets the path to the module source under 'c:\mymodule'
    .OUTPUTS
        [System.IO.DirectoryInfo], [System.IO.DirectoryInfo[]]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby) History : 1.0 -
        15/03/18 - Initial release

        Note that this function was lifted from teh Indented.Build module
        (https://github.com/indented-automation/Indented.Build) and modified to
        allow 'source' and 'src' folders to be used and replaced Push- and
        Pop-Location with Set-Location as Invoke-Build recommends not using
        those cmdlets. All credit should be given to that project.
    .LINK
        Get-BuildSystem
    .LINK
        Get-BuildEnvironment
    .LINK
        Get-ProjectRoot
    #>

    [CmdletBinding()]
    [OutputType([String])]
    Param (
        # Root path for the project.
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$ProjectRoot
    )

    if (Test-Path (Join-Path -Path $ProjectRoot -ChildPath (Split-Path -Path $ProjectRoot -Leaf))) {
        return (Join-Path -Path $ProjectRoot -ChildPath (Split-Path -Path $ProjectRoot -Leaf))
    }
    else {
        $folders = 'src', 'source'
        ForEach ($folder in $folders) {
            $sourcePath = Join-Path -Path $ProjectRoot -ChildPath $folder
            if (Test-Path $sourcePath) {
                return $sourcePath
            }
        } #end foreach-object
    } # end else

    # we get here we have found nothing
    throw 'Unable to determine the source path'
}