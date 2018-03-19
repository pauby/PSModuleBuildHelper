$buildOutput = Join-Path -Path $PSScriptRoot -ChildPath '..\..\buildoutput'
$latestBuildVersion = (Get-Childitem $buildOutput | `
        Select-Object -Property @{ l = 'Name'; e = { [version]$_.Name } } | Sort-Object Name -Descending | `
        Select-Object -First 1).Name.ToString()
if ($latestBuildVersion -eq '') {
    throw 'Cannot find the latest build of the module. Did you build it beforehand?'
}
else {
    Import-Module -FullyQualifiedName (Join-Path -Path (Join-Path -Path $buildOutput -ChildPath $latestBuildVersion) `
            -ChildPath 'psmodulebuildhelper.psd1') -Force -verbose
}

Describe 'Function Testing - Remove-BuildEnvironment' {
    Context 'Input' {
        # if this is the first test being run after module import then it
        # may fail the fiorst time it is run - it looks like it may be too
        # quick between importing the function and it appearing in Function:.
        # solution would be to move this so it is not the first test.
        It 'should be true if mandatory parameters have not been changed' {
            $mandatoryParams = @( 'BuildInfo' )
            $result = Get-FunctionParameter -Name 'Remove-BuildEnvironment' | Where-Object { $_.Value.Attributes.Mandatory -eq $true }
            
            @($result).count | Should -Be @($mandatoryParams).Count
            [bool]($result | ForEach-Object { $mandatoryParams -contains $_.key }) | Should -Be $true  
        }
    }

    Context "Output" {
        It "should pass if it remove the 'output' and 'buildoutput' folders" {
            @( "TestDrive:\MyModule\BuildOutput\6.19.0", 
                "TestDrive:\MyModule\output", 
                "TestDrive:\MyModule\source", 
                "TestDrive:\MyModule\test" 
            ) | ForEach-Object { New-Item -Path $_ -ItemType Directory }

            New-ModuleManifest -Path 'TestDrive:\MyModule\Source\MyModule.psd1'
            $currLoc = Get-Location
            Set-Location 'TestDrive:\MyModule'
            git init
            $projEnv = Get-BuildEnvironment

            Remove-BuildEnvironment -BuildInfo $projEnv
            'TestDrive:\MyModule\BuildOutput' | Should -Not -Exist
            'TestDrive:\MyModule\output' | Should -Not -Exist

            Set-Location -Path $currLoc
        }
    }
} 
