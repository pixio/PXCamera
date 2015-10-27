//
//  PXImagePickerHelper.m
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

#import "PXImagePickerHelper.h"

#import "PXCameraViewController.h"

static inline UIImage* getNormalizedImage(UIImage* originalImage);

@interface PXImagePickerHelper () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation PXImagePickerHelper

+ (PXImagePickerHelper*)sharedHelper
{
    static PXImagePickerHelper* _sharedHelper = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedHelper = [[PXImagePickerHelper alloc] init];
    });
    
    return _sharedHelper;
}

+ (void)getImageInViewController:(UIViewController*)vc completion:(void(^)(UIImage*, PXCameraImageSource))completion;
{
    [[PXImagePickerHelper sharedHelper] setCompletion:completion];
    
    [vc presentViewController:[[PXImagePickerHelper sharedHelper] imagePickerController] animated:TRUE completion:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        _tintColor = [UIColor blackColor];
        [self setImagePickerController:[[UIImagePickerController alloc] init]];
        [[self imagePickerController] setDelegate:self];
    }
    return self;
}

- (void(^)(UIImage*, PXCameraImageSource))completion
{
    return _completion;
}

#pragma mark -
#pragma mark UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    UIImage* originalImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (_completion) {
        _completion(getNormalizedImage(originalImage), PXCameraImageSourceLibrary);
        _completion = nil;
    }
    
    // Dismiss the picker controller
    [[picker presentingViewController] dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    if (_completion) {
        _completion(nil, PXCameraImageSourceLibrary);
        _completion = nil;
    }
    [[picker presentingViewController] dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark - Helper Methods

static inline UIImage* getNormalizedImage(UIImage* originalImage)
{
    UIImage* normalizedImage;
    
    if ([originalImage imageOrientation] == UIImageOrientationUp)
    {
        return originalImage;
    }
    
    CGRect rect = CGRectZero;
    rect.size = [originalImage size];
    UIGraphicsBeginImageContext(rect.size);
    [originalImage drawInRect:rect];
    normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

#pragma mark -
#pragma mark UINavigationController Delegate Methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[navigationController navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName : _tintColor}];
    [[navigationController navigationBar] setBarTintColor:_barTintColor];
    [[navigationController navigationBar] setTintColor:_tintColor];
}

@end
