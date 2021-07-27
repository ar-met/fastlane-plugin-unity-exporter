# unity_exporter plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-unity_exporter)


## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-unity_exporter`, add it to your project by running:

```bash
fastlane add_plugin unity_exporter
```


## About unity_exporter

Plugin for _fastlane_ that defines an action to export iOS and Android projects via [_Unity3d_](https://unity.com/). This allows _Unity3d_ to more easily integrate with _fastlane_. 

This action works by invoking _Unity3d_ via commandline to trigger an export of your _Unity3d_ project. [Per default _Unity3d_ supports a number of different commandline arguments.](https://docs.unity3d.com/Manual/CommandLineArguments.html) Therefore there are two ways to use the plugin: Either provide your own full list of commandline arguments or let the _fastlane plugin_ help you with some of it. This becomes clearer when looking at all [available actions](#actions).

For convenience and easier versioning, there also exists the [_Unity Build Exporter_](https://github.com/ar-met/unity-build-exporter) which can be added via the [_Unity Package Manager_](https://docs.unity3d.com/Manual/Packages.html). The _Unity Build Exporter_ provides a custom execute method that parses custom commandline arguments. See [_Unity Build Exporter_](https://github.com/ar-met/unity-build-exporter) for a more in-depth explanation of the package.

To make full use of the *unity_exporter* make sure to:
* Install the [_Unity Hub_](https://docs.unity3d.com/Manual/GettingStartedInstallingHub.html) at its default path: We use the _Unity Hub_ to get the paths of your _Unity Editor_ installations,  such that we can use the _Unity Editor_ version that matches the version used by your _Unity3d_ project when exporting a build.
* Add the [_Unity Build Exporter_](https://github.com/ar-met/unity-build-exporter) to your _Unity3d_ project: We invoke a specific `executeMethod` ([see docs](https://docs.unity3d.com/Manual/CommandLineArguments.html) and the [readme of the package](https://github.com/ar-met/unity-build-exporter/blob/master/Assets/BuildExporter/README.md) what's that about) provided by the package to handle versioning. Note that the package also exposes a new menu item to your _Unity3d_ project that helps with setting up _fastlane_ and the *fastlane-plugin-unity_exporter*.


## Getting Started with a blank _Unity3d_ project

Assuming you don't have _fastlane_ configured yet, we propose the following:
1) Add the [_Unity Build Exporter_](https://github.com/ar-met/unity-build-exporter) via the [_Unity Package Manager_](https://docs.unity3d.com/Manual/Packages.html) to your _Unity3d_ project
2) Open your _Unity3d_ project and find the menu items `Build Exporter / Initialize 'fastlane' directories for Android` and `Build Exporter / Initialize 'fastlane' directories for iOS`
3) Commit the changes to your repository
4) Navigate to `{Unity3d-project-root}/fastlane-build-exporter/iOS/unity-export` and `{Unity3d-project-root}/fastlane-build-exporter/Android/unity-export` and `fastlane init` respectively
5) Move the created `fastlane/` directory up one level, such that it is on the same hierarchical level as `unity-export/`
6) Commit the changes to your repository
7) See [Getting Started](#getting-started)
8) Use [the actions of the plugin](#actions)

We suggest you also check out the [_example Unity3d project_](https://github.com/ar-met/fastlane-plugin-unity-exporter-example-project).


## Actions

Two actions are provided by this plugin:
* `fastlane action unity_export`
* `fastlane action unity_commit_version_bump`

### Using `unity_export` with parameter `arguments`

Note that when writing `{path-to-unity}` we expect a path like so:
* Mac: `/Applications/Unity/Hub/Editor/<version>/Unity.app/Contents/MacOS/Unity`
* Windows: `"C:\Program Files\Unity\Hub\Editor\<version>\Editor\Unity.exe"`
* Linux: [see open issue](https://github.com/ar-met/fastlane-plugin-unity-exporter/issues/1)

```ruby
# for a full list of commandline arguments that are available to Unity see https://docs.unity3d.com/Manual/CommandLineArguments.html
# uses the Unity Hub to resolve the path to a Unity Editor installation
unity_export(arguments: "-batchmode -nographics -quit") 

# setting 'use_default_path' to 'false', will not resolve the path to a Unity Editor installation via the Unity Hub
# a path to a Unity Editor installation is expected as part of 'arguments'
unity_export(arguments: "{path-to-unity} -batchmode -nographics -quit", use_default_paths: false)
```

### Using `unity_export` with parameter `build_target` 

```ruby
# will export a Xcode project
unity_export(build_target: "iOS") 

# will export an Android project ('Export Project' is ticked, see https://docs.unity3d.com/Manual/android-BuildProcess.html)
unity_export(build_target: "Android")

# expects a semantic version and sets this version as the new Unity3d project version
# for semantic versioning see https://semver.org/
unity_export(build_target: "...", new_version: "1.2.3")

# increments the major, minor or patch part of the existing semantic version
unity_export(build_target: "...", new_version: "major")
unity_export(build_target: "...", new_version: "minor")
unity_export(build_target: "...", new_version: "patch")

# note that the plugin will keep the version code in sync across different platforms: version code (Android) and build number (iOS) will be the same
# expects a non-negative number and sets it as version code
unity_export(build_target: "...", new_version_code: "42")

# increments the existing version code (Android) and build number (iOS)
unity_export(build_target: "...", new_version_code: "increment")

# combined usage of 'new_version' and 'new_version_code'
unity_export(build_target: "...", new_version: "2.3.4", new_version_code: "0")
```

### Using `unity_commit_version_bump`

Uses [shell commands to commit a version bump](https://github.com/ar-met/fastlane-plugin-unity-exporter/blob/master/lib/fastlane/plugin/unity_exporter/actions/unity_commit_version_bump.rb), if there is any.

```ruby
# let's say we first export the Unity3d project
unity_export(build_target: "...", new_version: "3.4.5", new_version_code: "0")

# after the export is finished, we commit the version bump
unity_commit_version_bump
```


## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

Also check out the example [_Unity3d_ project](https://github.com/ar-met/fastlane-plugin-unity-exporter-example-project) to see how this plugin works. See the repositories readme for more details.


## Compatibility

Both this _fastlane plugin_ and the [_Unity Build Exporter_](https://github.com/ar-met/unity-build-exporter) were developed with _Unity 2020.3.13f1_. We haven't tested the plugin with any earlier versions, but we don't expect there to be any issues. If you run into trouble, regarding compatibility or anything else, [please open an issue](https://github.com/ar-met/unity-build-exporter/issues). For pull requests [see here](#pull-requests).


## Ruby

Note that this plugin requires `Ruby 2.7.4`. 

### Ruby on Mac

Installing ruby -- even different versions of it -- on Mac and _fastlane_ is well documented.

### Ruby on Windows

To install ruby on Windows you, e.g., can use [_RubyInstaller_](https://rubyinstaller.org/downloads/). Be sure to get `Ruby 2.7.4`. After that you can use `gem` commands with Windows' command prompt and rely on _fastlane_'s documentation to get you going.


## Pull requests

We are happy to accept [pull requests](https://github.com/ar-met/unity-build-exporter/pulls). For easier development of this plugin, we suggest you use the provided [_Unity3d_ project](https://github.com/ar-met/fastlane-plugin-unity-exporter-dev-project).


## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```


## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.


## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.


## Using _fastlane_ Plugins


For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).


## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
