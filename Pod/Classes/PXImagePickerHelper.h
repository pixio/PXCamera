//
//  PXImagePickerHelper.h
//
//  Created by Daniel Blakemore on 9/27/13.
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

#import "PXCamera.h"

/**
 *  Helper class for interfacing with UIImagePickerController.
 */
@interface PXImagePickerHelper : NSObject

/**
 *  The color used for the buttons and titles in the navigation bar. 
 *  The default is @c blackColor.
 */
@property (nonatomic, nullable) UIColor * tintColor;

/**
 *  The bar color used in the navigation bar. The default color is whiteColor;
 */
@property (nonatomic, nullable) UIColor * barTintColor;

/**
 *  Image picker controller that backs the helper.
 */
@property (nonatomic, nonnull) UIImagePickerController * imagePickerController;

/**
 *  Completion to call with 
 */
@property (nonatomic, copy, nullable) void(^completion)(UIImage* _Nullable, PXCameraImageSource);

/**
 *  Generate the singleton.  This allows you to generate the singleton ahead of 
 *  time so it doesn't hang when the user accesses the photo library first time.
 *
 *  @return a singleton with no exposed methods
 */
+ (nonnull PXImagePickerHelper*)sharedHelper;

/**
 *  Get an image asynchronously from the camera, library, or web. Calls the completion when an image is picked or picking is canceled.
 *
 *  @param vc         the view controller with which to present the image
 *  @param completion a block to run with the retrieved image
 */
+ (void)getImageInViewController:(nonnull UIViewController*)vc completion:(nullable void(^)(UIImage* _Nullable, PXCameraImageSource))completion;

@end
