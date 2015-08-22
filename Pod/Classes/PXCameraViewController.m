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

#import "PXImagePickerHelper.h"
#import "PXCameraCaptureManager.h"

#import <SVProgressHUD/SVProgressHUD.h>

#define PXCameraLastPosition @"PXCameraLastPosition"

@interface PXCameraViewController () <PXCameraCaptureManagerDelegate, UIGestureRecognizerDelegate>

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
    
    PXCameraCaptureManager * _captureManager;
    
    AVCaptureVideoPreviewLayer * _captureVideoPreviewLayer;
    
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
        _sharedCamera = [[PXCameraViewController alloc] init];
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

- (id)init
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
    
    // Add a single tap gesture to focus on the point tapped, then lock focus
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
    [singleTap setDelegate:self];
    [singleTap setNumberOfTapsRequired:1];
    [[[self contentView] cameraView] addGestureRecognizer:singleTap];
    
    // Add a double tap gesture to reset the focus mode to continuous auto focus
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
    [doubleTap setDelegate:self];
    [doubleTap setNumberOfTapsRequired:2];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [[[self contentView] cameraView] addGestureRecognizer:doubleTap];
        
    _captureManager = [[PXCameraCaptureManager alloc] init];
    
    [_captureManager setDelegate:self];
    
    NSNumber* position = [[NSUserDefaults standardUserDefaults] objectForKey:PXCameraLastPosition];
    BOOL setup = FALSE;
    if (position != nil && [position integerValue] != (NSInteger)AVCaptureDevicePositionUnspecified)
    {
        setup = [_captureManager setupSessionWithDevicePosition:(AVCaptureDevicePosition)[position integerValue]];
    }
    else
    {
        setup = [_captureManager setupSession];
    }
    
    if (setup) {
        // Create video preview layer and add it to the UI
        _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[_captureManager session]];
        [_captureVideoPreviewLayer setSpeed:1000]; // magically makes rotation disappear.
        _captureVideoPreviewLayer.connection.videoOrientation = [self interfaceOrientationToVideoOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        UIView *view = [[self contentView] cameraView];
        CALayer *viewLayer = [view layer];
        [viewLayer setMasksToBounds:YES];
        
        CGRect bounds = [[UIScreen mainScreen] bounds];
        [_captureVideoPreviewLayer setFrame:bounds];
        [_captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        
        [viewLayer insertSublayer:_captureVideoPreviewLayer below:[[viewLayer sublayers] lastObject]];
        
        [self setCaptureVideoPreviewLayer:_captureVideoPreviewLayer];
        
        [self changeFlashModeOrHideFlash:PXFlashTypeAuto];
        
        // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[_captureManager session] startRunning];
        });
        
        // Add a single tap gesture to focus on the point tapped, then lock focus
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
        [singleTap setDelegate:self];
        [singleTap setNumberOfTapsRequired:1];
        [view addGestureRecognizer:singleTap];
        
        // Add a double tap gesture to reset the focus mode to continuous auto focus
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
        [doubleTap setDelegate:self];
        [doubleTap setNumberOfTapsRequired:2];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [view addGestureRecognizer:doubleTap];
    }
    
    __weak typeof(self) weakSelf = self;
    [self setOnRotationBlock:^(UIInterfaceOrientation orientation) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_captureVideoPreviewLayer.connection.videoOrientation = [strongSelf interfaceOrientationToVideoOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    }];
}

- (void)setShutterDelayText:(NSString *)shutterDelayText
{
    _shutterDelayText = shutterDelayText;
    [[[self contentView] spanPicker] setTitle:_shutterDelayText];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self contentView] setOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (AVCaptureVideoOrientation)interfaceOrientationToVideoOrientation:(UIInterfaceOrientation)inOrientation
{
    switch (inOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
            
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            
        default:
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return TRUE;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [_captureVideoPreviewLayer setFrame:[[_captureVideoPreviewLayer superlayer] bounds]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_delayedPictureTimer invalidate];
    _delayedPictureTimer = nil;
    [[[self contentView] takePhoto] setCountDown:@""];
    _remainingDelay = 0.0f;
    
    [[_captureManager session] startRunning];
    [self changeFlashModeOrHideFlash:PXFlashTypeAuto];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[_captureManager session] stopRunning];
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
    if (_completion) {
        _completion(nil, PXCameraImageSourceNone, ^ {
            
        });
    }
    [_vc dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)switchCameraPressed
{
    [[[self contentView] switchCamera] setUserInteractionEnabled:FALSE];
    double delayInSeconds = 0.5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [[[self contentView] switchCamera] setUserInteractionEnabled:TRUE];
        
        NSInteger position = (NSInteger)[_captureManager position];
        [[NSUserDefaults standardUserDefaults] setObject:@(position) forKey:PXCameraLastPosition];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
    [_captureManager toggleCamera];
    [self changeFlashModeOrHideFlash:PXFlashTypeAuto];
}

- (void) changeFlashModeOrHideFlash:(PXFlashType)flashType
{
    if ([_captureManager isFlashTypeSupported]) {
        [[self contentView] setFlashType:flashType];
        [_captureManager setFlashType:flashType];
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
//    [[self contentView] flashOn];
    
    [[self contentView] setState:PXCameraViewTypePreview];
    [SVProgressHUD showWithStatus:@"Preparing Image"];
    
    __weak typeof(self) weakSelf = self;
    [_captureManager captureStillImageWithBlock:^(UIImage * image) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf->_captureVideoPreviewLayer.connection.enabled = FALSE;
        strongSelf->_capturedImage = image;
        
        strongSelf->_imageSource = PXCameraImageSourceCamera;
        
        [[[strongSelf contentView] imagePreview] setImage:strongSelf->_capturedImage];
        
//        [[self contentView] flashOff];
        
        void (^whenDone)(void) = ^ {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [SVProgressHUD dismiss];
            [[strongSelf contentView] reset];
            strongSelf->_captureVideoPreviewLayer.connection.enabled = TRUE;
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
    [[_captureManager session] stopRunning];
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
            [[strongSelf->_captureManager session] startRunning];
        }
    }];
}

- (void)runCompletion:(void (^)())whenDone
{   
    if (_completion) {
        _completion(_capturedImage, _imageSource, whenDone);
    }
}

// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[[self contentView] cameraView] frame].size;
    
    if ([[_captureManager stillImageConnection] isVideoMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }
    
    if ( [[_captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
        // Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[_captureManager imageInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[_captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        // If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            // Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        // If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            // Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[_captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    // Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[_captureManager imageInput] device] isFocusPointOfInterestSupported]) {
        CGPoint tapPoint = [gestureRecognizer locationInView:[[self contentView] cameraView]];
        CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
        [_captureManager autoFocusAtPoint:convertedFocusPoint];
    }
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[_captureManager imageInput] device] isFocusPointOfInterestSupported])
        [_captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
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
