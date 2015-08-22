//
//  PXCameraView.h
//
//  Created by Daniel Blakemore on 9/11/13.
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

#import "PXSpanPicker.h"
#import "PXFlashControl.h"
#import "PXCameraButton.h"
#import "PXLibraryButton.h"
#import "PXCameraGridLayer.h"

#import "PXPinnedRotationView.h"

typedef NS_ENUM(NSInteger, PXCameraViewType) { // NSAlrightyThen
    PXCameraViewTypeCamera = 0,
    PXCameraViewTypePreview,
};

/**
 *  View displaying the camera preview and controls.
 */
@interface PXCameraView : PXPinnedRotationView

/**
 *  Picker for picking the shutter delay
 */
@property (nonatomic) PXSpanPicker * spanPicker;

/**
 *  Button for choosing flash mode.
 */
@property (nonatomic) PXFlashControl * flashButton;

/**
 *  Button to switch camera from front-facing to back-facing.
 */
@property (nonatomic) UIButton * switchCamera;

/**
 *  Display grid overlay.
 */
@property (nonatomic) UIButton * gridButton;

/**
 *  Button for opening the photo library.
 */
@property (nonatomic) PXLibraryButton * photoLibrary;

/**
 *  Shutter button.
 */
@property (nonatomic) PXCameraButton * takePhoto;

/**
 *  Button to return to the previous view.
 */
@property (nonatomic) UIButton * backButton;

/**
 *  A view showing the captured image after it has been taken from the camera while processing occurs.
 */
@property (nonatomic) UIImageView * imagePreview;

/**
 *  Live preview of camera feed.
 */
@property (nonatomic) UIView * cameraView;

/**
 *  The state of the camera view.
 */
@property (nonatomic) PXCameraViewType state;

- (id)init;

- (void) reset;
- (void) flash;
- (void) flashOn;
- (void) flashOff;

- (void) setFlashType:(PXFlashType)flashType;

@end
