//
//  PXPinnedRotationView
//
//  Created by acobb on 5/16/14.
//  Updated and finished by Daniel Blakemore ca. 9/26/14.
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

#import "PXPinnedRotationView.h"
#import "PXPinnedRotationViewController.h"

#define BaseConstraintIdentifier @"com.pixio.pinnedrotation.constraintidentifierforconstraint"

@implementation PXPinnedRotationView
{
    NSMutableDictionary * _constraintHandlers;
    NSMutableArray * _viewsToAnimate;
    NSArray * _rotatedConstraints;
    
    NSInteger _contraintVersion;
    NSInteger _lastAppliedVersion;
}

- (id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _constraintHandlers = [NSMutableDictionary dictionary];
        _viewsToAnimate = [NSMutableArray array];
        _rotatedConstraints = @[];
    }
    return self;
}

- (NSArray *)viewsToAnimateRotation
{
    return _viewsToAnimate;
}

- (void) setOrientation:(UIInterfaceOrientation)orientation
{
    _orientation = orientation;
    [self manuallyStartLayoutPass];
}

- (void)manuallyStartLayoutPass
{
    [self removeConstraints:_rotatedConstraints]; // this should be here because apple said not to invalidate constraints while updating constraints.
    _rotatedConstraints = [self rotateConstraints:[self calculateBaseConstraintsBeforeLayoutPass]];
    _contraintVersion++;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)registerUpdateHandler:(void (^)(NSLayoutConstraint * constraint))updateHandler forConstraint:(NSLayoutConstraint*)constraint identifier:(NSString*)identifier
{
    // don't use restricted names
    identifier = [NSString stringWithFormat:@"%@%@", BaseConstraintIdentifier, identifier];
    
    // save block and identify constraint
    [_constraintHandlers setObject:[updateHandler copy] forKey:identifier];
    
    [constraint setIdentifier:identifier];
}

