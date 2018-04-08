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

Describe 'Function Testing - Get-TestEnvironment' {
    Context 'Input' {
        It 'should throw for an invalid path' {
            { Get-Source-Path -Path 'TestDrive:\abc' } | Should throw
        }
    }

    $currLoc = Get-Location
    $sources = @( 'MyModule', 'source', 'src' )
    ForEach ($sourcePath in $sources) {
        Context "Output - Source Path is '$sourcePath'" {  
            @(  "TestDrive:\MyModule\$sourcePath", 
                'TestDrive:\MyModule\BuildOutput\6.19.0',
                'TestDrive:\MyModule\Tests\CustomRules'
            ) | ForEach { New-Item -Path $_ -ItemType Directory }

            New-Item -Path 'TestDrive:\MyModule\Tests\PSSASettings.psd1' -ItemType File
            New-Item -Path 'TestDrive:\MyModule\Tests\CustomRules\SomeRules.psd1' -ItemType File

            $tests = @( 
                @{  key         = 'SourceManifestPath'
                    expected    = "$TestDrive\MyModule\$sourcePath\MyModule.psd1"
                },
                @{  key         = 'SourceModulePath'
                    expected    = "$TestDrive\MyModule\$sourcePath\MyModule.psm1"
                },
                @{  key         = 'BuildPath'
                    expected    = "$TestDrive\MyModule\BuildOutput\6.19.0"
                },
                @{  key         = 'BuildManifestPath'
                    expected    = "$TestDrive\MyModule\BuildOutput\6.19.0\MyModule.psd1"
                },
                @{  key         = 'BuildModulePath'
                    expected    = "$TestDrive\MyModule\BuildOutput\6.19.0\MyModule.psm1"
                },
                @{  key         = 'PSSASettingsPath'
                    expected    = "$TestDrive\MyModule\Tests\PSSASettings.psd1"
                },
                @{  key         = 'PSSACustomRulesPath'
                    expected    = "$TestDrive\MyModule\Tests\CustomRules"
                }
            )

            Set-Location -Path 'TestDrive:\MyModule'
            git init
            $testEnv = Get-TestEnvironment -PSSASettingsName 'PSSASettings.psd1' -PSSACustomRulesFolderName 'CustomRules'
            It 'should have the correct value for <key>' -TestCases $tests {
                Param (
                    $key,
                    $expected
                )

                $testEnv.$key | Should -Be $expected
            }

            $testEnv = Get-TestEnvironment -PSSASettingsName 'ScriptAnalyzerSettings.psd1' -PSSACustomRulesFolderName 'SomeCustomRules'
            It "should pass if 'PSSASettingsPath' and 'PSSACustomRulesPath' are empty when the files cannot be found" {
                $testEnv.PSSASettingsPath | Should -Be ''
                $testEnv.PSSACustomRulesPath | Should -Be ''
            }
        } #end Context
    } #end ForEach

    Set-Location -Path $currLoc
} 
