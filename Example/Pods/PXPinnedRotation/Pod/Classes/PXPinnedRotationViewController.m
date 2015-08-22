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

#import "PXPinnedRotationViewController.h"
#import "PXPinnedRotationView.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation PXPinnedRotationViewController
{
    BOOL _hideStatusBar;
}

- (PXPinnedRotationView*)rotationView
{
    return (PXPinnedRotationView*)[self view];
}

- (void)setView:(UIView *)view
{
    NSAssert(view == nil || [view isKindOfClass:[PXPinnedRotationView class]], @"View controller view must be a subclass of PXPinnedRotationView");
    [super setView:view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // do an initial layout pass to make sure we are laid out to the correct orientation
    [[self rotationView] setOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    if (_onRotationBlock) {
        _onRotationBlock([[UIApplication sharedApplication] statusBarOrientation]);
    }
    if (_postRotationBlock) {
        _postRotationBlock([[UIApplication sharedApplication] statusBarOrientation]);
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // check if this method is deprecated on this system or not.
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        // do something
        [UIView setAnimationsEnabled:NO];
        self.rotationView.orientation = toInterfaceOrientation;
        
        int halfPis[5];
        halfPis[UIInterfaceOrientationPortrait] = 0;
        halfPis[UIInterfaceOrientationLandscapeLeft] = 1;
        halfPis[UIInterfaceOrientationPortraitUpsideDown] = 2;
        halfPis[UIInterfaceOrientationLandscapeRight] = 3;
        
        int rots = (4 + (halfPis[toInterfaceOrientation] - halfPis[self.interfaceOrientation])) % 4;
        
        for (UIView* v in self.rotationView.viewsToAnimateRotation)
        {
            v.transform = CGAffineTransformMakeRotation(rots * M_PI_2);
        }
        
        _hideStatusBar = TRUE;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // check if this method is deprecated on this system or not.
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        // do something
        if (_onRotationBlock) {
            _onRotationBlock([[UIApplication sharedApplication] statusBarOrientation]);
        }
        
        [self.view.layer removeAnimationForKey:@"transform"];
        [self.view.layer removeAnimationForKey:@"bounds"];
        [self.view.layer removeAnimationForKey:@"position"];
        for (UIView* v in self.rotationView.viewsToAnimateRotation)
        {
            [v.layer removeAnimationForKey:@"bounds"];
            [v.layer removeAnimationForKey:@"position"];
        }
        
        // not sure why this block is needed, but it is...
        [UIView setAnimationsEnabled:YES];
        
        [UIView animateWithDuration:0 animations:^ {
            for (UIView* v in self.rotationView.viewsToAnimateRotation)
            {
                v.transform = CGAffineTransformIdentity;
            }
        }];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // check if this method is deprecated on this system or not.
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        // do something
        [UIView animateWithDuration:0.1 animations:^{
            _hideStatusBar = FALSE;
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // hide the status bar during rotation.
    _hideStatusBar = TRUE;
    [self setNeedsStatusBarAppearanceUpdate];
    
    // capture the old orientation
    UIInterfaceOrientation previousOrientation = self.interfaceOrientation;
    
    [UIView setAnimationsEnabled:NO];
    
//    NSLog(@"disabling animation");
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
//        NSLog(@"on rotation");
        if (_onRotationBlock) {
            _onRotationBlock([[UIApplication sharedApplication] statusBarOrientation]);
        }
        
        // rotate views to what would have been the current orientation if rotation was not enabled
        // so that then they can be rotated into the correct orientation as if all they have done is rotate (rather than teleport)
        int halfPis[5];
        halfPis[UIInterfaceOrientationPortrait] = 0;
        halfPis[UIInterfaceOrientationLandscapeLeft] = 1;
        halfPis[UIInterfaceOrientationPortraitUpsideDown] = 2;
        halfPis[UIInterfaceOrientationLandscapeRight] = 3;
        
        int rots = (4 + (halfPis[[[UIApplication sharedApplication] statusBarOrientation]] - halfPis[previousOrientation])) % 4;
        
        for (UIView* v in self.rotationView.viewsToAnimateRotation)
        {
            v.transform = CGAffineTransformMakeRotation(rots * M_PI_2);
        }
        
        // change constraints to match new screen.
//        NSLog(@"new constraints");
        self.rotationView.orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        NSLog(@"enabling animations");
        // enable animations only after rotation is entirely done
        [UIView setAnimationsEnabled:YES];
        
        // rotate views back into place once rotation has finished.  This is actually the only animation that the user sees.
        [UIView animateWithDuration:0.2 animations:^{
//            NSLog(@"post rotation");
            if (_postRotationBlock) {
                _postRotationBlock([[UIApplication sharedApplication] statusBarOrientation]);
            }
            
            for (UIView* v in self.rotationView.viewsToAnimateRotation)
            {
                v.transform = CGAffineTransformIdentity;
            }
            // show status bar as well.
            _hideStatusBar = FALSE;
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {
//            NSLog(@"Done");
            [UIView setAnimationsEnabled:YES];
        }];
    }];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)prefersStatusBarHidden
{
    return _hideStatusBar;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

@end
