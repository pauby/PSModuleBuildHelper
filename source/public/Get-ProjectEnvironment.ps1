#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-ProjectEnvironment {
    <#
    .SYNOPSIS
        Get the properties of the project environment.
    .DESCRIPTION
        Get the properties of the project in the current location.
    .EXAMPLE
        Get-ProjectEnvironment

        Gets the project environment for the current location.
    .OUTPUTS
        [PSObject]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release

        The idea came from the Indented.Build project
        (https://github.com/indented-automation/Indented.Build) and heavily
        modified. Credit should be given to that project.
    .LINK
        Get-BuildEnvironment
    .LINK
        Get-TestEnvironment
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseConsistentWhitespace", "", Justification = "Causes issue with the large hash table")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAlignAssignmentStatement", "", Justification = "Causes issue with the large hash table")]
    [OutputType([PSObject])]
    [CmdletBinding()]
    Param ()

    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }

    $projectRoot = Get-ProjectRoot
    $sourcePath = Get-SourcePath -ProjectRoot $projectRoot

    # test path
    try {
        $testPath = (Get-ChildItem (Join-Path -Path $projectRoot -ChildPath 'test*') -Directory | `
                Select-Object -First 1).ToString()
    }
    catch {
        Write-Warning 'We have no tests folder!'
    }

    [PSCustomObject]@{
        ModuleName              = Split-Path -Path $projectRoot -Leaf

        BuildSystem             = Get-BuildSystem

        ProjectRootPath         = $projectRoot
        SourcePath              = $sourcePath
        BuildRootPath           = Join-Path -Path $projectRoot -ChildPath 'releases'
        OutputPath              = Join-Path -Path $projectRoot -ChildPath 'output'
        TestPath                = $testPath
    }
}