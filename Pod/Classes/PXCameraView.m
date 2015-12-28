//
//  PXCameraView.m
//
//  Created by Daniel Blakemore on 9/11/13.
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

#import "PXCameraView.h"

#import "PXCameraDisplayView.h"

#define ButtonImageEdgeInsets (UIEdgeInsetsMake(8, 8, 8, 8))

@implementation PXCameraView
{
    UIView * _flashView;
    UIView * _dividerLineView;
    BOOL _spanPickerHidden;
    
    UIView * _plSpacer1;
    UIView * _plSpacer2;
    UIView * _backSpacer1;
    UIView * _backSpacer2;
    
    UIView * _topControlsBox;
    
    PXCameraDisplayView * _cameraView;
}

@synthesize cameraView = _cameraView;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 200, 200)];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor blackColor]];
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *url = [bundle URLForResource:@"PXCamera" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        
        // background
        _cameraView = [[PXCameraDisplayView alloc] init];
        [_cameraView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_cameraView];
        
        // controls
        _photoLibrary = [[PXLibraryButton alloc] init];
        [[_photoLibrary layer] setCornerRadius:3];
        [_photoLibrary setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_photoLibrary];
        [self applySmallShadow:_photoLibrary];
        [self addViewToAnimate:_photoLibrary];
        
        _takePhoto = [[PXCameraButton alloc] init];
        [_takePhoto setBackgroundColor:[UIColor clearColor]];
        [_takePhoto setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_takePhoto];
        [self applySmallShadow:_takePhoto];
        [self addViewToAnimate:_takePhoto];
        
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"close" ofType:@"png"]] forState:UIControlStateNormal];
        [_backButton setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_backButton];
        [self applySmallShadow:_backButton];
        [self addViewToAnimate:_backButton];
        
        _dividerLineView = [[UIView alloc] init];
        [_dividerLineView setBackgroundColor:[UIColor whiteColor]];
        [_dividerLineView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_dividerLineView];
        [self applySmallShadow:_dividerLineView];
        
        _topControlsBox = [[UIView alloc] init];
        [_topControlsBox setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_topControlsBox];
        
        _gridButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_gridButton setImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"grid" ofType:@"png"]] forState:UIControlStateNormal];
        [[_gridButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
        [_gridButton setContentEdgeInsets:ButtonImageEdgeInsets];
        [_gridButton setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [_topControlsBox addSubview:_gridButton];
        [self applySmallShadow:_gridButton];
        [self addViewToAnimate:_gridButton];
        [_gridButton addTarget:self action:@selector(gridPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _switchCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchCamera setImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"switch-camera" ofType:@"png"]] forState:UIControlStateNormal];
        [[_switchCamera imageView] setContentMode:UIViewContentModeScaleAspectFit];
        [_switchCamera setContentEdgeInsets:ButtonImageEdgeInsets];
        [_switchCamera setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [_topControlsBox addSubview:_switchCamera];
        [self applySmallShadow:_switchCamera];
        [self addViewToAnimate:_switchCamera];
        
        _flashButton = [[PXFlashControl alloc] init];
        [_flashButton addTarget:self action:@selector(flashControlChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_flashButton setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [_topControlsBox addSubview:_flashButton]; // add last so it's on top when it's expanded.
        [self applySmallShadow:_flashButton];
        [self addViewsToAnimate:[_flashButton individualViews]];
        
        _spanPicker = [[PXSpanPicker alloc] initWithFrame:CGRectZero];
        [_spanPicker setContentBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.5f]];
        [_spanPicker setTitle:@"shutter delay"];
        [_spanPicker setClipsToBounds:TRUE];
        [_spanPicker setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_spanPicker];
        [self addViewsToAnimate:[_spanPicker individualViews]];
        
        // overlay views
        _imagePreview = [[UIImageView alloc] init];
        [_imagePreview setContentMode:UIViewContentModeScaleAspectFit];
        [_imagePreview setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_imagePreview];
        
        _flashView = [[UIView alloc] init];
        [_flashView setBackgroundColor:[UIColor whiteColor]];
        [_flashView setAlpha:0.0f];
        [_flashView setUserInteractionEnabled:FALSE];
        [_flashView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_flashView];
        
        _plSpacer1 = [self makeSpacerView];
        _plSpacer2 = [self makeSpacerView];
        _backSpacer1 = [self makeSpacerView];
        _backSpacer2 = [self makeSpacerView];
        
        [self setState:PXCameraViewTypeCamera];
        [self flashOff];
        
        // initial layout
        [super manuallyStartLayoutPass];
    }
    return self;
}

- (NSArray *)calculateBaseConstraintsBeforeLayoutPass
{
    // Change layout
    NSMutableArray * constraints = [NSMutableArray array];
    NSDictionary * views = NSDictionaryOfVariableBindings(_flashButton, _gridButton, _switchCamera);
    NSDictionary * metrics = @{@"sdsp" : @20, @"bw" : @44, @"bh" : @44};
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_gridButton(bh)]" options:0 metrics:metrics views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_flashButton]|" options:0 metrics:metrics views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_switchCamera(bw)]" options:0 metrics:metrics views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_gridButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_topControlsBox attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_switchCamera attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_topControlsBox attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sdsp-[_gridButton(bw)]" options:0 metrics:metrics views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_switchCamera(bw)]-sdsp-|" options:0 metrics:metrics views:views]];
    
    switch ([_flashButton fcState]) {
        case PXFlashControlStateCollapsed: {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_flashButton(bw)]" options:0 metrics:metrics views:views]];
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_flashButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_topControlsBox attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
            
            // enable other controls
            [_gridButton setUserInteractionEnabled:TRUE];
            [_gridButton setAlpha:1.0f];
            [_switchCamera setUserInteractionEnabled:TRUE];
            [_switchCamera setAlpha:1.0f];
            break;
        }
            
        case PXFlashControlStateExpanded:
        default: {
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sdsp-[_flashButton]-sdsp-|" options:0 metrics:metrics views:views]];
            
            // disable other controls
            [_gridButton setUserInteractionEnabled:FALSE];
            [_gridButton setAlpha:0.0f];
            [_switchCamera setUserInteractionEnabled:FALSE];
            [_switchCamera setAlpha:0.0f];
            break;
        }
    }
    
    views = NSDictionaryOfVariableBindings(_cameraView, _imagePreview, _flashView, _photoLibrary, _takePhoto, _backButton, _plSpacer1, _plSpacer2, _backSpacer1, _backSpacer2, _dividerLineView, _topControlsBox, _spanPicker);
    metrics = @{@"pbsp" : @12, @"csp" : @4, @"tpbs" : @75, @"pls" : @45, @"lh" : @1, @"lsp" : @25, @"ch" : @40, @"sp" : @8};
    
    // controls
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_plSpacer1(_plSpacer2)][_photoLibrary(pls)][_plSpacer2][_takePhoto(tpbs)][_backSpacer1(_backSpacer2)][_backButton(pls)][_backSpacer2]|" options:0 metrics:metrics views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_takePhoto attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_photoLibrary(pls)]" options:0 metrics:metrics views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_backButton(pls)]" options:0 metrics:metrics views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_photoLibrary attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_takePhoto attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_backButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_takePhoto attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cameraView][_topControlsBox(ch)][_dividerLineView(lh)]-pbsp-[_takePhoto(tpbs)]-pbsp-|" options:0 metrics:metrics views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cameraView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-lsp-[_dividerLineView]-lsp-|" options:0 metrics:metrics views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-lsp-[_topControlsBox]-lsp-|" options:0 metrics:metrics views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_spanPicker(==80)][_topControlsBox]" options:0 metrics:metrics views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_spanPicker]|" options:0 metrics:metrics views:views]];
    
    // overlays and background
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_imagePreview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_cameraView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_imagePreview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_cameraView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_imagePreview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_cameraView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_imagePreview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_cameraView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cameraView]|" options:0 metrics:metrics views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_flashView]|" options:0 metrics:metrics views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_flashView]|" options:0 metrics:metrics views:views]];
    
    return constraints;
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [_flashButton setOrientation:PXFlashControlOrientationLandscape];
        [_spanPicker setOrientation:PXSpanPickerOrientationLandscape];
    } else {
        [_flashButton setOrientation:PXFlashControlOrientationPortrait];
        [_spanPicker setOrientation:PXSpanPickerOrientationPortrait];
    }
    
    // call last
    [super setOrientation:orientation];
}

