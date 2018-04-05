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

Describe 'Function Testing - Install-DependentModule' {
    Context 'Parameters' {
        # if this is the first test being run after module import then it
        # may fail the fiorst time it is run - it looks like it may be too
        # quick between importing the function and it appearing in Function:.
        # solution would be to move this so it is not the first test.
        It 'should be true if mandatory parameters have not been changed' {
            $mandatoryParams = @( 'Name' )
            $result = Get-FunctionParameter -Name 'Install-DependentModule' | Where-Object { $_.Value.Attributes.Mandatory -eq $true }
            
            @($result).count | Should -Be @($mandatoryParams).Count
            [bool]($result | ForEach-Object { $mandatoryParams -contains $_.key }) | Should -Be $true  
        }
    }

    Context 'Input' {
        It 'should throw an exception for an null or empty parameter' {
            { Install-DependentModule -Name $null } | Should throw
            { Install-DependentModule -Name '' } | Should throw
        }

        It 'should pass for valid version parameters and throw for invalid ones' {
            { Install-DependentModule -Name 'Pester' -Version 1.0.0 -WhatIf } | Should -Not -Throw 
            { Install-DependentModule -Name 'Pester' -Version 'latest' -WhatIf } | Should -Not -Throw
            { Install-DependentModule -Name 'Pester' -Version 'abc' -WhatIf } | Should -Throw
        }
    }

    Context 'Logic & Flow' {
        It 'should pass installing test modules' {
            Mock Get-Command -MockWith { throw } -ModuleName PSModuleBuildHelper
            Mock Install-PackageProvider -MockWith { return } -ModuleName PSModuleBuildHelper
            Mock Get-PSRepository -MockWith { New-Object -TypeName PSObject -Property @{ InstallationPolicy = 'Trusted' } } -ModuleName PSModuleBuildHelper
            Mock Install-Module { return } -ModuleName PSModuleBuildHelper
            $tests = @(
                @{  name    = 'dummymodule' 
                },
                @{  name    = 'anotherdummymodule'
                    version = '1.0.0'
                }
            )

            $tests | ForEach-Object { [PSCustomObject]$_ | Install-DependentModule }
            Assert-MockCalled -CommandName Get-Command -Times 2 -ModuleName PSModuleBuildHelper
            Assert-MockCalled -CommandName Install-PackageProvider -Times 2 -ModuleName PSModuleBuildHelper
            Assert-MockCalled -CommandName Get-PSRepository -Times 2 -ModuleName PSModuleBuildHelper
            Assert-MockCalled -CommandName Install-Module -Times 2 -ModuleName PSModuleBuildHelper
        }
    }
}
