//
//  PXCameraViewController.m
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

#import "PXCameraViewController.h"

#import "PXCameraView.h"
#import "PXImagePickerHelper.h"
#import "PXCameraCaptureManager.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface PXCameraViewController () <PXCameraCaptureManagerDelegate>

@property (nonatomic) BOOL presented;

@end

@implementation PXCameraViewController 
{
    // Camera menu
    UILongPressGestureRecognizer * _takePhotoLongPress;
    NSTimer * _delayedPictureTimer;
    CGFloat _remainingDelay;
    
    UIImage * _capturedImage;
        
    AVCaptureVideoOrientation _orientation;
    
    void (^_completion)(UIImage*, PXCameraImageSource, void (^completion)());
    UIViewController * _vc;
    
    PXCameraImageSource _imageSource;
    
    BOOL _presentedModally;
}

+ (PXCameraViewController*)sharedCamera
{
    static PXCameraViewController* _sharedCamera = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedCamera = [[PXCameraViewController alloc] init_internal];
    });
    
    return _sharedCamera;
}

+ (void)getImageInViewController:(UIViewController*)vc completion:(void(^)(UIImage*, PXCameraImageSource, void (^completion)()))completion
{
    [[PXCameraViewController sharedCamera] setVc:vc];
    [[PXCameraViewController sharedCamera] setPresented:TRUE];
    [[PXCameraViewController sharedCamera] setCompletion:completion];
    [vc presentViewController:[PXCameraViewController sharedCamera] animated:TRUE completion:nil];
}

- (void)setCompletion:(void (^)(UIImage*, PXCameraImageSource, void (^completion)()))completion
{
    _completion = completion;
}

- (void)setVc:(UIViewController*)vc
{
    _vc = vc;
}