- (void)applySmallShadow:(UIView*)view
{
    [[view layer] setShadowOffset:CGSizeMake(0.0f, 0.375f)];
    [[view layer] setShadowRadius:0.75f];
    [[view layer] setShadowOpacity:0.6f];
}

- (void)flashControlChanged:(PXFlashControl*)flashControl
{
    [UIView animateWithDuration:0.15f animations:^{
        [self manuallyStartLayoutPass];
        
        switch ([flashControl fcState]) {
            case PXFlashControlStateCollapsed: {
                [_flashButton collapse];
                break;
            }
                
            case PXFlashControlStateExpanded:
            default: {
                [_flashButton expand];
                break;
            }
        }
        
        CGFloat otherControlAlpha = 1.0f * !!([flashControl fcState] == PXFlashControlStateCollapsed);
        [_gridButton setAlpha:otherControlAlpha];
    }];
}

- (UIView*)makeSpacerView
{
    UIView * spacerView = [[UIView alloc] init];
    [spacerView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [self addSubview:spacerView];
    return spacerView;
}


- (void)gridPressed
{
    [_cameraView setGridHidden:![_cameraView gridHidden]];
}

- (void)setFlashType:(PXFlashType)flashType
{
    [_flashButton setValue:flashType];
}

- (void)flash
{    
    [UIView animateWithDuration:0.1f animations:^{
        [_flashView setAlpha:1.0f];
        [_flashView setUserInteractionEnabled:TRUE];
    } completion:^(BOOL finished) {
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_flashView setAlpha:0.0f];
            [_flashView setUserInteractionEnabled:FALSE];
        });
    }];
}

