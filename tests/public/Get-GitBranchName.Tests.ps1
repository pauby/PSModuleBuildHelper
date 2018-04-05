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

Describe 'Function Testing - Get-GitBranchName' {
    Context 'Input' {
        
    }
    Context 'Logic & Flow' {
        It 'should throw an exception for a location that is not a git repo' {
            Push-Location
            Set-Location $env:windir
            { Get-GitBranchName } | Should throw
            Pop-Location
        }
    }

    Context 'Output' {
        Push-Location
        Set-Location TestDrive:\
        git init
        git checkout -B master
        git commit --allow-empty -m 'test'

        It 'should return a branch name for a location that is a git repo' -Skip:$SkipTest {
            $result = Get-GitBranchName
            $result | Should -BeOfType [string]
            $result | Should -Be 'master'
        }

        Pop-Location
    }
} 
