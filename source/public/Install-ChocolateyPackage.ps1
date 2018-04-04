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

        We use Invoke-Command in this function rather than the & call operator
        as we can mock it.
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
            Invoke-Command -ScriptBlock { choco.exe } | Out-Null
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

                    # create a temp file to hold the Chocolatey install script and then execute it
                    do { 
                        $tempFile = "$(Join-Path -Path $env:TEMP -ChildPath([System.Guid]::NewGuid().ToString())).ps1"
                    } while (Test-Path $tempFile)
                    Invoke-WebRequest -UseBasicParsing -Uri 'https://chocolatey.org/install.ps1' -OutFile $tempFile
                    Invoke-Command -Command { .\$tempFile }
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
        $chocoParams = @('install', "$Name", '-y', '--no-progress')
        if ($Version -ne 'latest') {
            $chocoParams += "--version=$Version"
        }

        if ($PackageParams) {
            $chocoParams += "--params='$PackageParams'"
        }

        if ($pscmdlet.ShouldProcess("'$Name' with parameters '$($chocoParams -join "" "")'", "Installing Chocolatey package")) {
            # reset the last exit
            $LASTEXITCODE = 0
            Write-Verbose "Installing version '$Version' of '$Name' package with parameters '$($chocoParams -join "" "")'."
            Invoke-Command -ScriptBlock { & choco.exe $chocoParams }
            
            if ($LASTEXITCODE -ne 0) {
                throw "Chocolatey package '$Name' failed to install with command line '$($chocoParams -join "" "")'"
            }
        }
    }

    End {
        Write-Verbose 'Refreshing the PATH'
        refreshenv
    }
}