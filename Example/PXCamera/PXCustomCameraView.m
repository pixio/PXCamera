//
//  PXCustomCameraView.m
//  PXCamera
//
//  Created by Daniel Blakemore on 12/23/15.
//  Copyright © 2015 Daniel Blakemore. All rights reserved.
//

#import "PXCustomCameraView.h"

#import <PXCamera/PXCameraCaptureManager.h>

@implementation PXCustomCameraView
{
    UIView * _cameraView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor darkGrayColor]];
        
        _cameraView = [[PXCameraCaptureManager captureManager] cameraPreviewView];
        [_cameraView setBackgroundColor:[UIColor blackColor]];
        [_cameraView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_cameraView];
        
        _shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shutterButton setTitle:@"Take Photo" forState:UIControlStateNormal];
        [_shutterButton setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_shutterButton];
        
        NSDictionary* views = NSDictionaryOfVariableBindings(_cameraView, _shutterButton);
        NSDictionary* metrics = @{@"bw" : @100, @"bh" : @40, @"sp" : @20};
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cameraView]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_shutterButton(bw)]" options:0 metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_shutterButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cameraView]-sp-[_shutterButton(bh)]-sp-|" options:0 metrics:metrics views:views]];
    }
    return self;
}

@end
