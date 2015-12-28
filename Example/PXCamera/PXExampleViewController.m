//
//  PXViewController.m
//  PXCamera
//
//  Created by Daniel Blakemore on 05/01/2015.
//  Copyright (c) 2014 Daniel Blakemore. All rights reserved.
//

#import "PXExampleViewController.h"

#import <PXCamera/PXCamera.h>
#import <PXCamera/PXCameraViewController.h>

#import "PXCustomCameraViewController.h"

@interface PXExampleViewController ()

@end

@implementation PXExampleViewController
{
    UIButton * _cameraButton;
    UIButton * _cameraButton2;
    UIButton * _libraryButton;
    UIButton * _customCameraButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setTitle:@"PXCamera"];
    
    // make some buttons
    _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cameraButton setTitle:@"Present Camera" forState:UIControlStateNormal];
    [_cameraButton setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [[self view] addSubview:_cameraButton];
    [_cameraButton addTarget:self action:@selector(cameraPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _cameraButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cameraButton2 setTitle:@"Navigate to Camera" forState:UIControlStateNormal];
    [_cameraButton2 setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [[self view] addSubview:_cameraButton2];
    [_cameraButton2 addTarget:self action:@selector(cameraPressed2) forControlEvents:UIControlEventTouchUpInside];
    
    _libraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_libraryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_libraryButton setTitle:@"Present Library" forState:UIControlStateNormal];
    [_libraryButton setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [[self view] addSubview:_libraryButton];
    [_libraryButton addTarget:self action:@selector(libraryPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _customCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_customCameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_customCameraButton setTitle:@"Navigate to Custom Camera" forState:UIControlStateNormal];
    [_customCameraButton setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [[self view] addSubview:_customCameraButton];
    [_customCameraButton addTarget:self action:@selector(customCameraPressed) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary * views = NSDictionaryOfVariableBindings(_cameraButton, _cameraButton2, _libraryButton, _customCameraButton);
    NSDictionary * metrics = @{@"bw" : @(250), @"bh" : @(50), @"sp" : @(10)};
    
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cameraButton(bw)]" options:0 metrics:metrics views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cameraButton2(bw)]" options:0 metrics:metrics views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_libraryButton(bw)]" options:0 metrics:metrics views:views]];
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_customCameraButton(bw)]" options:0 metrics:metrics views:views]];
    [[self view] addConstraint:[NSLayoutConstraint constraintWithItem:_cameraButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[self view] attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [[self view] addConstraint:[NSLayoutConstraint constraintWithItem:_cameraButton2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[self view] attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [[self view] addConstraint:[NSLayoutConstraint constraintWithItem:_libraryButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[self view] attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [[self view] addConstraint:[NSLayoutConstraint constraintWithItem:_customCameraButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[self view] attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    
    [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_cameraButton(bh)]-sp-[_cameraButton2(bh)]-sp-[_libraryButton(bh)]-sp-[_customCameraButton(bh)]" options:0 metrics:metrics views:views]];
    [[self view] addConstraint:[NSLayoutConstraint constraintWithItem:_libraryButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:[self view] attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
}

- (void)cameraPressed
{
    [[PXCamera camera] getImageInViewController:self interface:PXCameraInterfaceCamera completion:^(UIImage * image, PXCameraImageSource source) {
        NSLog(@"C: %@", image);
    }];
}

- (void)cameraPressed2
{
    PXCameraViewController * cvc = [PXCameraViewController sharedCamera];
    [cvc setCompletion:^(UIImage * image, PXCameraImageSource source, void (^whenDone)()) {
        if (source != PXCameraImageSourceNone) {
            // demonstrate post-camera view controller transition
            UIViewController * postCameraVC = [[UIViewController alloc] init];
            [postCameraVC setTitle:@"Post-Camera Screen"];
            [[postCameraVC view] setBackgroundColor:[UIColor grayColor]];
            [[self navigationController] pushViewController:postCameraVC animated:TRUE];
            
            // reset navigation stack without the camera in it (just because)
            NSMutableArray * newViewControllers = [NSMutableArray array];
            [[[self navigationController] viewControllers] enumerateObjectsUsingBlock:^(UIViewController * obj, NSUInteger idx, BOOL *stop) {
                if (![obj isKindOfClass:[PXCameraViewController class]]) {
                    [newViewControllers addObject:obj];
                }
            }];
            [[self navigationController] setViewControllers:newViewControllers];
        } else {
            [[self navigationController] popViewControllerAnimated:TRUE];
        }
        
        if (whenDone) {
            whenDone();
        }
        NSLog(@"C: %@", image);
    }];
    [[self navigationController] pushViewController:cvc animated:TRUE];
}

- (void)libraryPressed
{
    [[PXCamera camera] getImageInViewController:self interface:PXCameraInterfaceLibrary completion:^(UIImage * image, PXCameraImageSource source) {
        NSLog(@"L: %@", image);
    }];
}

- (void)customCameraPressed
{
    [[self navigationController] pushViewController:[[PXCustomCameraViewController alloc] init] animated:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
