## v0.0.2 5 April 2018

* Updated the module requirements to PowerShell 5;
* Added functionality to read a configuration file. At the moment only module and Chocolatey dependencies are supported and you can now specify a CodeCoverageThreshold (by default it will still be 80%). Configuration file is 'build.configuration.psd1' and should exist in the project root path. To support this functionality three new functions have been created - Initialize-BuildDependency, Install-ChocolateyPackage and Install-DependentModule;
* Added a InitDependencies task that will install the module dependencies from the configuration file. This is intended to be used where the build environment needs to be created before the build starts (such as in a CI / DC pipeline);
* Renamed the BuildSystem names for 'GitLab CI' to 'GitLab' and 'Travis CI' to 'Travis';
* Fixed issue with Get-GitBranchName, Get-GitLastCommitHash and Get-GitLastCommitMessage failing the Pester test if it was not run in a Git repo;
* Fixed issue when the module was building itself the CreateCodeHealthReport would just loop by creating a custom task list;
* Added tests for Get-ProjectRoot function;
* Fixed issue where Publish-Module would fail as the -RequiredVersion parameter was being cast to [Version];



## v0.0.1 Initial Release