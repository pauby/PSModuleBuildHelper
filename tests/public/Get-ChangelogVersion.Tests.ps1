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

Describe 'Function Testing - Get-ChangelogVersion' {
    Context 'Input' {
        It 'should be true if mandatory parameters have not been changed' {
            $mandatoryParams = @( 'Path' )
            $result = Get-FunctionParameter -Name 'Get-ChangelogVersion' | Where-Object { $_.Value.Attributes.Mandatory -eq $true }
            
            @($result).count | Should -Be @($mandatoryParams).Count
            [bool]($result | ForEach-Object { $mandatoryParams -contains $_.key }) | Should -Be $true  
        }

        It 'should throw an exception for an invalid path' {
            { Get-ChangelogVersion -Path 'TestDrive:\abc.md' } | Should throw
        }
    }

    Context 'Output' {
        $changelogPath = 'TestDrive:\changelog.md'

        It "should pass if the version is '0.0.0' when nothing matched in the changelog" {
            Set-Content -Path $changelogPath -Value ''
            $result = Get-ChangelogVersion -Path $changelogPath 
            $result | Should Be '0.0.0'
            $result | Should -BeOfType [Version]
        }

        It 'should return the correct version number for a test changelog' {
@"
# Changelog

This is a change log.

## v9.8.14 - Some fixes were done

* A fix
* Another fix

## v9.8.13 - A few fixes were done

* this is a fix
"@ | Set-Content $changelogPath

            $version = Get-ChangelogVersion -Path $changelogPath
            $version | Should -BeOfType [Version]
            $version | Should -Be '9.8.14' 
        }
    }
} 
