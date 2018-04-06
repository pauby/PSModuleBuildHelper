#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-BuildEnvironment {
    <#
    .SYNOPSIS
        Get properties required to build the project.
    .DESCRIPTION
        Get the properties required to build the project, or elements of the
        project.

        All areas of the build process takes it's details from the data produced
        by this function. To influence part of the build process the data
        produced only need be altered.
    .EXAMPLE
        Get-BuildEnvironment

        Get build information for the current or any child directories.
    .OUTPUTS
        [PSObject]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
                  1.1 - 04/04/18 - Added CodeCoverageThreshold parameter

        The idea came from the Indented.Build project
        (https://github.com/indented-automation/Indented.Build) and heavily
        modified. Credit should be given to that project.
    .LINK
        Get-ProjectEnvironment
    .LINK
        Get-TestEnvironment
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "", Justification = "Easiest way of jumping out of the block when one fails")]
    [OutputType([PSObject])]
    [CmdletBinding()]
    Param (
        # The type of release we should be building. If this is 'Unknown' then
        # the release type will be deteremined from the commit message.
        [String]
        [ValidateSet( 'Major', 'Minor', 'Build', 'None', 'Unknown' )]
        $ReleaseType,

        # The GitHub Username that has write access to this repo.
        [string]
        $GitHubUsername = '',

        # The GitHub Api Key that has write access to this repo.
        [string]
        $GitHubApiKey = '',

        # The PowerShell Gallery key for publishing the module.
        [string]
        $PSGalleryApiKey = '',

        # Filename of the PowerShell ScriptAnalyzer settings file. This file
        # will be searched for under the project root.
        [string]
        $PSSASettingsName = 'PSScriptAnalyzerSettings.psd1',

        # The PowerShell ScriptAnalyzer Custom Rules folder. This folder will be
        # searched for under the project root and any .psd1 files found under
        # teh folder will be used.
        [string]
        $PSSACustomRulesFolderName = 'CustomAnalyzerRules',

        # The threshold that test code coverage must meet expressed between 0.01 to 1.00.
        [ValidateRange(0.01, 1.00)]
        [single]
        $CodeCoverageThreshold = 0.8
    )

    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }

    $buildInfo = Get-ProjectEnvironment 

    @(  'LatestVersion', 'ReleaseVersion', 'ReleaseType', 'PSGalleryApiKey', 'RepoBranch', 'RepoLastCommitHash', `
        'RepoLastCommitMessage', 'GitHubUsername', 'GitHubApiKey', 'SourceManifestPath', 'SourceModulePath', `
        'BuildPath', 'BuildManifestPath', 'BuildModulePath', 'PSSASettingsPath', 'PSSACustomRulesPath', `
        'BuildArtifactPath', 'CodeCoverageThreshold', 'ReleaseNotes', 'ReleaseNotesPath'
    ) | ForEach-Object {
        $buildInfo | Add-Member -MemberType NoteProperty -Name $_ -Value ''
    }

    # ReleaseType & PSGallery API Key
    if ([string]::IsNullOrEmpty($ReleaseType) -or $ReleaseType -eq 'Unknown') {
        Write-Verbose "Determining 'ReleaseType' from the last commit message."
        $buildInfo.ReleaseType = Get-ReleaseType -CommitMessage (Get-GitLastCommitMessage)
    } 
    else {
       $buildInfo.ReleaseType = $ReleaseType
    }
    $buildInfo.PSGalleryApiKey = $PSGalleryApiKey

    # Git
    $buildInfo.GitHubUsername = $GitHubUsername
    $buildInfo.GitHubApiKey = $GitHubApiKey

    try {
        $buildInfo.RepoBranch = Get-GitBranchName -ErrorAction SilentlyContinue
        $buildInfo.RepoLastCommitHash = Get-GitLastCommitHash -ErrorAction SilentlyContinue
        $buildInfo.RepoLastCommitMessage = Get-GitLastCommitMessage -ErrorAction SilentlyContinue
    }
    catch {
    }

    # Source Paths
    $buildInfo.SourceManifestPath = Join-Path -Path $buildInfo.SourcePath -ChildPath "$($buildInfo.ModuleName).psd1"
    $buildInfo.SourceModulePath = Join-Path -Path $buildInfo.SourcePath -ChildPath "$($buildInfo.ModuleName).psm1"

    # Versions
    if (Test-Path -Path $buildInfo.SourceManifestPath) {
        $buildInfo.LatestVersion = Get-ManifestVersion -Path $buildInfo.SourceManifestPath
        $buildInfo.ReleaseVersion = Get-NextReleaseVersion -LatestVersion $buildInfo.LatestVersion -ReleaseType $buildInfo.ReleaseType
    }
    else {
        throw "Source manifest '$($buildInfo.SourceManifestPath)' does not exist."
    }

    # Build paths
    $buildPath = Join-Path -Path (Join-Path -Path $buildInfo.ProjectRootPath -ChildPath 'releases') -ChildPath $buildInfo.ReleaseVersion
    $buildInfo.BuildPath = $buildPath
    $buildInfo.BuildManifestPath = Join-Path -Path $buildPath -ChildPath "$($buildInfo.ModuleName).psd1"
    $buildInfo.BuildModulePath = Join-Path -Path $buildPath -ChildPath "$($buildInfo.ModuleName).psm1"

    # Build Abstract
    $buildInfo.BuildArtifactPath = Join-Path -Path $buildInfo.ProjectRootPath -ChildPath "$($buildInfo.ModuleName)-$($buildInfo.ReleaseVersion).zip"

    # PSSA
    $buildInfo.CodeCoverageThreshold = $CodeCoverageThreshold
    $settingsPath = Get-ChildItem -Path $PSSASettingsName -File -Recurse | Select-Object -First 1
    if ($settingsPath) {
        $buildInfo.PSSASettingsPath = $settingsPath.FullName
    }
    else {
        Write-Verbose "Could not find PSScriptAnalyzer Settings file '$PSSASettingsName'."
    }

    $path = Get-ChildItem -Path $PSSACustomRulesFolderName -Directory -Recurse | Select-Object -First 1
    if ($path -and (Test-Path -Path (Join-Path -Path $path.FullName -ChildPath '*.psd1'))) {
        $buildInfo.PSSACustomRulesPath = $path.FullName
    }
    else {
        Write-Verbose "No PSScriptAnalyzer Custom Rules folder '$PSSACustomRulesFolderName' found."
    }

    # ReleaseNotes
    $path = Join-Path -Path $buildInfo.ProjectRootPath -ChildPath 'CHANGELOG.md'
    if (Test-Path $path) {
        $buildInfo.ReleaseNotesPath = $path

        $buildInfo.ReleaseNotes = Get-BuildReleaseNotes -Path $buildInfo.ReleaseNotesPath -Version $buildInfo.ReleaseVersion
    }

    $buildInfo
}