//
//  PXCamera.h
//
//  Created by Daniel Blakemore on 8/21/15.
//
//  Copyright (c) 2015 Pixio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>

/**
 *  The different image sources from which images can be retrieved.
 */
typedef NS_ENUM(NSInteger, PXCameraInterface){
    /**
     *  Get a photo from the library using the standard @c UIImagePickerController UI.
     */
    PXCameraInterfaceLibrary,
    /**
     *  Get a photo from the camera using a custom camera interface.
     */
    PXCameraInterfaceCamera,
};

/**
 *  The final source of the image returned.
 */
typedef NS_ENUM(NSInteger, PXCameraImageSource){
    /**
     *  The image was selected from the photo library.
     */
    PXCameraImageSourceLibrary,
    /**
     *  The image was taken from the camera.
     */
    PXCameraImageSourceCamera,
    /**
     *  No image was retrieved.
     */
    PXCameraImageSourceNone,
};

/**
 *  The authorization status of the image sources (camera or library).
 */
typedef NS_ENUM(NSInteger, PXCameraAuthorizationStatus) {
    /**
     *  The user hasn't been asked yet.
     */
    PXCameraAuthorizationStatusNotDetermined,
    /**
     *  The user can't use the image source and can't change that fact.
     */
    PXCameraAuthorizationStatusRestricted,
    /**
     *  The user said no when you asked.
     */
    PXCameraAuthorizationStatusDenied,
    /**
     *  The user said yes when you asked.
     */
    PXCameraAuthorizationStatusAuthorized,
};

/**
 *  Central class for interfacing with all the various image classes (camera, library).
 */
@interface PXCamera : NSObject

/**
 *  Shared singleton.
 */
+ (instancetype)camera;

/**
 *  The authorization state of the camera.
 */
- (PXCameraAuthorizationStatus)cameraAuthorized;

/**
 *  The authorization state of the photo library.
 */
- (PXCameraAuthorizationStatus)photosAuthorized;

#pragma mark - Configurable Properties
#pragma mark Photo Library

/**
 *  The color used for the buttons and titles in the navigation bars. 
 *  The default is @c blackColor.
 */
@property (nonatomic) UIColor * tintColor;

/**
 *  The bar color used in the navigation bars. The default color is whiteColor;
 */
@property (nonatomic) UIColor * barTintColor;

#pragma mark Camera

/**
 *  The text for the shutter delay in the camera.  The default is @"shutter delay".
 */
@property (nonatomic) NSString * shutterDelayText;

#pragma mark - Image capture methods

/**
 *  Get an image asynchronously from the camera, library, or web. Calls the completion when an image is picked or picking is canceled.
 *
 *  @param vc         the view controller with which to present the image
 *  @param interface  the interface from which to get the image
 *  @param completion a block to run with the retrieved image
 */
- (void)getImageInViewController:(UIViewController*)vc interface:(PXCameraInterface)interface completion:(void(^)(UIImage*, PXCameraImageSource))completion;

- (instancetype)init __attribute__((unavailable("use the camera singleton")));

@end
