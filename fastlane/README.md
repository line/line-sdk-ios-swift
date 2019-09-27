fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios to_beta
```
fastlane ios to_beta
```
Switch to Beta environment
### ios tests
```
fastlane ios tests
```
Run tests.
### ios sdk_tests
```
fastlane ios sdk_tests
```

### ios sample_tests
```
fastlane ios sample_tests
```

### ios lint
```
fastlane ios lint
```
Lint to check Carthage and CocoaPods compatibility.
### ios lint_pod
```
fastlane ios lint_pod
```

### ios lint_carthage
```
fastlane ios lint_carthage
```

### ios release
```
fastlane ios release
```
Release a new version.
### ios doc
```
fastlane ios doc
```
Generate documentation
### ios doc_internal
```
fastlane ios doc_internal
```
Generate documentation for internal usage
### ios change_log
```
fastlane ios change_log
```

### ios ensure_latest_carthage
```
fastlane ios ensure_latest_carthage
```

### ios bump_constant_version
```
fastlane ios bump_constant_version
```

### ios bump_reference_top_version
```
fastlane ios bump_reference_top_version
```

### ios xcframework
```
fastlane ios xcframework
```
Create binary frameworks with the `xcframework` format under the `build/` folder.

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
