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

Describe 'Function Testing - Get-ProjectRoot' {

    $currLoc = Get-Location
    Set-Location -Path 'TestDrive:\'

    Context 'Output' {
        It 'should throw for no git repo' {
            { Get-ProjectRoot } | Should -Throw
        }

        It 'should return the path with a git repo' {
            git init

            Get-ProjectRoot | Should -Be "$TestDrive"
        }
    }

    Set-Location -Path $currLoc
} 
