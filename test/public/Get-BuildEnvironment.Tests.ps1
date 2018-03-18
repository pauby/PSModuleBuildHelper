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

Describe 'Function Testing - Get-BuildEnvironment' {
    Context 'Input' {
        It 'should throw an exception for an invalid ReleaseType' {
            { Get-BuildEnvironment -ReleaseType 'Invalid' } | Should throw
        }
    }

    Context 'Output' {
        It 'should return an object for a location that is a git repo' {
            Get-BuildEnvironment -ReleaseType 'None' | Should -BeOfType [PSObject] 
        }
    }

    $moduleName = 'MyModule'
    $moduleVersion = '19.3.89'
    $psGalleryApiKey = '1234567890'
    $gitHubUsername = 'dummy'
    $gitHubApiKey = '0987654321'
    $pssaSettings = 'SASettings.psd1'
    $pssaCustomRulesPath = 'CustomRules'
    $currLoc = Get-Location
    $sources = @( $moduleName, 'source', 'src' )
    ForEach ($sourcePath in $sources) {
        Context "Output - Source Path is '$sourcePath'" {  
            @(  "TestDrive:\$moduleName\$sourcePath", 
                "TestDrive:\$moduleName\BuildOutput\6.19.0",
                "TestDrive:\$moduleName\Tests\$pssaCustomRulesPath"
            ) | ForEach-Object { New-Item -Path $_ -ItemType Directory }

            New-ModuleManifest -Path "TestDrive:\$moduleName\$sourcePath\$moduleName.psd1" -ModuleVersion $moduleVersion
            New-Item -Path "TestDrive:\$moduleName\Tests\$pssaSettings" -ItemType File
            New-Item -Path "TestDrive:\$moduleName\Tests\CustomRules\customrules.psd1" -ItemType File
            $tests = @( 
                @{  key      = 'LatestVersion'
                    expected = $moduleVersion
                },
                @{  key      = 'ReleaseVersion'
                    expected = $moduleVersion
                },
                @{  key      = 'ReleaseType'
                    expected = 'None'
                },
                @{  key      = 'BuildArtifactPath'
                    expected = "$TestDrive\$moduleName\$moduleName-$moduleVersion.zip"
                },
                @{  key      = 'BuildPath'
                    expected = "$TestDrive\$moduleName\buildoutput\$moduleVersion"
                },
                @{  key      = 'BuildManifestPath'
                    expected = "$TestDrive\$moduleName\buildoutput\$moduleVersion\$modulename.psd1"
                },
                @{  key      = 'BuildModulePath'
                    expected = "$TestDrive\$moduleName\buildoutput\$moduleVersion\$modulename.psm1"
                }                
            )

            Set-Location -Path "TestDrive:\$moduleName"
            # initial the repo so that we can find the project root
            git init
            $projEnv = Get-BuildEnvironment -ReleaseType 'None' -PSGalleryApiKey $psGalleryApiKey `
                -GitHubUsername $gitHUbUsername -GitHubApiKey $gitHubApiKey `
                -PSSASettingsName $pssaSettings -PSSACustomRulesFolderName $pssaCustomRulesPath
            It 'should have the correct value for <key>' -TestCases $tests {
                Param (
                    $key,
                    $expected
                )

                $projEnv.$key | Should -Be $expected
            }
        } #end Context
    } #end ForEach

    Set-Location -Path $currLoc
} 
