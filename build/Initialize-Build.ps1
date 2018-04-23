#Requires -RunAsAdministrator

[CmdletBinding()]
Param ()

$requiredModules = 'InvokeBuild', 'Configuration', 'platyPS', 'PSCodeHealth'
$chocoPackages = 'pandoc', '7zip'

# dependencies
$null = Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Write-Verbose 'Bootstrapping NuGet package provider.'
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
Set-PSRepository -Name PSGallery -InstallationPOlicy Trusted

Install-Module -Name PSModuleBuildHelper, InvokeBuild


# Configure git
if ($null -eq (Invoke-Expression -Command 'git config --get user.email')) {
    Write-Verbose 'Git is not configured so we need to configure it now.'
    Invoke-Expression -Command 'git config --global user.email "pauby@users.noreply.github.com"'
    Invoke-Expression -Command 'git config --global user.name "pauby"'
    Invoke-Expression -Command 'git config --global core.safecrlf false'
}