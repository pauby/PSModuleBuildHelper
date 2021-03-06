#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-FunctionParameter {
    <#
    .SYNOPSIS
        Gets the parameters and their properties for a specified function.
    .DESCRIPTION
        Gets the parameters and their properties for a specified function. The
        function must exist within the 'Function:' provider so will not work on
        cmdlets.
    .EXAMPLE
        Get-FunctionParameters -Name 'Get-FunctionParameters'

        Returns the properties of each function parameter for the 'Import-Module'
        function excluding the common parameters for Advanced Functions.
    .EXAMPLE
        Get-FunctionParameters -Name 'Get-FunctionParameters' -Exclude ''

        Returns the properties of each function parameter for the 'Import-Module'
        function excluding no parameter names.
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 17/03/18 - Initial release
    #>
    [CmdletBinding()]
    Param (
        # Name of the function. The function must exist within the 'Function:'
        # provider or an exception will be thrown.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        # Array of parameter names to exclude. By default the Advanced Functions
        # common parameters are excluded. Pass an empty array to have all
        # parameters returned.
        [AllowEmptyCollection()]
        [string[]]
        $Exclude = @('Verbose', 'Debug', 'ErrorAction', 'WarningAction', `
                'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', `
                'OutVariable', 'OutBuffer', 'PipelineVariable' )
    )

    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
        $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }

    try {
        (Get-Item -Path "Function:\$Name").Parameters.GetEnumerator() | Where-Object { $Exclude -notcontains $_.key}
    }
    catch {
        throw "Cannot find function '$Name' loaded in the current session."
    }
}