//
//  PXPinnedRotationViewController
//
//  Created by acobb on 5/16/14.
//  Updated and finished by Daniel Blakemore ca. 9/26/14.
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
#import <UIKit/UIKit.h>

@class PXPinnedRotationView;

/**
 *  PXPinnedRotationViewController is intended to be subclassed, but can also
 *  be used without subclassing by using setView: and setting the view to be a
 *  subclass of PXPinnedRotationView.
 */
@interface PXPinnedRotationViewController : UIViewController

- (PXPinnedRotationView*)rotationView;

/**
 *  Block to be run when rotation begins.  Will not animate as rotation animations are disabled.
 */
@property (nonatomic, copy) void (^onRotationBlock)(UIInterfaceOrientation newOrientation);

/**
 *  Block to run when the rotation ends.  Will be animated.
 */
@property (nonatomic, copy) void (^postRotationBlock)(UIInterfaceOrientation newOrientation);

@end