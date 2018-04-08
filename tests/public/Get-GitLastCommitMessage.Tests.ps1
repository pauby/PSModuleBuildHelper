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

Describe 'Function Testing - Get-GitLastCommitMessage' {
    Context 'Logic & Flow' {
        It 'should throw an exception for a location that is not a git repo' {
            Push-Location
            Set-Location $env:windir
            { Get-GitLastCommitMessage } | Should throw
            Pop-Location
        }
    }

    Context 'Output' {
        $commitMsg = 'The world is a Vampire'

        Push-Location
        Set-Location TestDrive:\
        git init
        git checkout -B master
        git commit --allow-empty -m $commitMsg

        It "should return the last commit message '$commitMsg'" {
            $result = Get-GitLastCommitMessage
            $result | Should -BeOfType [string]
            $result | Should -Be $commitMsg
        }

        Pop-Location
    }
} 