- (void)setState:(PXCameraViewType)state
{
    _state = state;
    
    switch (_state) {
        case PXCameraViewTypeCamera:
            [_imagePreview setAlpha:0.0f];
            [_imagePreview setUserInteractionEnabled:FALSE];
            break;
            
        case PXCameraViewTypePreview:
            [_imagePreview setAlpha:1.0f];
            [_imagePreview setUserInteractionEnabled:TRUE];
            break;
            
        default:
            break;
    }
}

- (void)reset
{
    [self setState:PXCameraViewTypeCamera];
    [_flashView setAlpha:0.0f];
    [_flashView setUserInteractionEnabled:FALSE];
    [_imagePreview setImage:nil];
}

- (void)flashOn
{
    [UIView animateWithDuration:0.1f animations:^{
        [_flashView setAlpha:1.0f];
        [_flashView setUserInteractionEnabled:TRUE];
    }];
}

- (void)flashOff
{
    [UIView animateWithDuration:0.1f animations:^{
        [_flashView setAlpha:0.0f];
        [_flashView setUserInteractionEnabled:FALSE];
    }];
}

- (void)ensureValidCameraView
{
    // make sure that the camera preview view from the capture manager is actually a subview of our camera view
    // I don't love this solution but it's easy and I'm feeling lazy today.  
    // It would probably be cleaner to just make a new PXCameraView every time the camera is loaded.  It's all internal anyway.
    [_cameraView ensureCameraPreviewViewAttached];
}

@end
