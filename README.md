# Switchboard for iOS & macOS

[![Build Status](https://travis-ci.com/KeepSafe/Switchboard-iOS.svg?token=FkPqyrwwnAY4pErzdxwy&branch=master)](https://travis-ci.com/KeepSafe/Switchboard-iOS)
[![Apache 2.0 licensed](https://img.shields.io/badge/license-Apache2-blue.svg)](https://github.com/KeepSafe/Switchboard-iOS/blob/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/v/Switchboard.svg?maxAge=10800)]()
[![Swift 3+](https://img.shields.io/badge/language-Swift-blue.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/OS-iOS-orange.svg)](https://developer.apple.com/ios/)
[![macOS](https://img.shields.io/badge/OS-macOS-orange.svg)](https://developer.apple.com/macos/)

Simple A/B testing and feature flags for iOS & macOS built on top of [Switchboard](https://github.com/KeepSafe/Switchboard).

## What it does

Switchboard is a simple way to remote control your mobile application even after you've shipped it to your users' devices, so you can use Switchboard to:

- Stage-rollout new features to users
- A/B-test user flows, messaging, colors, features, etc.
- anything else you want to remote-control

Switchboard lets you control what happens in your app in a quick, easy, and useful manner.

Additionally, Switchboard segments your users consistently; because user segmentation is based upon a UUID that is computed once, the experience you switch on and off using Switchboard is consistent across sessions.

## What it does not do

Switchboard does not give you analytics, nor does it do automatic administration and optimization of your A/B tests. It also doesn't give you nice graphs and stuff. You can get all of that by plugging an analytics package into your app which you're probably doing anyway.

There are convenient hooks for this by conforming to the `SwitchboardAnalyticsProvider` protocol and `SwitchboardExperiment` and `SwitchboardFeature` subclasses also have a convenient `track(event...)` method you can call as well. See the example app for more detail.

## Installation

Quickly install using [CocoaPods](https://cocoapods.org): 

```ruby
pod 'Switchboard'
```

Or [Carthage](https://github.com/Carthage/Carthage):

```
github "KeepSafe/Switchboard-iOS"
```

Or [manually install it](#manual-installation)

## Example Usage

There is an example app under the `SwitchboardExample` target within the project file that you can run and see the debug user interface. This debug interface comes in handy when you want to test various flows within your app (e.g. enable `featureA` and verify the code does X, then disable `featureA` and verify the code does Y) or you want to put yourself into a given experiment cohort to see what that user experience will look like to others. 

The example might also be helpful in showing you our Switchboard setup recommendations so you can more easily integrate the debug interface into your own app.

![Switchboard Debug](https://user-images.githubusercontent.com/30269720/31296028-c2812356-aa95-11e7-83c8-336266f2497e.gif)

## Manual Installation

1. Clone this repository and drag the `Switchboard.xcodeproj` into the Project Navigator of your application's Xcode project.
  - It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.
2. Select the `Switchboard.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
3. Select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the `Targets` heading in the sidebar.
4. In the tab bar at the top of that window, open the `General` panel.
5. Click on the `+` button under the `Embedded Binaries` section.
6. Search for and select the top `Switchboard.framework` for iOS or macOS.

And that's it!

The `Switchboard.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

## Issues & Bugs
Please use the [Github issue tracker](https://github.com/KeepSafe/Switchboard-iOS/issues) to let us know about any issues you may be experiencing.

## License

Switchboard for iOS / macOS is licensed under the [Apache Software License, 2.0 ("Apache 2.0")](https://github.com/KeepSafe/Switchboard-iOS/blob/master/LICENSE)

## Authors

Switchboard for iOS / macOS is brought to you by [Rob Phillips](https://github.com/iwasrobbed) and the rest of the [Keepsafe team](https://www.getkeepsafe.com/about.html). We'd love to have you contribute or [join us](https://www.getkeepsafe.com/careers.html).

## Used in production by

- Keepsafe (www.getkeepsafe.com)
