#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-TestEnvironment {
    <#
    .SYNOPSIS
        Get the properties of the testing environment.
    .DESCRIPTION
        Get the properties required to test the project, or elements of the
        project. Some of the paths require that the module already be built
        beforehand and will throw an exception if that is not the case. 

        All areas of the test process takes it's details from the data produced
        by this function. To influence part of the build process the data
        produced only need be altered.

        Note that BuildPath, BuildManifestPath and BuildModulePath use the
        latest build directory based on it's version number.

        This funciton assumes that the module has already been built 
    .EXAMPLE
        Get-TestEnvironment

        Get test information for the current or any child directories.
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
        Get-BuildEnvironment
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseConsistentWhitespace", "", Justification = "Causes issue with the large hash table")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAlignAssignmentStatement", "", Justification = "Causes issue with the large hash table")]
    [OutputType([PSObject])]
    [CmdletBinding()]
    Param (
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

    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }
    
    $testInfo = Get-ProjectEnvironment

    $buildOutput = Join-Path -Path $testInfo.ProjectRootPath -ChildPath 'releases'
    # get all of the versions built in the 'releases' folder, and sort them
    # by name and choose the latest one - to sort them by name properly we have
    # to convert the names to versions (as 0.10.0 comes before 0.9.0 when using
    # strings)
    $latestBuildVersion = (Get-Childitem $buildOutput | `
            Select-Object -Property @{ l = 'Name'; e = { [version]$_.Name } } | Sort-Object Name -Descending | `
            Select-Object -First 1).Name.ToString()
    if ($latestBuildVersion -eq '') {
        throw 'Cannot find the latest build of the module. Did you build it beforehand?'
    }

    @(  
        @{  name    = 'SourceManifestPath'
            value   = (Join-Path -Path $testInfo.SourcePath -ChildPath "$($testInfo.ModuleName).psd1")
        }, 
        @{  name    = 'SourceModulePath'
            value   = (Join-Path -Path $testInfo.SourcePath -ChildPath "$($testInfo.ModuleName).psm1")
        },
        @{  name    = 'BuildPath'
            value   = (Join-Path -Path $buildOutput -ChildPath $latestBuildVersion)
        },
        @{  name    = 'BuildManifestPath'
            value   = (Join-Path -Path (Join-Path $buildOutput -ChildPath $latestBuildVersion) -ChildPath "$($testInfo.ModuleName).psd1")
        },
        @{  name    = 'BuildModulePath'
            value   = (Join-Path -Path (Join-Path $buildOutput -ChildPath $latestBuildVersion) -ChildPath "$($testInfo.ModuleName).psm1")
        }
        @{  name    = 'PSSASettingsPath'
            value   = ''
        },
        @{  name    = 'PSSACustomRulesPath'
            value   = ''
        }
    ) | ForEach-Object {
        $testInfo | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
    }

    # PSSA
    $settingsPath = Get-ChildItem $PSSASettingsName -Recurse | Select-Object -First 1
    if ($settingsPath) {
        $testInfo.PSSASettingsPath = $settingsPath.FullName
    }
    else {
        Write-Verbose "Could not find PSScriptAnalyzer Settings file '$PSSASettingsName'."
    }

    $path = Get-ChildItem -Path $PSSACustomRulesFolderName -Directory -Recurse | Select-Object -First 1
    if ($path -and (Test-Path -Path (Join-Path -Path $path.FullName -ChildPath '*.psd1'))) {
        $testInfo.PSSACustomRulesPath = $path.FullName
    }
    else {
        Write-Verbose "No PSScriptAnalyzer Custom Rules folder '$PSSACustomRulesFolderName' found."
    }

    $testInfo
}