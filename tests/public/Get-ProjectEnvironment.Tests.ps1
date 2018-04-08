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

Describe 'Function Testing - Get-ProjectEnvironment' {

    $moduleName = 'MyModule'
    $currLoc = Get-Location
    $sources = @( $moduleName, 'source', 'src' )
    ForEach ($sourcePath in $sources) {
        Context "Output - Source Path is '$sourcePath'" {  
            @(  "TestDrive:\$moduleName\$sourcePath", 
                "TestDrive:\$moduleName\BuildOutput\6.19.0",
                "TestDrive:\$moduleName\Tests\CustomRules"
            ) | ForEach-Object { New-Item -Path $_ -ItemType Directory }

            $tests = @( 
                @{  key         = 'ModuleName'
                    expected    = $moduleName
                },
                @{  key         = 'ProjectRootPath'
                    expected    = "$TestDrive\$moduleName"
                },
                @{  key         = 'SourcePath'
                    expected    = "$TestDrive\$moduleName\$sourcePath"
                },
                @{  key         = 'BuildRootPath'
                    expected    = "$TestDrive\$moduleName\buildoutput"
                },
                @{  key         = 'OutputPath'
                    expected    = "$TestDrive\$moduleName\output"
                },
                @{  key         = 'TestPath'
                    expected    = "$TestDrive\$moduleName\tests"
                }
            )

            Set-Location -Path "TestDrive:\$moduleName"
            # initial the repo so that we can find the project root
            git init
            $projEnv = Get-ProjectEnvironment
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
