#.ExternalHelp PSModuleBuildHelper-help.xml
function Initialize-BuildDependency {
    <#
    .SYNOPSIS
        Initializes the build dependencies.
    .DESCRIPTION
        Installs the modules, chocolatey packages and other dependencies for the
        module build.

        The format of the dependency hashtable depends on it's type but all of
        them share these keys:

            - Name      - [required] Name of the dependency. This is the module
                          name, chocolatey package name etc.
            - Version   - [optional] Version to be installed - latest by default.
            - Type      - [optional] Type of dependency - 'Module', 'Chocolatey'
                          By default this will be a 'Module'

        For a 'Module' type there are no additional options.

        For a 'Chocolatey' type there are these additional options:

            - PackageParams - [optional] Additional parameters that are passed to
                              choco.exe using the --params parameter. Whatever is
                              put in here will be surrounded by single quotes on
                              the choco command line.
    .EXAMPLE
        Initialize-BuildDependency -Dependency $deps

        Initializes the dependencies from data in $deps
    .EXAMPLE
        $deps | Initialize-BuildDependency -Dependency $deps

        Initializes the dependencies from data in $deps
    .INPUTS
        [Hashtable]
    .NOTES
        Author  : Paul Broadwith (https://github.com/pauby) 
        History : 1.0 - 03/04/18 - Initial release
    .LINK
        Install-DependentModule
    .LINK
        Install-ChocolateyPackage
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        # Dependency data to initialize.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $Dependency
    )

    Begin {
        # !if you change this you need to change the default in the switch statement below
        $DefaultType = 'Module'
    }

    Process {
        ForEach ($dep in $Dependency) {
            # check we have a type and if not default to $DefaultType
            $type = $DefaultType
            if ($dep.Keys -contains 'Type') {
                $type = $dep.Type
            }

            # we need to remove the 'Type' key before splatting
            $params = $dep.PsObject.Copy()
            $params.Remove('Type')
            
            switch ($type) {
                'Module' {
                    Install-DependentModule @params | Out-Null
                    break
                }
                'Chocolatey' {
                    Install-ChocolateyPackage @params | Out-Null
                    break
                }
                default {
                    Install-DependentModule @params | Out-Null
                }

            }
        }
    }
}