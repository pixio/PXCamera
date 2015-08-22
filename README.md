# PXCamera

[![Version](https://img.shields.io/cocoapods/v/PXCamera.svg?style=flat)](http://cocoapods.org/pods/PXCamera)
[![License](https://img.shields.io/cocoapods/l/PXCamera.svg?style=flat)](http://cocoapods.org/pods/PXCamera)
[![Platform](https://img.shields.io/cocoapods/p/PXCamera.svg?style=flat)](http://cocoapods.org/pods/PXCamera)

## Usage

Get images from the camera or photo library with one call.  No delegates, no initialization.

```objective-c
[[PXCamera camera] getImageInViewController:self interface:PXCameraInterfaceCamera completion:^(UIImage * image, PXCameraImageSource source) {
    // boom! image and analytics data about where the image came from (camera or library)
}];

// or 

[[PXCamera camera] getImageInViewController:self interface:PXCameraInterfaceLibrary completion:^(UIImage * image, PXCameraImageSource source) {
    
}];
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

PXCamera is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PXCamera"
```

## Author

Daniel Blakemore, DanBlakemore@gmail.com

## License

PXCamera is available under the MIT license. See the LICENSE file for more info.
