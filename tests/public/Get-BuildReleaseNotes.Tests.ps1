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

Describe 'Function Testing - Get-BuildReleaseNotes' {

    @"
## v0.1 A date
* Some notes
some more notes

v0.0.7 Another date
A note here
Some more notes here
* A list

"@ | Set-Content 'TestDrive:\releasenotes.md'

    Context 'Input' {
        # if this is the first test being run after module import then it
        # may fail the fiorst time it is run - it looks like it may be too
        # quick between importing the function and it appearing in Function:.
        # solution would be to move this so it is not the first test.
        It 'should be true if mandatory parameters have not been changed' {
            $mandatoryParams = @( 'Path', 'Version' )
            $result = Get-FunctionParameter -Name 'Get-BuildReleaseNotes' | Where-Object { $_.Value.Attributes.Mandatory -eq $true }
            
            @($result).count | Should -Be @($mandatoryParams).Count
            [bool]($result | ForEach-Object { $mandatoryParams -contains $_.key }) | Should -Be $true  
        }

        It 'should throw an exception for null or empty parameters' {
            { Get-BuildReleaseNotes -Path $null } | Should throw
            { Get-BuildReleaseNotes -Path '' } | Should throw
            { Get-BuildReleaseNotes -Version $null } | Should throw
            { Get-BuildReleaseNotes -Version '' } | Should throw
        }

        It 'should pass for valid version parameters and throw for invalid ones' {
            { Get-BuildReleaseNotes -Path 'TestDrive:\releasenotes.md' -Version '1.0.0' } | Should -Not -Throw 
            { Get-BuildReleaseNotes -Path 'TestDrive:\releasenotes.md' -Version 'latest' -WhatIf } | Should -Throw
            { Get-BuildReleaseNotes -Path 'TestDrive:\releasenotes.md' -Version 'abc' -WhatIf } | Should -Throw
        }
    }

    Context 'Output' {
        $tests =@(
            @{  version     = '0.1'
                expected    = @"
v0.1 A date
* Some notes
some more notes
"@
            },
            @{
                version     = '0.0.7'
                expected    = @"
v0.0.7 Another date
A note here
Some more notes here
* A list
"@
            }
        )


        It 'should return the release notes for version <version>' -TestCases $tests {
            param (
                $version,
                $expected
            )

            $result = Get-BuildReleaseNotes -Path 'TestDrive:\releasenotes.md' -Version $version -Verbose
            $result | Should -Be $expected
        }
    }
} 
