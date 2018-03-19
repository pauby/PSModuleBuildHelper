#.ExternalHelp PSModuleBuildHelper-help.xml
function New-GithubRelease {
    <#
    .SYNOPSIS
        Creates a release on GitHub.
    .DESCRIPTION
        Creates a release on GitHub using an already created artifact.

        Note that this does not use the credential store for authentication but uses
        the GitHub Username and Api Key passed to the function.
    .EXAMPLE
        New-GitHubRelease -Version 1.0 -CommitId 'a6fe432' 
            -ArtifactPath 'c:\temp\mymodule-1.0.zip' -GitHubUsername 'me' 
            -GitHubRepository 'mymodule' -GitHubApiKey '123456789'

        This will create a new version 1.0 relase on GitHub for the Commit ID
        'a6fe432' using the artifact 'c:\temp\mymodule-1.0.zip' in the GitHub 
        repository 'mymodule' using the Api Key and Username for authentication.
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseConsistentWhitespace", "", Justification = "Causes issue with the open hash tables")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    Param (
        # The version number to be used for this release.
        [Parameter(Mandatory)]
        [Version]$Version,

        # The Commit ID corresponding to this release.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CommitID,

        # Release notes for this release.
        [string]$ReleaseNotes = '',

        # The path to the release artifact.
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ } )]
        [string]$ArtifactPath,

        # The GitHub Username to use for authentication.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GitHubUsername,

        # The Github API key used for authentication. 
        # See (https://github.com/blog/1509-personal-api-tokens)
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GitHubApiKey,

        # Which GitHub repository this release is for.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GitHubRepository,

        # Marks this release as a draft.
        [Switch]
        $DraftRelease,

        # Marks this release as a pre-release.
        [switch]
        $PreRelease
    )

    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }

    # Get just the name of the file to attach to this release
    $artifact = Split-Path $ArtifactPath -Leaf 

    $releaseData = @{
        tag_name         = "v{0}" -f $Version
        target_commitish = $CommitId
        name             = "v{0}" -f $Version
        body             = $ReleaseNotes
        draft            = $DraftRelease.IsPresent
        prerelease       = $PreRelease.IsPresent
    }

    $releaseParams = @{
        Uri         = "https://api.github.com/repos/$GitHubUsername/$GitHubRepository/releases"
        Method      = 'POST'
        Headers     = @{
            Authorization = 'Basic ' + [Convert]::ToBase64String(
                [Text.Encoding]::ASCII.GetBytes($GitHubApiKey + ":x-oauth-basic"))
        }
        ContentType = 'application/json'
        Body        = (ConvertTo-Json $releaseData -Compress)
        UseBasicParsing = $true
    }

    # force use of TLS 1.2
    Write-Verbose 'Forcing using of TLS1.2 for GitHub.'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Write-Verbose 'Creating tagged Github release.'
    try {
        $result = Invoke-RestMethod @releaseParams -OutVariable $errorMsg
    }
    catch {
        throw "Could not create tagged GitHub release - '$_'"
    }
    $uploadUri = $result | Select-Object -ExpandProperty upload_url
    $uploadUri = $uploadUri -replace '\{\?name.*\}', "?name=$artifact"

    $uploadParams = @{
        Uri         = $uploadUri
        Method      = 'POST'
        Headers     = @{
            Authorization = 'Basic ' + [Convert]::ToBase64String(
                [Text.Encoding]::ASCII.GetBytes($GitHubApiKey + ":x-oauth-basic"));
        }
        ContentType = 'application/zip'
        InFile      = $ArtifactPath
    }

    if ($PSCmdlet.ShouldProcess("ShouldProcess?")) {
        Write-Verbose 'Uploading artifact.'
        $response = Invoke-RestMethod @uploadParams
        Write-Verbose "Response from artifact upload: $response"
    }
}