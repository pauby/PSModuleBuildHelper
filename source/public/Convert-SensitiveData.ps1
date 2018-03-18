#.ExternalHelp PSModuleBuildHelper-help.xml
function Convert-SensitiveData {
    <#
    .SYNOPSIS
        Searches the object property names for keywords and masks their value if it matches.
    .DESCRIPTION
        Searches the object property names for keywords and masks their value if it matches.

        There is a default set of keywords that are searched for which can be
        replaced.
    .EXAMPLE
        $test = New-Object -TypeName PSObject -Property @{ api = 'abcd', name = 'Luke' }
        $test | Convert-SensitiveData

        Returns the object with the value of 'api' as '*****'
    .OUTPUTS
        [PSObject]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release
    .LINK
        Get-BuildSystem
    .LINK
        Get-BuildEnvironment
    #>

    [CmdletBinding()]
    [OutputType([PSObject])]
    Param (
        # Object to search the keys for matching keywords. Cannot be $null or empty.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript( { $null -ne $_ -and @($_.psobject.properties).count -ne 0 } )]
        [PSObject]
        $InputObject,

        # Array of regular expressions to match the keys against.
        [String[]]
        $Keyword = @('password', 'secret', 'key', 'api', 'token'),

        # The mask that will be used to replace any matching keyword values.
        [String]
        $Mask = '*****'
    )

    Begin {}

    Process {
        # filter the environment secret vars
        # if the environment variable is empty then don't mask it
        ForEach ($obj in $InputObject.PSObject.Properties) {
            Write-Debug "Checking '$($obj.Name)' for a keyword match."
            ForEach ($k in $Keyword) {
                # does the name match the secret and it's not empty
                if ($obj.Name -match $k) {
                    $obj.Value = $Mask
                    Write-Verbose "Key matched keyword '$k'. Value changed to '$($obj.Value)'."
                    break
                }
            }
        }

        $InputObject
   }

    End {}
}