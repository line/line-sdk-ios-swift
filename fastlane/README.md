fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios to_beta

```sh
[bundle exec] fastlane ios to_beta
```

Switch to Beta environment

### ios tests

```sh
[bundle exec] fastlane ios tests
```

Run tests.

### ios sdk_tests

```sh
[bundle exec] fastlane ios sdk_tests
```



### ios sample_tests

```sh
[bundle exec] fastlane ios sample_tests
```



### ios lint

```sh
[bundle exec] fastlane ios lint
```

Lint to check dependency manager compatibility.

### ios lint_pod

```sh
[bundle exec] fastlane ios lint_pod
```



### ios lint_spm

```sh
[bundle exec] fastlane ios lint_spm
```



### ios release

```sh
[bundle exec] fastlane ios release
```

Release a new version.

### ios doc

```sh
[bundle exec] fastlane ios doc
```

Generate documentation

### ios doc_internal

```sh
[bundle exec] fastlane ios doc_internal
```

Generate documentation for internal usage

### ios change_log

```sh
[bundle exec] fastlane ios change_log
```



### ios ensure_latest_carthage

```sh
[bundle exec] fastlane ios ensure_latest_carthage
```



### ios bump_constant_version

```sh
[bundle exec] fastlane ios bump_constant_version
```



### ios bump_reference_top_version

```sh
[bundle exec] fastlane ios bump_reference_top_version
```



### ios xcframework

```sh
[bundle exec] fastlane ios xcframework
```

Create binary frameworks with the `xcframework` format under the `build/` folder.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
