#.ExternalHelp PSModuleBuildHelper-help.xml
function Initialize-TestEnvironment {
    <#
    .SYNOPSIS
        Brief synopsis about the function.
    .DESCRIPTION
        Detailed explanation of the purpose of this function.
    .PARAMETER Param1
        The purpose of param1.
    .PARAMETER Param2
        The purpose of param2.
    .EXAMPLE
        <FUNCTION> -Param1 'Value1', 'Value2'
    .EXAMPLE
        'Value1', 'Value2' | <FUNCTION>
    .INPUTS
        [String]
    .OUTPUTS
        [PSObject]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 16/03/18 - Initial release
    .LINK
        Related things
    #>
    [CmdletBinding()]
    Param()
    
    $testInfo = Get-TestEnvironment

    if ($testInfo.BuildSystem -eq 'Unknown') {
        # re-import the module each time if you are running it locally - using
        # the SuppressImportModule will only import it once each session
        Write-Verbose "Removing module '$($testInfo.Modulename)'."
        Remove-Module $testInfo.ModuleName -Force
        Write-Verbose "Importing module '$($testInfo.BuildManifestPath)'"
        Import-Module -FullyQualifiedName $testInfo.BuildManifestPath -Force
    }
    elseif (-not (Get-Module -Name $testInfo.ModuleName -ErrorAction SilentlyContinue) -or !(Test-Path Variable:SuppressImportModule) -or !$SuppressImportModule) {
        # The first time this is called, the module will be forcibly (re-)imported.
        # After importing it once, the $SuppressImportModule flag should prevent
        # the module from being imported again for each test file.

        # -Scope Global is needed when running tests from within a CI environment
        Import-Module -FullyQualifiedName $testInfo.BuildManifestPath -Scope Global -Force

        # Set to true so we don't need to import it again for the next test
        $Script:SuppressImportModule = $true
    }

    $testInfo
}