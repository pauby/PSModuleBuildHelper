#.ExternalHelp PSModuleBuildHelper-help.xml
function Get-BuildItem {
    <#
    .SYNOPSIS
        Gets the files to be used in the build.
    .DESCRIPTION
        Gets a list of files to be used in the build from the 'source' folder.
    .EXAMPLE
        Get-BuildItem -Type 'Static' -Path 'c:\mymodule\source'

        Gets a list of the static build items from the path 'c:\mymodule\source'
    .OUTPUTS
        [System.IO.FileInfo], [System.IO.DirectoryInfo]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby)
        History : 1.0 - 15/03/18 - Initial release

        This function was lifted as is from Indented.Build
        (https://github.com/indented-automation/Indented.Build) so all credit
        goes to that project.
    .LINK
    #>

    [CmdletBinding()]
    [OutputType([System.IO.FileInfo], [System.IO.DirectoryInfo])]
    Param (
        # Gets items by type.
        #
        #   ShouldMerge - *.ps1 files from enum*, class*, priv*, pub* and
        #                 InitializeModule if present. 
        #   Static      - Files which are not within a well known top-level
        #                 folder. Captures help content in en-US, format 
        #                 files, configuration files, etc.
        [Parameter(Mandatory)]
        [ValidateSet('ShouldMerge', 'Static')]
        [String]$Type,

        # The path to the module 'source' folder.
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path,

        # Exclude script files containing PowerShell classes.
        [Switch]$ExcludeClass
    )

    Push-Location $Path

    $itemTypes = [Ordered]@{
        enumeration    = 'enum*'
        class          = 'class*'
        private        = 'priv*'
        public         = 'pub*'
        initialisation = 'InitializeModule.ps1'
    }

    if ($Type -eq 'ShouldMerge') {
        foreach ($itemType in $itemTypes.Keys) {
            if ($itemType -ne 'class' -or ($itemType -eq 'class' -and -not $ExcludeClass)) {
                $items = Get-ChildItem $itemTypes[$itemType] -Recurse -ErrorAction SilentlyContinue |
                    Where-Object { -not $_.PSIsContainer -and $_.Extension -eq '.ps1' -and $_.Length -gt 0 }

                $orderingFilePath = Join-Path $itemTypes[$itemType] 'order.txt'
                if (Test-Path $orderingFilePath) {
                    [String[]]$order = Get-Content (Resolve-Path $orderingFilePath).Path

                    $items = $items | Sort-Object {
                        $index = $order.IndexOf($_.BaseName)
                        if ($index -eq -1) {
                            [Int32]::MaxValue
                        }
                        else {
                            $index
                        }
                    }, Name
                }

                $items
            }
        }
    }
    elseif ($Type -eq 'Static') {
        [String[]]$exclude = $itemTypes.Values + '*.config', 'test*', 'doc', 'help', '.build*.ps1'

        # Should work, fails when testing.
        # Get-ChildItem -Exclude $exclude
        foreach ($item in Get-ChildItem) {
            $shouldExclude = $false

            foreach ($exclusion in $exclude) {
                if ($item.Name -like $exclusion) {
                    $shouldExclude = $true
                }
            }

            if (-not $shouldExclude) {
                $item
            }
        }
    }

    Pop-Location
}