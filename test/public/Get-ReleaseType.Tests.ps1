$buildOutput = Join-Path -Path $PSScriptRoot -ChildPath '..\..\buildoutput'
$latestBuildVersion = (Get-Childitem $buildOutput | `
        Select-Object -Property @{ l = 'Name'; e = { [version]$_.Name } } | Sort-Object Name -Descending | `
        Select-Object -First 1).Name.ToString()
if ($latestBuildVersion -eq '') {
    throw 'Cannot find the latest build of the module. Did you build it beforehand?'
}
else {
    Import-Module (Join-Path -Path (Join-Path -Path $buildOutput -ChildPath $latestBuildVersion) `
        -ChildPath 'psmodulebuildhelper.psd1') -Force
}

Describe 'Function Testing - Get-ReleaseType' {
    Context 'Logic & Flow' {
        $latestVersion = [version]'1.0.0'
        $tests = @(
            @{  message     = 'Major release to fix things'
                expected    = 'Major' 
            },
            @{  message     = 'Minor release to fix things'
                expected    = 'Minor'
            },
            @{  message     = 'Release to fix some stuff'
                expected    = 'Build'
            },
            @{  message     = 'Fixed some stuff'
                expected    = 'None'
            },
            @{  message     = 'a dummy message'
                expected    = 'None'
            },
            @{  message     = 'This is a Major Release'
                expected    = 'None'
            },
            @{  message     = 'This is a nice new release'
                expected    = 'None'
            },
            @{  message     = ''
                expected    = 'None'
            }
        )
        It "should return <expected> for commit message <message>" -TestCases $tests {
            Param (
                $message,
                $expected
            )

            $result = Get-ReleaseType -CommitMessage $message
            $result | Should -Be $expected
        }
    }

    Context 'Parameters' {
        It 'should be true if mandatory parameters have not been changed' {
            # if this is the first test being run after module import then it
            # may fail the fiorst time it is run - it looks like it may be too
            # quick between importing the function and it appearing in Function:.
            # solution would be to move this so it is not the first test.
            $mandatoryParams = @( 'CommitMessage' )
            $result = Get-FunctionParameter -Name 'Get-ReleaseType' | Where-Object { $_.Value.Attributes.Mandatory -eq $true }
            
            @($result).count | Should -Be @($mandatoryParams).Count
            [bool]($result | ForEach-Object { $mandatoryParams -contains $_.key }) | Should -Be $true  
        }
    }

} 
