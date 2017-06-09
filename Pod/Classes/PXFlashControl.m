//
//  PXFlashButton.m
//
//  Created by Daniel Blakemore on 10/11/13.
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

#import "PXFlashControl.h"

@implementation PXFlashControl
{
    UIImageView * _autoView;
    UIImageView * _onView;
    UIImageView * _offView;
    UIImageView * _unavailableView;
    PXFlashType _value;
    
    BOOL _expanded;
    BOOL _receivingTouches;
    
    PXFlashControlOrientation _orientation;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _receivingTouches = TRUE;
        
        [self setMultipleTouchEnabled:FALSE];
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *url = [bundle URLForResource:@"PXCamera" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
                
        _autoView = [[UIImageView alloc] init];
        [_autoView setContentMode:UIViewContentModeCenter];
        [_autoView setBackgroundColor:[UIColor clearColor]];
        [_autoView setImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"flash-auto" ofType:@"png"]]];
        [_autoView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_autoView];
        
        _onView = [[UIImageView alloc] init];
        [_onView setContentMode:UIViewContentModeCenter];
        [_onView setBackgroundColor:[UIColor clearColor]];
        [_onView setImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"flash-on" ofType:@"png"]]];
        [_onView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_onView];
        
        _offView = [[UIImageView alloc] init];
        [_offView setContentMode:UIViewContentModeCenter];
        [_offView setBackgroundColor:[UIColor clearColor]];
        [_offView setImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"flash-off" ofType:@"png"]]];
        [_offView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_offView];
        
        _unavailableView = [[UIImageView alloc] init];
        [_unavailableView setAlpha:0.0f];
        [_unavailableView setContentMode:UIViewContentModeCenter];
        [_unavailableView setBackgroundColor:[UIColor clearColor]];
        [_unavailableView setImage:[UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"flash-unavailable" ofType:@"png"]]];
        [_unavailableView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_unavailableView];
        
        _value = PXFlashTypeAuto;
    }
    return self;
}

- (void)setOrientation:(PXFlashControlOrientation)orientation
{
    _orientation = orientation;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (NSArray*)individualViews
{
    return @[_autoView, _offView, _onView, _unavailableView];
}

- (void)updateConstraints
{
    [self removeConstraints:[self constraints]];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(_autoView, _onView, _offView, _unavailableView);
    NSDictionary* metrics = @{@"bw" : @40};
    
    if (_orientation == PXFlashControlOrientationPortrait) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_autoView]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_onView]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_offView]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_unavailableView]|" options:0 metrics:metrics views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_unavailableView(bw)]" options:0 metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_unavailableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_onView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_autoView(bw)]" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_onView(bw)]" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_offView(bw)]|" options:0 metrics:metrics views:views]];
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_autoView]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_onView]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_offView]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_unavailableView]|" options:0 metrics:metrics views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_unavailableView(bw)]" options:0 metrics:metrics views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_unavailableView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_onView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_autoView(bw)]" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_onView(bw)]" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_offView(bw)]|" options:0 metrics:metrics views:views]];
    }
    
    [super updateConstraints];
}

- (void)setValue:(PXFlashType)value
{
    _value = value;
    
    // make the correct one visible and ignore touches if set to unavailable
    if (_value == PXFlashTypeUnavailable) {
        _receivingTouches = FALSE;
    } else {
        _receivingTouches = TRUE;
    }
    
    [self collapse];
}

- (void)collapse
{
    switch (_value) {
        case PXFlashTypeAuto: {
            [_autoView setAlpha:1.0f];
            [_onView setAlpha:0.0f];
            [_offView setAlpha:0.0f];
            [_unavailableView setAlpha:0.0f];
            [self bringSubviewToFront:_autoView];
            break;
        }
            
        case PXFlashTypeOn:{
            [_autoView setAlpha:0.0f];
            [_onView setAlpha:1.0f];
            [_offView setAlpha:0.0f];
            [_unavailableView setAlpha:0.0f];
            [self bringSubviewToFront:_onView];
            break;
        }
            
        case PXFlashTypeOff: {
            [_autoView setAlpha:0.0f];
            [_onView setAlpha:0.0f];
            [_offView setAlpha:1.0f];
            [_unavailableView setAlpha:0.0f];
            [self bringSubviewToFront:_offView];
            break;
        }
            
        case PXFlashTypeUnavailable:
        default: {
            [_autoView setAlpha:0.0f];
            [_onView setAlpha:0.0f];
            [_offView setAlpha:0.0f];
            [_unavailableView setAlpha:1.0f];
            [self bringSubviewToFront:_unavailableView];
            break;
        }
    }
}

- (void)expand
{
    [_autoView setAlpha:1.0f];
    [_onView setAlpha:1.0f];
    [_offView setAlpha:1.0f];
}

- (PXFlashType)value
{
    return _value;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_receivingTouches) {
        return;
    }
    
    if (_expanded) {
        _fcState = PXFlashControlStateCollapsed;
    } else {
        _fcState = PXFlashControlStateExpanded;
    }
    
    if (_expanded) {
        // pick flash mode
        NSInteger newValue = [self resolveBinFromPrimaryAxis:[[touches anyObject] locationInView:self]];
        
        // deal with state and events
        [self setValue:newValue];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        _expanded = FALSE;
        
    } else {
        _expanded = TRUE;
    }
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (NSInteger)resolveBinFromPrimaryAxis:(CGPoint)point
{
    CGFloat axisCoordinate;
    CGFloat totalAxisLength;
    
    if (_orientation == PXFlashControlOrientationPortrait) {
        axisCoordinate = point.x;
        totalAxisLength = [self frame].size.width;
    } else {
        axisCoordinate = point.y;
        totalAxisLength = [self frame].size.height;
    }
    CGFloat binWidth = totalAxisLength / 3;
    
    return (NSInteger)(axisCoordinate / binWidth);
}

@end
