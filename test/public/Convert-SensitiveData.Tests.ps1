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

Describe 'Function Testing - Convert-SensitiveData' {
    Context 'Input' {
        # if this is the first test being run after module import then it
        # may fail the fiorst time it is run - it looks like it may be too
        # quick between importing the function and it appearing in Function:.
        # solution would be to move this so it is not the first test.
        It 'should be true if mandatory parameters have not been changed' {
            $mandatoryParams = @( 'InputObject' )
            $result = Get-FunctionParameter -Name 'Convert-SensitiveData' | Where-Object { $_.Value.Attributes.Mandatory -eq $true }
            
            @($result).count | Should -Be @($mandatoryParams).Count
            [bool]($result | ForEach-Object { $mandatoryParams -contains $_.key }) | Should -Be $true  
        }

        It 'should throw for a $null or empty input object' {
            { Convert-SensitiveData -InputObject $null } | Should throw
            { $null | Convert-SensitiveData -ErrorAction Stop } | Should throw

            $emptyObj = New-Object -TypeName PSObject
            { Convert-SensitiveData -InputObject $emptyObj } | Should throw
            { $emptyObj | Convert-SensitiveData -ErrorAction Stop } | Should throw
        }
    }

    Context 'Output' {
        It 'should pass by masking object values with matching keys using default keywords' {
            $test = [PSCustomObject]@{ 
                Name         = 'Luke Skywalker'
                JediPassword = 'Han Solo'
                LoginKey     = 'lightsaber'
                AuthToken    = 'falcon'
                Sister       = 'Leia' 
            }
            $expected = [PSCustomObject]@{  
                Name            = 'Luke Skywalker'
                JediPassword    = '*****'
                LoginKey        = '*****'
                AuthToken       = '*****'
                Sister          = 'Leia'
            }

            $result = Convert-SensitiveData -InputObject $test
            Compare-Object -ReferenceObject $expected -DifferenceObject $result `
                -Property Name, JediPassword, LoginKey, AuthToken, Sister | Should -Be $null
        } 

        It 'should pass by masking object values with matching keys with passed keywords' {
            $test = [PSCustomObject]@{ 
                Name         = 'Luke Skywalker'
                JediPassword = 'Han Solo'
                LoginKey     = 'lightsaber'
                AuthToken    = 'falcon'
                Sister       = 'Leia' 
            }
            $expected = [PSCustomObject]@{  
                Name         = '*****'
                JediPassword = 'Han Solo'
                LoginKey     = 'lightsaber'
                AuthToken    = 'falcon'
                Sister       = '*****'
            }

            $result = $test | Convert-SensitiveData -Keyword @('sis', 'name')
            Compare-Object -ReferenceObject $expected -DifferenceObject $result `
                -Property Name, JediPassword, LoginKey, AuthToken, Sister | Should -Be $null
        } 
    }
} 
