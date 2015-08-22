//
//  PXCamera.m
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

#import "PXCamera.h"

#import "PXImagePickerHelper.h"
#import "PXCameraViewController.h"

@implementation PXCamera

+ (instancetype)camera
{
    static PXCamera * _camera = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _camera = [[PXCamera alloc] initCamera];
    });
    
    return _camera;
}

- (instancetype)initCamera
{
    self = [super init];
    if (self) {
        _shutterDelayText = @"shutter delay";
        _tintColor = [UIColor blackColor];
        _barTintColor = [UIColor whiteColor];
        
        // make the photo library helper early so it's faster
        [PXImagePickerHelper sharedHelper];
        [PXCameraViewController sharedCamera];
    }
    return self;
}

- (void)getImageInViewController:(UIViewController*)vc interface:(PXCameraInterface)interface completion:(void(^)(UIImage*, PXCameraImageSource))completion;
{
    switch (interface) {
        case PXCameraInterfaceCamera: {
            [PXCameraViewController getImageInViewController:vc completion:^(UIImage * i, PXCameraImageSource s, void (^whenDone)()) {
                if (completion) {
                    completion(i, s);
                }
                if (whenDone) {
                    whenDone();
                }
            }];
            break;
        }
            
        case PXCameraInterfaceLibrary:
        default:  {
            [[PXImagePickerHelper sharedHelper] setCompletion:completion];
            [vc presentViewController:[[PXImagePickerHelper sharedHelper] imagePickerController] animated:TRUE completion:nil];
            break;
        }
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    [[PXImagePickerHelper sharedHelper] setTintColor:_tintColor];
}

- (void)setBarTintColor:(UIColor *)barTintColor
{
    _barTintColor = barTintColor;
    [[PXImagePickerHelper sharedHelper] setBarTintColor:_barTintColor];
}

- (void)setShutterDelayText:(NSString *)shutterDelayText
{
    _shutterDelayText = shutterDelayText;
    [[PXCameraViewController sharedCamera] setShutterDelayText:_shutterDelayText];
}

@end
