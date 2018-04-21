## v0.2.0 21 April 2018
* Changed the logic of release notes being used - only use them if nothing is in the ReleaseNotes field of the manifest and then use the release notes from the changelog or if we can't extract them use the URL to the changelog itself;
* The Initialize-TestEnvironment function now loads the module being tested into the Global scope. This was to get around the issue of it being loaded inside this modules' scope;
* Removed required module 'Configuration';
* Added required module 'PowerShellGet';
* Renamed 'buildoutput' folder to 'releases';
* Fixed issue with Initialize-TestEnvironment function which was showing errors trying to remove the module being tested when it hadn't been loaded;
* Added option to add content to the top and bottom of the module script. This is done using the ModuleScript.Header and ModuleScript.Footer properties in the build configuration file. These values must be strings but can be a multi-line script (ie. @"<CONTENT>"@);
 
## v0.1.0 8 April 2018
* Removed the dependency on the 'Configuration' module - we were really only using this to create a build manifest. Now we create a build manifest using the source fields as a template and updating those fields we need to. If you use comments in the source manifest they will be lost as we are effectively building a new one;
* If you do not specify the ProjectUri, LicenseUri (and you have a LICENSE file in the project root path) or ReleaseNotes (and you have a CHANGELOG.md in the project root path) and you have an 'origin' git remote repo then these will be automatically populated;
* Added a feature to pull the release notes from the CHANGELOG.md file but the file must end with two blank lines if the last release notes are to be used;
* Changed module help folder to 'en-US';

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