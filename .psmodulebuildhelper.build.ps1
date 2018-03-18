[CmdletBinding()]
Param (
    [String]
    $ReleaseType = 'Unknown',

    [string]
    $GitHubUsername = $env:GITHUB_USERNAME,

    [string]
    $GitHubApiKey = $env:GITHUB_API_KEY,

    [string]
    $PSGalleryApiKey = $env:PSGALLERY_API_KEY
)

if (-not $PSBoundParameters.ContainsKey('Verbose')) {
    $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
}

$params = @{
    ReleaseType     = $ReleaseType
    GitHubUserName  = $GitHubUsername
    GitHubApiKey    = $GitHubApiKey
    PSGalleryApiKey = $PSGalleryApiKey
}

# do this so that the module can build itself
'pub*', 'priv*', 'script*' | ForEach-Object { 
    $dir = Get-ChildItem -Path "source\$_" -Directory
    Get-ChildItem -Path "$dir\*.ps1" -File | ForEach-Object {
        Write-Verbose "Dot-sourcing '$_'"
        . $_ 
    } 
}

. .\source\Start-ModuleBuild.ps1 @params