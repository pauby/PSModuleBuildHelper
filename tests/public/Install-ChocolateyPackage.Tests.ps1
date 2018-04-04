$buildOutput = Join-Path -Path $PSScriptRoot -ChildPath '..\..\buildoutput'
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

Describe 'Function Testing - Install-ChocolateyPackage' {
    Context 'Parameters' {
        # if this is the first test being run after module import then it
        # may fail the fiorst time it is run - it looks like it may be too
        # quick between importing the function and it appearing in Function:.
        # solution would be to move this so it is not the first test.
        It 'should be true if mandatory parameters have not been changed' {
            $mandatoryParams = @( 'Name' )
            $result = Get-FunctionParameter -Name 'Install-ChocolateyPackage' | Where-Object { $_.Value.Attributes.Mandatory -eq $true }
            
            @($result).count | Should -Be @($mandatoryParams).Count
            [bool]($result | ForEach-Object { $mandatoryParams -contains $_.key }) | Should -Be $true  
        }
    }

    Context 'Input' {
        It 'should throw an exception for null or empty parameters' {
            { Install-ChocolateyPackage -Name $null } | Should throw
            { Install-ChocolateyPackage -Name '' } | Should throw
            { Install-ChocolateyPackage -PackageParam $null } | Should throw
            { Install-ChocolateyPackage -PackageParam '' } | Should throw
        }

        It 'should pass for valid version parameters and throw for invalid ones' {
            { Install-ChocolateyPackage -Name 'Pester' -Version 1.0.0 -WhatIf } | Should -Not -Throw 
            { Install-ChocolateyPackage -Name 'Pester' -Version 'latest' -WhatIf } | Should -Not -Throw
            { Install-ChocolateyPackage -Name 'Pester' -Version 'abc' -WhatIf } | Should -Throw
        }
    }

    Context 'Logic & Flow' {
        It 'should pass installing Chocolatey packages' {
            Mock Invoke-Expression -MockWith { return } -ModuleName PSModuleBuildHelper
            Mock Invoke-Expression -ParameterFilter { $Command -eq 'choco.exe' } -MockWith { throw } -ModuleName PSModuleBuildHelper
            Mock Set-ExecutionPolicy { return } -ModuleName PSModuleBuildHelper

            $tests = @(
                [pscustomobject]@{  
                    name    = 'dummypkg' 
                },
                [pscustomobject]@{  
                    name    = 'dummypkg'
                    version = '1.0'
                },
                [pscustomobject]@{  
                    Name         = 'dummychocopkg'
                    version      = '2.0'
                    packageparam = '--noprogress'
                }
            )

            $tests | Install-ChocolateyPackage
            Assert-MockCalled -CommandName Invoke-Expression -ParameterFilter { $Command -eq 'choco.exe' } -Times 1 -ModuleName PSModuleBuildHelper
            Assert-MockCalled -CommandName Invoke-Expression -Times 5 -ModuleName PSModuleBuildHelper
            Assert-MockCalled -CommandName Set-ExecutionPolicy -Times 1 -ModuleName PSModuleBuildHelper
        }
    }
} 
