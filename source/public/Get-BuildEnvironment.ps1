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

        The idea came from the Indented.Build project
        (https://github.com/indented-automation/Indented.Build) and heavily
        modified. Credit should be given to that project.
    .LINK
        Get-ProjectEnvironment
    .LINK
        Get-TestEnvironment
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseConsistentWhitespace", "", Justification = "Causes issue with the large hash table")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAlignAssignmentStatement", "", Justification = "Causes issue with the large hash table")]
    [OutputType([PSObject])]
    [CmdletBinding()]
    Param (
        # The type of release we should be building. If this is 'Unknown' then
        # the release type will be deteremined from the commit message.
        [ReleaseType]
        $ReleaseType = (Get-ReleaseType -CommitMessage Get-GitLastCommitMessage),

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
        $PSSACustomRulesFolderName = 'CustomAnalyzerRules'
    )

    $buildInfo = Get-ProjectEnvironment 

    # Repo
    try {
        $repoBranch = Get-GitBranchName
        $repoLastCommitHash = Get-GitLastCommitHash
        $repoLastCommitMessage = Get-GitLastCommitMessage
    }
    catch {
        Write-Warning 'Cannot determine the current git branch or there are no previous commits.'
    }

    @(  @{  name    = 'LatestVersion'
            value   = ''
        },
        @{  name    = 'ReleaseVersion'
            value   = ''
        },
        @{  name    = 'ReleaseType'
            value   = $ReleaseType
        },
        @{  name    = 'PSGalleryApiKey'
            value   = $PSGalleryApiKey
        },
        @{  name    = 'RepoBranch'
            value   = $repoBranch
        },
        @{  name    = 'RepoLastCommitHash'
            value   = $repoLastCommitHash
        },
        @{  name    = 'RepoLastCommitMessage'
            value   = $repoLastCommitMessage
        },
        @{  name    = 'GitHubUsername'
            value   = $GitHubUsername
        },
        @{  name    = 'GitHubApiKey'
            value   = $GitHubApiKey
        },
        @{  name    = 'SourceManifestPath'
            value   = (Join-Path -Path $buildInfo.SourcePath -ChildPath "$($buildInfo.ModuleName).psd1")
        }, 
        @{  name    = 'SourceModulePath'
            value   = (Join-Path -Path $buildInfo.SourcePath -ChildPath "$($buildInfo.ModuleName).psm1")
        },
        @{  name    = 'BuildPath'
            value   = ''
        },
        @{  name    = 'BuildManifestPath'
            value   = ''
        },
        @{  name    = 'BuildModulePath'
            value   = ''
        }
        @{  name    = 'PSSASettingsPath'
            value   = ''
        },
        @{  name    = 'PSSACustomRulesPath'
            value   = ''
        }
        @{  name    = 'BuildArtifactPath'
            value   = ''
        }
    ) | ForEach-Object {
        $buildInfo | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
    }

    # Versions
    $buildInfo.LatestVersion = Get-ManifestVersion -Path $buildInfo.SourceManifestPath
    $buildInfo.ReleaseVersion = Get-NextReleaseVersion -LatestVersion $buildInfo.LatestVersion -ReleaseType $ReleaseType
    $psGalleryVersion = Get-PowerShellGalleryVersion -Name $buildInfo.ModuleName
    if ([version]$psGalleryVersion -gt [version]$buildInfo.ReleaseVersion) {
        Write-Warning "The version of this module in the PowerShell Gallery ($psGalleryVersion) is greater than the release version of this build ($($buildInfo.ReleaseVersion))."
    }

    # Build paths
    $buildPath = Join-Path -Path (Join-Path -Path $buildInfo.ProjectRootPath -ChildPath 'buildoutput') -ChildPath $buildInfo.ReleaseVersion
    $buildInfo.BuildPath = $buildPath
    $buildInfo.BuildManifestPath = Join-Path -Path $buildPath -ChildPath "$($buildInfo.ModuleName).psd1"
    $buildInfo.BuildModulePath = Join-Path -Path $buildPath -ChildPath "$($buildInfo.ModuleName).psm1"

    # Build Abstract
    $buildInfo.BuildArtifactPath = Join-Path -Path $buildInfo.ProjectRootPath -ChildPath "$($buildInfo.ModuleName)-$($buildInfo.ReleaseVersion).zip"

    # PSSAct-Object -First 1
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

    $buildInfo
}