#.ExternalHelp PSModuleBuildHelper-help.xml
function Install-DependentModule {
    <#
    .SYNOPSIS
        Installs a module.
    .DESCRIPTION
        Installs a module and. if necessary, installs the Nuget Package Provider
        and trusts the PowerShell Gallery repository. These last two steps are
        necessary if installing on a bare PowerShell install (such as in CI).
    .EXAMPLE
        Install-DependentModule -Name 'Dummy'

        Installs thelatest version of the module dummy.
    .OUTPUTS
        [PSObject]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby) 
        History : 1.0 - 03/04/18 - Initial release
    .LINK
        Initialize-BuildDependency
    .LINK
        Install-ChocolateyPackage
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        # The module name ot install
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        # The version to install. To install the latest version do not pass this
        # parameter or pass the string 'latest'.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript( { if ($_ -ne 'latest') { try { [version]$_ } catch { return $false } } $true })]
        [string]
        $Version = 'latest'
    )

    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }

    # check for install-module cmdlet - this tells us if we have the nuget package provider installed
    try {
        Get-Command -Name 'Install-Module' -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Verbose 'Installing the Nuget Package Provider'
        if ($pscmdlet.ShouldProcess("Nuget Package Provider", "Installing")) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
        }
    }

    # check the PSGallery repository is trusted
    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') { 
        if ($pscmdlet.ShouldProcess("PowerShell Gallery", "Trusting")) {
            Write-verbose "Trusting PowerShell Gallery"
            # !there is a problem with mocking this cmdlet within Pester so it is not tested
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }
    }

    # install the module
    if ($pscmdlet.ShouldProcess("$Version version of module $Name", "Installing module")) {
        if ($Version -ne 'latest') {
            Write-Verbose "Installing version '$Version' of module '$Name'"
            Install-Module -Name $Name -RequiredVersion [Version]$Version -Scope CurrentUser
            # return the version of the module we installed
            Get-Module -Name $Name -ListAvailable | Where-Object { [Version]$_.Version -eq [Version]$Version }
        }
        else {
            Write-Verbose "Installing latest version of module '$Name'"
            Install-Module -Name $Name -Scope CurrentUser
            # return only the latest version of this module
            Get-Module -Name $Name -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
        }
    }
}