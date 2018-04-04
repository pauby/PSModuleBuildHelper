#.ExternalHelp PSModuleBuildHelper-help.xml
function Install-ChocolateyPackage {
    <#
    .SYNOPSIS
        Installs a Chocolatey package.
    .DESCRIPTION
        Installs a Chocolatey package and installs Chocolatey if required.
    .EXAMPLE
        Install-ChocolateyPackage -Name '7zip'

        Installs the latest version of 7zip.
    .EXAMPLE
        Install-ChocolateyPackage -Name '7zip' -Version '15.0'

        Installs version 15.0 of 7zip.
    .EXAMPLE
        Install-ChocolateyPackage -Name 'dummy' -PackageParams '--noprogress'

        Installs the latest version of dummy with the package parameters --noprogress.
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 03/04/18 - Initial release
    .LINK
        Install-DependentModule
    .LINK
        Initialize-BuildDependency
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        # Name of the Chocolatye package to install
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        # Version of the package to install.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript( { if ($_ -ne 'latest') { try { [version]$_ } catch { return $false } } $true })]
        [string]
        $Version = 'latest',

        # Chocolatey package parameters to use when installing the package.
        [ValidateNotNullOrEmpty()]
        [string]
        $PackageParams
    )

    Begin {
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
        }

        $chocoInstalled = $true
        try {
            Invoke-Expression -Command 'choco.exe' | Out-Null
        }
        catch {
            $chocoInstalled = $false
        }

        if (-not $chocoInstalled) {
            try {
                Write-Verbose 'Chocolatey not installed. Installing.'
                if ($pscmdlet.ShouldProcess("Chocolatey", "Install")) {
                    # taken from https://chocolatey.org/install
                    Set-ExecutionPolicy Bypass -Scope Process -Force
                    Invoke-Expression -Command "((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
                }
            }
            catch {
                throw 'Could not install Chocolatey'
            }
        }
        else {
            Write-Verbose "Chocolatey already installed."
        }
    }

    Process {
        # if we get here chocolatey is installed - install the package
        $chocoParams = "choco install $Name -y --no-progress"
        if ($Version -ne 'latest') {
            $chocoParams += " --version=$Version"
        }

        if ($PackageParams) {
            $chocoParams += " --params='$PackageParams'"
        }

        if ($pscmdlet.ShouldProcess("'$Name' with parameters '$chocoParams'", "Installing Chocolatey package")) {
            # reset the last exit
            $LASTEXITCODE = 0
            Write-Verbose "Installing version '$Version' of '$Name' package with parameters '$chocoParams'."
            Invoke-Expression -Command $chocoParams
            
            if ($LASTEXITCODE -ne 0) {
                throw "Chocolatey package '$Name' failed to install with command line '$chocoParams'."
            }
        }
    }

    End {
        Write-Verbose 'Refreshing the PATH'
        refreshenv
    }
}