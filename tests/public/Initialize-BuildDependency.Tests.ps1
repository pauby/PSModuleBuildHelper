$buildOutput = Join-Path -Path $PSScriptRoot -ChildPath '..\..\releases'
$latestBuildVersion = (Get-Childitem $buildOutput | `
        Select-Object -Property @{ l = 'Name'; e = { [version]$_.Name } } | Sort-Object Name -Descending | `
        Select-Object -First 1).Name.ToString()
if ($latestBuildVersion -eq '') {
    throw 'Cannot find the latest build of the module. Did you build it beforehand?'
}
else {
    Import-Module -FullyQualifiedName (Join-Path -Path (Join-Path -Path $buildOutput -ChildPath $latestBuildVersion) `
            -ChildPath 'psmodulebuildhelper.psd1') -Force
}

Describe 'Function Testing - Initialize-BuildDependency' {
    Context 'Parameters' {
        # if this is the first test being run after module import then it
        # may fail the fiorst time it is run - it looks like it may be too
        # quick between importing the function and it appearing in Function:.
        # solution would be to move this so it is not the first test.
        It 'should be true if mandatory parameters have not been changed' {
            $mandatoryParams = @( 'Dependency' )
            $result = Get-FunctionParameter -Name 'Initialize-BuildDependency' | Where-Object { $_.Value.Attributes.Mandatory -eq $true }
            
            @($result).count | Should -Be @($mandatoryParams).Count
            [bool]($result | ForEach-Object { $mandatoryParams -contains $_.key }) | Should -Be $true  
        }
    }

    Context 'Input' {
        It 'should throw an exception for an null or empty parameter' {
            { Initialize-BuildDependency -Dependency $null } | Should throw
            { Initialize-BuildDependency -Dependency @{} } | Should throw
        }
    }

    Context 'Logic & Flow' {
        It "should call the required modules for the dependencies" {
            Mock Install-DependentModule { return } -ModuleName PSModuleBuildHelper
            Mock Install-ChocolateyPackage { return } -ModuleName PSModuleBuildHelper
            $input = @(
                @{  name    = 'dummymodule' 
                },
                @{  name    = 'anotherdummymodule'
                    version = '1.0'
                    type    = 'module'
                },
                @{  Name    = 'dummychocopkg'
                    type    = 'Chocolatey'
                }
            )

            $input | Initialize-BuildDependency
            Assert-MockCalled -CommandName Install-DependentModule -Times 2 -ModuleName PSModuleBuildHelper
            Assert-MockCalled -CommandName Install-ChocolateyPackage -Times 1 -ModuleName PSModuleBuildHelper
        }
    }
} 
