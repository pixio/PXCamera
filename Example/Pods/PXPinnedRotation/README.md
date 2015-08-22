# PXPinnedRotation

[![Version](https://img.shields.io/cocoapods/v/PXPinnedRotation.svg?style=flat)](http://cocoapods.org/pods/PXPinnedRotation)
[![License](https://img.shields.io/cocoapods/l/PXPinnedRotation.svg?style=flat)](http://cocoapods.org/pods/PXPinnedRotation)
[![Platform](https://img.shields.io/cocoapods/p/PXPinnedRotation.svg?style=flat)](http://cocoapods.org/pods/PXPinnedRotation)

## Usage

`PXPinnedRotation` allows you to create views that use pinned rotation:

![Pinned Rotation](pinned.gif)

Your views will stay in place but rotate when the phone rotates like with the library and filter buttons in the Camera app in iOS.

There are a few things that you need to do to use `PXPinnedRotation`:

1. Subclass `PXPinnedRotationView` and `PXPinnedRotationViewController`.
2. Call `[self addSubviewToAnimate:]` with your animated subviews (buttons, labels, etc.).
3. Call `[self manuallyStartLayoutPass]` at the end of init.
4. Implement `-(NSArray*)calculateBaseConstraintsBeforeLayoutPass` and put all the code in here that you would normally put in `-(void)updateConstraints`.

Any views you have specified to animate will be animated.  Anything else will not change at all during rotation. 

There are blocks you can assign on the view controller if you need additional behavior during or after rotation.  Check out the headers for more info.

There's also the example project shown above.  To run it, clone the repo, and run `pod install` from the Example directory first.

## Installation

PXPinnedRotation is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PXPinnedRotation"
```

## Author

Daniel Blakemore, DanBlakemore@gmail.com

## License

PXPinnedRotation is available under the MIT license. See the LICENSE file for more info.
