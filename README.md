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

If you want to get a little bit more hands-on and make your own custom camera interface but don't want to manage all the hassle of AVFoundation, check out `PXCameraCaptureManager`.  This singleton provides a readonly `UIView` property `cameraPreviewView` that displays live camera output.  From there, you can connect your custom UI to the other methods in the interface that allow you to control the various aspects of the camera (flash mode, preview orientation, front -facing or back-facing camera).  Check out the `PXCustomCameraViewController` in the example project for a really basic example.

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
