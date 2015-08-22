//
//  PXViewController.m
//  PXCamera
//
//  Created by Daniel Blakemore on 05/01/2015.
//  Copyright (c) 2014 Daniel Blakemore. All rights reserved.
//

#import "PXExampleViewController.h"

#import <PXCamera/PXCamera.h>

@interface PXExampleViewController ()

@end

@implementation PXExampleViewController
{
    UIButton * _cameraButton;
    UIButton * _libraryButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setTitle:@"PXCamera"];
    
    // make some buttons
    _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cameraButton setTitle:@"Use Camera" forState:UIControlStateNormal];
    [_cameraButton setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [[self view] addSubview:_cameraButton];
    [_cameraButton addTarget:self action:@selector(cameraPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _libraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_libraryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_libraryButton setTitle:@"Use Library" forState:UIControlStateNormal];
    [_libraryButton setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [[self view] addSubview:_libraryButton];
    [_libraryButton addTarget:self action:@selector(libraryPressed) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary * views = NSDictionaryOfVariableBindings(_cameraButton, _libraryButton);
    NSDictionary * metrics = @{@"bw" : @(120), @"bh" : @(50), @"sp" : @(10)};
    
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cameraButton(bw)]" options:0 metrics:metrics views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_libraryButton(bw)]" options:0 metrics:metrics views:views]];
    [[self view] addConstraint:[NSLayoutConstraint constraintWithItem:_cameraButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[self view] attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [[self view] addConstraint:[NSLayoutConstraint constraintWithItem:_libraryButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[self view] attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_cameraButton(bh)]-sp-[_libraryButton(bh)]" options:0 metrics:metrics views:views]];
    [[self view] addConstraint:[NSLayoutConstraint constraintWithItem:_libraryButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:[self view] attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
}

- (void)cameraPressed
{
    [[PXCamera camera] getImageInViewController:self interface:PXCameraInterfaceCamera completion:^(UIImage * image, PXCameraImageSource source) {
        NSLog(@"C: %@", image);
    }];
}

- (void)libraryPressed
{
    [[PXCamera camera] getImageInViewController:self interface:PXCameraInterfaceLibrary completion:^(UIImage * image, PXCameraImageSource source) {
        NSLog(@"L: %@", image);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
