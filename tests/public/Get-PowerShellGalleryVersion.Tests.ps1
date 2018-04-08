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

Describe 'Function Testing - Get-PowerShellGalleryVersion' {
    Context 'Input' {
        It 'should be true if mandatory parameters have not been changed' {
            $mandatoryParams = @( 'Name' )
            $result = Get-FunctionParameter -Name 'Get-PowerShellGalleryVersion' | Where-Object { $_.Value.Attributes.Mandatory -eq $true }
            
            @($result).count | Should -Be @($mandatoryParams).Count
            [bool]($result | ForEach-Object { $mandatoryParams -contains $_.key }) | Should -Be $true  
        }

        It 'should throw an exception for a blank or $null name' {
            { Get-PowerShellGalleryVersion -Name '' } | Should throw
            { Get-PowerShellGalleryVersion -Name $null } | Should throw
        }
    }

    Context 'Logic & Flow' {
        It "should return a version of '0.0.0' when it cannot find a module in the PowerShell Gallery" {
            $name = [System.Guid]::NewGuid().ToString()
            $result = Get-PowerShellGalleryVersion -Name $name
            $result | Should -BeOfType [Version]
            $result | Should -Be '0.0.0'
        }

        It "should return the latest version of Pester" {
            $minVersion = [Version](Get-Module -Name 'Pester').Version
            $result = Get-PowerShellGalleryVersion -Name 'Pester'
            $result | Should -BeOfType [Version]
            $result | Should -BeGreaterOrEqual $minVersion
        }
    }
}