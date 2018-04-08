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

Describe 'Function Testing - Get-NextReleaseVersion' {
    Context 'Input' {
        It 'should be true if mandatory parameters have not been changed' {
            $mandatoryParams = @( 'LatestVersion', 'ReleaseType' )
            $result = Get-FunctionParameter -Name 'Get-NextReleaseVersion' | Where-Object { $_.Value.Attributes.Mandatory -eq $true }
            
            @($result).count | Should -Be @($mandatoryParams).Count
            [bool]($result | ForEach-Object { $mandatoryParams -contains $_.key }) | Should -Be $true  
        }
        It 'should throw an exception for an invalid version' {
            { Get-NextReleaseVersion -LatestVersion 'hello world' -ReleaseType 'None' } | Should throw
        }

        It 'should throw for an invalid ReleaseType' {
            { Get-NextReleaseVersion -LatestVersion '1.0.0' ReleaseType 'Invalid' } | Should throw
        }
    }

    Context 'Logic & Flow' {
        $latestVersion = [version]'1.0.0'
        $tests = @(
            @{  releaseType = 'Major'
                newVersion  = [version]'2.0.0' 
            },
            @{  releaseType = 'Minor'
                newVersion  = [version]'1.1.0'
            },
            @{  releaseType = 'Build'
                newVersion  = [version]'1.0.1'
            },
            @{  releaseType = 'None'
                newVersion  = [version]'1.0.0'
            }
        )
        It 'should pass when matching against the correct incremented version number' -TestCases $tests {
            Param (
                $releaseType,
                $newVersion
            )

            $result = Get-NextReleaseVersion -LatestVersion $latestVersion -ReleaseType $releaseType
            $result | Should -BeOfType [Version]
            $result | Should -Be $newVersion 
        }
    }
} 