- (instancetype)init_internal
{
    self = [super init];
    if (self) {
        // Custom initialization
        _shutterDelayText = @"shutter delay";
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)loadView
{
    [self setView:[[PXCameraView alloc] init]];
}

- (PXCameraView*)contentView
{
    return (PXCameraView*)[self view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameChanged:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameWillChange:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    
    _takePhotoLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(takeDelayedPhoto:)];
    [[[self contentView] takePhoto] addGestureRecognizer:_takePhotoLongPress];
    
    [[[self contentView] spanPicker] setTitle:_shutterDelayText];
    
    [[[self contentView] spanPicker] setContinuous:TRUE];
    [[[self contentView] spanPicker] addTarget:self action:@selector(delayChanged:) forControlEvents:UIControlEventValueChanged];
    
    [[[self contentView] flashButton] addTarget:self action:@selector(changedFlashMode:) forControlEvents:UIControlEventValueChanged];
    [[[self contentView] switchCamera] addTarget:self action:@selector(switchCameraPressed) forControlEvents:UIControlEventTouchUpInside];
    [[[self contentView] photoLibrary] addTarget:self action:@selector(photoLibraryButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [[[self contentView] takePhoto] addTarget:self action:@selector(takePhotoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [[[self contentView] backButton] addTarget:self action:@selector(backPressed) forControlEvents:UIControlEventTouchUpInside];

    [self changeFlashModeOrHideFlash:PXFlashTypeAuto];
    
    [self setOnRotationBlock:^(UIInterfaceOrientation orientation) {
        [[PXCameraCaptureManager captureManager] setCameraPreviewOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    }];
}

- (void)setShutterDelayText:(NSString *)shutterDelayText
{
    _shutterDelayText = shutterDelayText;
    [[[self contentView] spanPicker] setTitle:_shutterDelayText];
}

- (BOOL)prefersStatusBarHidden
{
    return TRUE;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self contentView] setOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_delayedPictureTimer invalidate];
    _delayedPictureTimer = nil;
    [[[self contentView] takePhoto] setCountDown:@""];
    _remainingDelay = 0.0f;
    
    [[self contentView] ensureValidCameraView];
    [[PXCameraCaptureManager captureManager] start];
    [self changeFlashModeOrHideFlash:PXFlashTypeAuto];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[PXCameraCaptureManager captureManager] stop];
}

- (void)statusBarFrameWillChange:(NSNotification*)notification {
    NSValue* rectValue = [[notification userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    CGRect newFrame;
    [rectValue getValue:&newFrame];
    // Move your view here ...
    [[self contentView] setNeedsLayout];
}

- (void)statusBarFrameChanged:(NSNotification*)notification {
    NSValue* rectValue = [[notification userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    CGRect oldFrame;
    [rectValue getValue:&oldFrame];
    // ... or here, whichever makes the most sense for your app.
    [[self contentView] setNeedsLayout];
}

- (void)backPressed
{
    __weak typeof(self) weakSelf = self;
    void (^whenDone)(void) = ^ {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [SVProgressHUD dismiss];
        [[strongSelf contentView] reset];
    };
    
    if (_presented) {
        [self runCompletion:nil];
        [[self presentingViewController] dismissViewControllerAnimated:TRUE completion:whenDone];
        _presented = FALSE; // reset state
    } else {
        if (_completion) {
            _completion(nil, PXCameraImageSourceNone, ^ {
                whenDone();
            });
        }
    }
}

- (void)switchCameraPressed
{
    [[[self contentView] switchCamera] setUserInteractionEnabled:FALSE];
    double delayInSeconds = 0.5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [[[self contentView] switchCamera] setUserInteractionEnabled:TRUE];
    });
    [[PXCameraCaptureManager captureManager] toggleCamera];
    [self changeFlashModeOrHideFlash:PXFlashTypeAuto];
}

- (void)changeFlashModeOrHideFlash:(PXFlashType)flashType
{
    if ([[PXCameraCaptureManager captureManager] isFlashSupported]) {
        [[self contentView] setFlashType:flashType];
        [[PXCameraCaptureManager captureManager] setFlashType:flashType];
    } else {
        [[self contentView] setFlashType:PXFlashTypeUnavailable];
    }
}

- (void)changedFlashMode:(PXFlashControl*)sender
{
    [self changeFlashModeOrHideFlash:[sender value]];
}

- (void)delayChanged:(PXSpanPicker*)sender
{
    // set the delay timer
    [[[self contentView] takePhoto] setCountDown:[NSString stringWithFormat:@"%d", (int)[sender value]]];
    _remainingDelay = [sender value];
}

- (void)timerTick:(NSTimer*)sender
{
    if (_remainingDelay <= 0.0f) {
        [_delayedPictureTimer invalidate];
        _delayedPictureTimer = nil;
        _remainingDelay = 0;
        [self takePhotoButtonPressed];
    } else {
        _remainingDelay -= 0.1f;
        [[[self contentView] takePhoto] setCountDown:[NSString stringWithFormat:@"%d", ((int)_remainingDelay) + 1]];
    }
}

- (void)takeDelayedPhoto:(UILongPressGestureRecognizer*)sender
{
    if ([sender state] != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if (_delayedPictureTimer) {
        // cancel the photo
        [_delayedPictureTimer invalidate];
        _delayedPictureTimer = nil;
        [[[self contentView] takePhoto] setCountDown:@""];
        _remainingDelay = 0.0f;
    } else if ([[[self contentView] spanPicker] hidden]) {
        // show the span picker and set the countdown
        [[[self contentView] spanPicker] showAnimated:TRUE];
        [[[self contentView] takePhoto] setCountDown:[NSString stringWithFormat:@"%d", (int)[[[self contentView] spanPicker] value]]];
        _remainingDelay = [[[self contentView] spanPicker] value];
    } else {
        // hide the span picker
        [[[self contentView] spanPicker] hideAnimated:TRUE];
        [[[self contentView] takePhoto] setCountDown:@""];
        _remainingDelay = 0.0f;
    }
}

- (void)takePhotoButtonPressed
{    
    [[[self contentView] spanPicker] hideAnimated:TRUE];
    
    if (_delayedPictureTimer) {
        return;
    }
    
    if (_remainingDelay > 0) {
        _delayedPictureTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTick:) userInfo:nil repeats:TRUE];
        return;
    }
    
    // take picture
    [[self contentView] setState:PXCameraViewTypePreview];
    [SVProgressHUD showWithStatus:@"Preparing Image"];
    
    __weak typeof(self) weakSelf = self;
    [[PXCameraCaptureManager captureManager] captureStillImageWithBlock:^(UIImage * image) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf->_capturedImage = image;
        
        strongSelf->_imageSource = PXCameraImageSourceCamera;
        
        [[[strongSelf contentView] imagePreview] setImage:strongSelf->_capturedImage];
        
        void (^whenDone)(void) = ^ {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [SVProgressHUD dismiss];
            [[strongSelf contentView] reset];
        };
        
        if (strongSelf->_presented) {
            [strongSelf runCompletion:nil];
            [[strongSelf presentingViewController] dismissViewControllerAnimated:TRUE completion:whenDone];
            strongSelf->_presented = FALSE; // reset state
        } else {
            [strongSelf runCompletion:^{
                whenDone();
            }];
        }
    }];
}

- (void)photoLibraryButtonPressed
{
    [[PXCameraCaptureManager captureManager] stop];
    __weak typeof(self) weakSelf = self;
    [PXImagePickerHelper getImageInViewController:self completion:^(UIImage * image, PXCameraImageSource source) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (image) {
            strongSelf->_capturedImage = image;
            strongSelf->_imageSource = source;
            [[[strongSelf contentView] imagePreview] setImage:image];
            
            [[strongSelf contentView] setState:PXCameraViewTypePreview];
            [SVProgressHUD showWithStatus:@"Preparing Image"];
            
            void (^whenDone)(void) = ^ {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [SVProgressHUD dismiss];
                [[strongSelf contentView] reset];
            };
            
            if (strongSelf->_presented) {
                [strongSelf runCompletion:nil];
                [[strongSelf presentingViewController] dismissViewControllerAnimated:TRUE completion:whenDone];
                strongSelf->_presented = FALSE; // reset state
            } else {
                [strongSelf runCompletion:^{
                    whenDone();
                }];
            }
        } else {
            [[PXCameraCaptureManager captureManager] start];
        }
    }];
}

- (void)runCompletion:(void (^)())whenDone
{   
    if (_completion) {
        _completion(_capturedImage, _imageSource, whenDone);
    }
}

- (void)captureManager:(PXCameraCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
