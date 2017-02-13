//
//  PXCameraCaptureManager.h
//  Pixio
//
//  Created by Daniel Blakemore on 9/18/13.
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
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, PXFlashType) {
    PXFlashTypeAuto,
    PXFlashTypeOn,
    PXFlashTypeOff,
    PXFlashTypeUnavailable,
};

@protocol PXCameraCaptureManagerDelegate;

@interface PXCameraCaptureManager : NSObject

/**
 *  Shared singleton.
 */
+ (nonnull instancetype) captureManager;

/**
 *  The flash mode to use.
 */
@property (nonatomic) PXFlashType flashType;

/**
 *  A view that displays the current camera output.
 */
@property (nonatomic, readonly, nonnull) UIView * cameraPreviewView;

/**
 *  The orientation of the camera interface.  This dictates the orientation of the video output into the preview view.  
 *  If your camera supports rotation, set this as your interface rotates.
 */
@property (nonatomic) UIInterfaceOrientation cameraPreviewOrientation;

/**
 *  Delegate called for various events.
 */
@property (nonatomic, weak, nullable) id <PXCameraCaptureManagerDelegate> delegate;

/**
 *  Switch the cameras (front to back, back to front)
 *
 *  @return whether the cameras switched
 */
- (BOOL) toggleCamera;

/**
 *  Whether or not flash is supported by the current camera.  This may change after a call to @c -toggleCamera.
 */
- (BOOL) isFlashSupported;

/**
 *  Start the camera capture.  This starts getting camera data and playing it back in the preview view.
 */
- (void) start;

/**
 *  Stop the camera capture.  This stops the camera preview view from updating.
 *  You should stop the capture manager whenever it is not visible to save battery life.
 */
- (void) stop;

/**
 *  Capture an image from the camera.
 *
 *  @param block a block called with the captured image.
 */
- (void) captureStillImageWithBlock:(nullable void(^)(UIImage* _Nullable))block;

- (nullable instancetype) init __attribute__((unavailable("use the singleton")));

@end

/**
 *  These delegate methods can be called on any arbitrary thread. If the delegate does something with the UI when called, make sure to send it to the main thread.
 */ 
@protocol PXCameraCaptureManagerDelegate <NSObject>
@optional
- (void) captureManager:(nullable PXCameraCaptureManager *)captureManager didFailWithError:(nullable NSError *)error;
- (void) captureManagerStillImageCaptured:(nullable PXCameraCaptureManager *)captureManager;
- (void) captureManagerDeviceConfigurationChanged:(nullable PXCameraCaptureManager *)captureManager;
@end
