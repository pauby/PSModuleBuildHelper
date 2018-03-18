#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-BuildSystem {
    <#
    .SYNOPSIS
        Gets the current build system.
    .DESCRIPTION
        Gets the current build system, such as AppVeyor, GitLab CI,
        Teamcity etc. If a build system cannot be detected (such as
        runnning on a local machine), then 'Unknown' will be returned.
    .EXAMPLE
        Get-BuildSystem

        Return the current build system.
    .OUTPUTS
        [String]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby) History : 1.0 -
        15/03/18 - Initial release
    .LINK
        Get-BuildSystemEnvironment
    .LINK
        Get-BuildEnvironment
    #>
    [CmdletBinding()]
    [OutputType([String])]
    Param ()

    # todo Make these values Enums for use elsewhere?
    $system = switch ((Get-Item env:).name) {
        'APPVEYOR_BUILD_FOLDER' { 'AppVeyor'; break }
        'GITLAB_CI' { 'GitLab CI' ; break }
        'JENKINS_URL' { 'Jenkins'; break }
        'BUILD_REPOSITORY_URI' { 'VSTS'; break }
        'TEAMCITY_VERSION' { 'Teamcity'; break }
        'BAMBOO_BUILDKEY' { 'Bamboo'; break }
        'GOCD_SERVER_URL' { 'GoCD'; break }
        'TRAVIS' { 'Travis CI'; break }
    }

    if (-not $system) {
        $system = 'Unknown'
    }

    $system
}