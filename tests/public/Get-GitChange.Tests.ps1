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

Describe 'Function Testing - Get-GitChange' {

    $currLoc = Get-Location
    Set-Location -Path 'TestDrive:\'
    git init

    Context 'Output' {
        It 'should return an empty string for no changes' {
            Get-GitChange | Should -BeNullOrEmpty
        }

        $changedFile = 'ChangedFile.ps1'
        It "should return 1 changed file as a string called '$changedFile'" {
            New-Item -Path $changedFile -ItemType File
            $result = Get-GitChange
            @($result).count | Should -Be 1
            $result | Should -BeOfType [String]
            $result | Should -Be $changedFile
        }
    }

    Set-Location -Path $currLoc
} 
