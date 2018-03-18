#.ExternalHelp PSModuleBuildHelper-help.xml
function Remove-BuildEnvironment {
    <#
    .SYNOPSIS
        Removes the folders and files created during the build process.
    .DESCRIPTION
        Removes the folders and files created during the build process.
    .EXAMPLE
        Remove-BuildEnvironment

        Removes the folders and files created during the build process.
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 16/03/18 - Initial release
    .LINK
        Get-BuildEnvironment
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    Param (
        # The build environment returned from Get-BuildEnvironment
        [Parameter(Mandatory)]
        [PSObject]$BuildInfo
    )

    if ($PSCmdlet.ShouldProcess('ShouldProcess?')) {
        try {
            if (Test-Path $BuildInfo.BuildPath) {
                Write-Verbose "Removing 'Build' folder $($BuildInfo.BuildPath)"
                Remove-Item $BuildInfo.BuildPath -Recurse -Force
            }

            if (Test-Path $BuildInfo.OutputPath) {
                Write-Verbose "Removing 'Output' folder $($BuildInfo.OutputPath)"
                Remove-Item $BuildInfo.OutputPath -Recurse -Force
            }
        }
        catch {
            throw
        }
    }
}