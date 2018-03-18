# PSBuildHelper

Contains functions to help you build, maintain and manage your modules.

# Module File & Folder Structure

The module function expect to find your file and folder structure as follows:

```
<PROJECTROOT>
    |_ source / src / <PROJECTROOT> [required] (1)
    |   |
    |   |_ en-US [optional] (for help files) (2)
    |   |_ public [required] (public functions that will be exported)
    |   |_ private [optional] (private functions that will not be exported)
    |   |_ scripts [optional] (scripts included with your module)
    |   |_ <PROJECTROOT>.psd1 (your module manifest) (3)
    |   |_ *.Format.ps1xml [optional] (included in the manifest to be loaded)
    |   |_ *.ps1 [optional] (these will be included in the module build) (4)
    |
    |_ test* [optional] (Pester tests) (5)
    |   |
    |   |_ public [optional] (public function tests)
    |   |_ private [optional] (private function tests)
    |
    |_ .build.ps1 [required] (Invoke-Build script) (6)
    |_ CHANGELOG.md [optional] (module changelog)
    |_ README.md [optional] (GitHub README file)
    |_ LICENSE [optional] (module license)
    |
    |_ buildoutput [created by build process] (holds all built module versions)
    |   |_ <VERSION> [created by build process] (your built module)
    |
    |_ output [created by build process] (holds output of tests)
    |
    |_ help [created by build process] (holds markdown generated help files) (7)
```

Where <PROJECTROOT> is the root folder of your project and is also the module name.

* (1) - The source folder can be called 'source', 'src' or the name of your project. Any of these will be detected;
* (2) - if this folder does not exist it will be created if the external help file is created. Only en-US is supported at the moment;
* (3) - this manifest file has to be named as your <PROJECTROOT> to be found;
* (4) - Any .ps1 scripts found in the source folder will be included in the final module build so be careful what you have in there;
* (5) - The test folder is searched for using the wildcard test* so can be called test, tests, testing, tested etc.;
* (6) - This build script is required and can simply dot inlcude the main build script but this is where we start;
* (7) - If you have comment based help in your functions then they will be used to create Markdown help files in this folder;


# Contributing

* Source hosted at [GitHub](https://github.com/pauby/psmodulebuildhelper)
* Report issues/questions/feature requests on [GitHub Issues](https://github.com/pauby/psmodulebuildhelper/issues)

Pull requests are very welcome! Make sure your patches are well tested. Ideally create a topic branch for every separate change you make. For example:

* Fork the repo
* Create your feature branch (git checkout -b my-new-feature)
* Commit your changes (git commit -am 'Added some feature')
* Push to the branch (git push origin my-new-feature)
* Create new Pull Request
