//
//  PXCustomCameraViewController.m
//  PXCamera
//
//  Created by Daniel Blakemore on 12/23/15.
//  Copyright © 2015 Daniel Blakemore. All rights reserved.
//

#import "PXCustomCameraViewController.h"

#import "PXCustomCameraView.h"

#import <PXCamera/PXCameraCaptureManager.h>

@implementation PXCustomCameraViewController
{
    void (^_completion)(UIImage * image, BOOL pictureTaken);
}

- (instancetype)initWithCompletion:(void(^)(UIImage * image, BOOL pictureTaken))completion
{
    self = [super init];
    if (self) {
        _completion = completion;
    }
    return self;
}

- (void)loadView
{
    [self setView:[[PXCustomCameraView alloc] init]];
}

- (PXCustomCameraView*)contentView
{
    return (id)[self view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [[[self contentView] shutterButton] addTarget:self action:@selector(shutterPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[PXCameraCaptureManager captureManager] start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[PXCameraCaptureManager captureManager] stop];
    [super viewWillDisappear:animated];
    if (_completion) {
        _completion(nil, FALSE); // cheap replacement for back button in camera UI
        _completion = nil;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [[PXCameraCaptureManager captureManager] setCameraPreviewOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
}

- (void)shutterPressed
{
    [[PXCameraCaptureManager captureManager] captureStillImageWithBlock:^(UIImage * image) {
        [[self navigationController] popViewControllerAnimated:TRUE];
        if (_completion) {
            _completion(image, TRUE);
            _completion = nil;
        }
    }];
}

@end
