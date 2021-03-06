//
//  PXFlashButton.h
//
//  Created by Daniel Blakemore on 10/11/13.
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

#import "PXCameraCaptureManager.h"

typedef NS_ENUM(NSInteger, PXFlashControlState) {
    PXFlashControlStateCollapsed,
    PXFlashControlStateExpanded,
};

typedef NS_ENUM(NSInteger, PXFlashControlOrientation) {
    PXFlashControlOrientationPortrait,
    PXFlashControlOrientationLandscape,
};

@interface PXFlashControl : UIControl

@property (nonatomic) PXFlashType value;
@property (nonatomic) PXFlashControlState fcState;

/**
 *  Call to set the buttons to collapsed mode.
 */
- (void) collapse;

/**
 *  Call to set the buttons to expanded mode.
 */
- (void) expand;

/**
 *  Set the orirentation of the flash control to change layout to be compatible with pinned rotation.
 *
 *  @param orientation the new orientation
 */
- (void) setOrientation:(PXFlashControlOrientation)orientation;

/**
 *  Returns the individual views for each flash symbol for in-place animation purposes.
 *
 *  @return an array of the individual image views
 */
- (NSArray<UIImageView *>*) individualViews;

@end
