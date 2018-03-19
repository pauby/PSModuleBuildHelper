#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-NextReleaseVersion {
    <#
    .SYNOPSIS
        Get's the next release version.
    .DESCRIPTION
        Get's the next release version.
    .EXAMPLE
        Get-NextReleaseVersion -LatestVersion [Version]'1.0.0' -ReleaseType 'Minor'

        Will return a new version number of [Version]'1.1.0' which is a minor version increase from '1.0.0'
    .OUTPUTS
        [Version]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
    .LINK
        Get-PowerShellGalleryVersion
    .LINK
        Get-ManifestVersion
    .LINK
        Get-ChangelogVersion
    #>
    [OutputType([Version])]
    [CmdletBinding()]
    Param (
        # The latest releaase version.
        [Parameter(Mandatory)]
        [Version]
        $LatestVersion,

        # The type of this release.
        [Parameter(Mandatory)]
        [String]
        $ReleaseType
    )

    Write-Verbose "Release type is $($ReleaseType)."
    $version = switch ($ReleaseType) {
        Major {
            Write-Verbose "Incrementing major version number."
            New-Object Version(($LatestVersion.Major + 1), 0, 0)
        }
        Minor {
            Write-Verbose "Incrementing minor version number."
            New-Object Version($LatestVersion.Major, ($LatestVersion.Minor + 1), 0)
        }
        Build {
            Write-Verbose "Incrementing build version number."
            New-Object Version($LatestVersion.Major, $LatestVersion.Minor, ($LatestVersion.Build + 1))
        }
        default {
            # this also catches the ReleaseType of None
            Write-Verbose 'Not incrementing any version numbers.'
            New-Object Version($LatestVersion)
        }
    }

    Write-Verbose "New version will be $version"

    $version
}