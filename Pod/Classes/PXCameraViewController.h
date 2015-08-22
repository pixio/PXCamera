//
//  PXCameraViewController.h
//
//  Created by Daniel Blakemore on 9/17/13.
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "PXCamera.h"
#import "PXCameraView.h"

#import <PXPinnedRotation/PXPinnedRotationViewController.h>

@interface PXCameraViewController : PXPinnedRotationViewController

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

+ (PXCameraViewController*)sharedCamera;

/**
 *  The text for the shutter delay in the camera.  The default is @"shutter delay".
 */
@property (nonatomic) NSString * shutterDelayText;

/**
 *  Get an image using the camera and report back when done.
 *
 *  The completion you specify also takes a completion as an argument.  This second block should be 
 *  called when you are ready to dismiss the spinner in the camera.
 *
 *  @param vc         the presenting view controller for the camera
 *  @param completion a completion called with the resulting image, the source, and a block to call when it's complete
 */
+ (void)getImageInViewController:(UIViewController*)vc completion:(void(^)(UIImage*, PXCameraImageSource, void (^completion)()))completion;

/**
 *  Set completion for image capture.  Caller is responsible for navigation stack
 *
 *  @param completion block to call when image is captured
 */
- (void)setCompletion:(void (^)(UIImage*, PXCameraImageSource, void (^completion)()))completion;

@end