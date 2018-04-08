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

Describe 'Function Testing - Get-FunctionParameter' {
    Context 'Input' {
        It 'should pass if mandatory parameters have not been changed' {
            $mandatoryParams = 'Name'
            $params = Get-FunctionParameter -Name 'Get-FunctionParameter' | Where-Object { $_.Value.Attributes.Mandatory -eq $true }
            
            @($params).count | Should -Be @($mandatoryParams).Count
            [bool]($params | ForEach-Object { $mandatoryParams -contains $_.key }) | Should -Be $true
        }
    }

    Context 'Output' {
        It 'should pass if all parameters, including Advanced Functions common parameters, are returned' {
            $params = @( 'Name', 'Exclude', 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', `
                'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', `
                'OutVariable', 'OutBuffer', 'PipelineVariable' )
            $result = Get-FunctionParameter -Name 'Get-FunctionParameter' -Exclude @()

            @($result).count | Should -Be @($params).Count
            [bool]($result | ForEach-Object { $params -contains $_.key }) | Should -Be $true
        }
    }
} 