- (NSArray*)rotateConstraints:(NSArray*)constraints
{
    BOOL rotated = UIInterfaceOrientationIsLandscape(_orientation);
    BOOL flipped = _orientation == UIInterfaceOrientationPortraitUpsideDown || _orientation == UIInterfaceOrientationLandscapeRight;
    
    NSLayoutAttribute (^ rotateAttrib)(NSLayoutAttribute) = ^ (NSLayoutAttribute a) {
        switch (a) {
            case NSLayoutAttributeLeadingMargin:
            case NSLayoutAttributeLeftMargin:
                return NSLayoutAttributeTopMargin;
            case NSLayoutAttributeLeading:
            case NSLayoutAttributeLeft:
                return NSLayoutAttributeTop;
                
            case NSLayoutAttributeTrailingMargin:
            case NSLayoutAttributeRightMargin:
                return NSLayoutAttributeBottomMargin;
            case NSLayoutAttributeTrailing:
            case NSLayoutAttributeRight:
                return NSLayoutAttributeBottom;
                
            case NSLayoutAttributeTopMargin:
                return NSLayoutAttributeRightMargin;
            case NSLayoutAttributeTop:
                return NSLayoutAttributeRight;
                
            case NSLayoutAttributeBottomMargin:
                return NSLayoutAttributeLeftMargin;
            case NSLayoutAttributeBottom:
                return NSLayoutAttributeLeft;
                
            case NSLayoutAttributeWidth:
                return NSLayoutAttributeHeight;
                
            case NSLayoutAttributeHeight:
                return NSLayoutAttributeWidth;
                
            case NSLayoutAttributeCenterXWithinMargins:
                return NSLayoutAttributeCenterYWithinMargins;
            case NSLayoutAttributeCenterX:
                return NSLayoutAttributeCenterY;
                
            case NSLayoutAttributeCenterYWithinMargins:
                return NSLayoutAttributeCenterXWithinMargins;
            case NSLayoutAttributeCenterY:
                return NSLayoutAttributeCenterX;
                
            default:
                return a;
        }
    };
    
    NSLayoutAttribute (^ flipAttrib)(NSLayoutAttribute) = ^ (NSLayoutAttribute a) {
        switch (a) {
            case NSLayoutAttributeLeft:
                return NSLayoutAttributeRight;
            case NSLayoutAttributeLeftMargin:
                return NSLayoutAttributeRightMargin;
            case NSLayoutAttributeRight:
                return NSLayoutAttributeLeft;
            case NSLayoutAttributeRightMargin:
                return NSLayoutAttributeLeftMargin;
            case NSLayoutAttributeTop:
                return NSLayoutAttributeBottom;
            case NSLayoutAttributeTopMargin:
                return NSLayoutAttributeBottomMargin;
            case NSLayoutAttributeBottom:
                return NSLayoutAttributeTop;
            case NSLayoutAttributeBottomMargin:
                return NSLayoutAttributeTopMargin;
            case NSLayoutAttributeLeading:
                return NSLayoutAttributeTrailing;
            case NSLayoutAttributeLeadingMargin:
                return NSLayoutAttributeTrailingMargin;
            case NSLayoutAttributeTrailing:
                return NSLayoutAttributeLeading;
            case NSLayoutAttributeTrailingMargin:
                return NSLayoutAttributeLeadingMargin;
            default:
                return a;
        }
    };
    
    NSLayoutAttribute (^ attribMeBro)(NSLayoutAttribute) = ^ (NSLayoutAttribute a) {
        if (rotated) {
            a = rotateAttrib(a);
        }
        if (flipped) {
            a = flipAttrib(a);
        }
        return a;
    };
    
    BOOL(^ attribNeedsConstantFlip)(NSLayoutAttribute) = ^ BOOL (NSLayoutAttribute a) {
        switch (attribMeBro(a)) {
            case NSLayoutAttributeLeft:
            case NSLayoutAttributeLeftMargin:
            case NSLayoutAttributeRight:
            case NSLayoutAttributeRightMargin:
            case NSLayoutAttributeCenterX:
            case NSLayoutAttributeCenterXWithinMargins:
            case NSLayoutAttributeLeading:
            case NSLayoutAttributeLeadingMargin:
            case NSLayoutAttributeTrailing:
            case NSLayoutAttributeTrailingMargin:
                return _orientation == UIInterfaceOrientationLandscapeLeft
                || _orientation == UIInterfaceOrientationPortraitUpsideDown;
            case NSLayoutAttributeCenterY:
            case NSLayoutAttributeCenterYWithinMargins:
            case NSLayoutAttributeBaseline:
            case NSLayoutAttributeFirstBaseline:
            case NSLayoutAttributeTop:
            case NSLayoutAttributeTopMargin:
            case NSLayoutAttributeBottom:
            case NSLayoutAttributeBottomMargin:
                return _orientation == UIInterfaceOrientationLandscapeRight
                || _orientation == UIInterfaceOrientationPortraitUpsideDown;
            case NSLayoutAttributeWidth:
            case NSLayoutAttributeHeight:
            case NSLayoutAttributeNotAnAttribute:
                return FALSE;
        }
        return FALSE;
    };
    
    NSMutableArray* rotatedConstraints = [NSMutableArray array];
    for (NSLayoutConstraint* constraint in constraints) {
        
        if ([constraint isKindOfClass:NSClassFromString(@"NSAutoresizingMaskLayoutConstraint")]) {
            [rotatedConstraints addObject:constraint];
            continue;
        }
        
        NSLayoutConstraint * rotatedConstraint = [NSLayoutConstraint
                                                  constraintWithItem:[constraint firstItem]
                                                  attribute:attribMeBro([constraint firstAttribute])
                                                  relatedBy:[constraint relation]
                                                  toItem:[constraint secondItem]
                                                  attribute:attribMeBro([constraint secondAttribute])
                                                  multiplier:[constraint multiplier]
                                                  constant:(attribNeedsConstantFlip([constraint firstAttribute]) ? -1 : 1) * [constraint constant]];
        
        [rotatedConstraints addObject:rotatedConstraint];
        
        // check if someone wants to know that we just rebuilt this constraint
        void (^updateHandler)(NSLayoutConstraint * constraint) = nil;
        if ((updateHandler = [_constraintHandlers objectForKey:[constraint identifier]])) {
            // keep track of new constraint
            [rotatedConstraint setIdentifier:[constraint identifier]];
            
            // call handler with new constraint
            updateHandler(rotatedConstraint);
        }
    }
    
    return rotatedConstraints;
}

- (void) updateConstraints
{
    if (_lastAppliedVersion != _contraintVersion) {
        _lastAppliedVersion = _contraintVersion;
        [self addConstraints:_rotatedConstraints?:@[]];
    }
    
    [super updateConstraints];
}

- (NSArray*)calculateBaseConstraintsBeforeLayoutPass
{
    // super does nothing
    return nil;
}

- (void)addViewToAnimate:(UIView*)view
{
    [_viewsToAnimate addObject:view];
}

- (void)addViewsToAnimate:(NSArray*)views
{
    [_viewsToAnimate addObjectsFromArray:views];
}

- (void)removeViewToAnimate:(UIView*)view
{
    [_viewsToAnimate removeObject:view];
}

@end