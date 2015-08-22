//
//  PXPinnedRotationView
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


/**
 *  PXPinnedRotationView is the root view that allows subviews to be pinned.
 *  This class is intended to be subclassed. Subclasses should override
 *  calculateBaseConstraintsBeforeLayoutPass to setup constraints. The view
 *  should be set as the view of a PXPinnedRotationViewController.
 *
 *  @seealso PXPinnedRotationViewController
 *  @seealso calculateBaseConstraintsBeforeLayoutPass
 */
@interface PXPinnedRotationView : UIView

@property(nonatomic) UIInterfaceOrientation orientation;

/**
 *  List of views that will be pinned.
 *
 *  @seealso addViewToAnimate:
 *  @seealso addViewsToAnimate:
 */
@property (nonatomic, readonly) NSArray * viewsToAnimateRotation;

- (void)addViewToAnimate:(UIView*)view;
- (void)addViewsToAnimate:(NSArray*)views;
- (void)removeViewToAnimate:(UIView*)view;

/**
 *  Calculate all view contraints outside of the UIKit update/layout loop.
 *
 *  Subclasses should use this method instead of update contraints for efficient and correct
 *  pinned rotation. There is no need to call super.
 *
 *  Constraints returned by this method are not guaranteed to survive the layout process.
 *  To keep an up-to-date reference to a constraint (to change it's constant for example)
 *  use method -registerUpdateHandler:forConstraint:.
 *
 *  @see -registerUpdateHandler:forConstraint:
 *
 *  @return an array of all constraints for the view.
 */
- (NSArray*)calculateBaseConstraintsBeforeLayoutPass;

/**
 *  Manually trigger constraint generation and layout.
 *  
 *  This should be done after subclasses init is finished.
 */
- (void)manuallyStartLayoutPass;

/**
 *  Registers an update handler to let the caller know when a constraint has been rebuilt for pinned rotation.
 *
 *  Constraints for which references need to be kept to change them after layout should have handlers registered
 *  to provide the caller with the most up-to-date pointer to the constraint.
 *
 *  @param updateHandler a block called any time the constraint is rebuilt
 *  @param constraint    the initial constraint to track
 *  @param identifier    a string to uniquely identify this constraint (with respect to others the caller may also register handlers for)
 */
- (void)registerUpdateHandler:(void (^)(NSLayoutConstraint * constraint))updateHandler forConstraint:(NSLayoutConstraint*)constraint identifier:(NSString*)identifier;

@end