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

Describe 'Function Testing - Get-SourcePath' {
    Context 'Parameters' {
        It 'should throw for an invalid path' {
            { Get-Source-Path -Path 'TestDrive:\abc' } | Should throw
        }

        It 'should be true if mandatory parameters have not been changed' {
            $mandatoryParams = @( 'ProjectRoot' )
            $result = Get-FunctionParameter -Name 'Get-SourcePath' | Where-Object { $_.Value.Attributes.Mandatory -eq $true }
            
            @($result).count | Should -Be @($mandatoryParams).Count
            [bool]($result | ForEach-Object { $mandatoryParams -contains $_.key }) | Should -Be $true  
        }
    }

    Context 'Logic & Flow' {
        $tests = @( 
            @{  root        = 'TestDrive:\Project1'
                expected    = 'TestDrive:\Project1\source'
            },
            @{  root        = 'TestDrive:\Project2'
                expected    = 'TestDrive:\Project2\src'
            },
            @{  root        = 'TestDrive:\Project3'
                expected    = 'TestDrive:\Project3\Project3'
            }
        )
        $tests | ForEach-Object { 
            New-Item -Path $_.expected -ItemType Directory
        }

        It 'should return the correct source path' -TestCases $tests {
            Param (
                $root,
                $expected
            )

            Get-SourcePath -ProjectRoot $root | Should -Be $expected
        }
    }
} 
