//
//  PXCameraDisplayView.m
//
//  Created by Daniel Blakemore on 8/14/15.
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

#import "PXCameraGridLayer.h"

@implementation PXCameraGridLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _gridHidden = TRUE;
    }
    return self;
}

- (void)setGridHidden:(BOOL)gridHidden
{
    _gridHidden = gridHidden;
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx
{
    if (_gridHidden) {
        return;
    }
    CGRect rect = [self frame];
    
    CGContextClearRect(ctx, rect);
    
    CGContextSetShadowWithColor(ctx, CGSizeZero, 0.5, [[UIColor grayColor] CGColor]);
    
    CGMutablePathRef linePath = CGPathCreateMutable();
    
    void (^drawLine)(CGPoint, CGPoint) = ^(CGPoint start, CGPoint end) {
        CGPathMoveToPoint(linePath, NULL, start.x, start.y);
        CGPathAddLineToPoint(linePath, NULL, end.x, end.y);
    };
    
    static const int xDivisions = 4;
    for (int i = 1; i < xDivisions - 1; i++) {
        CGFloat xValue = i / (double)(xDivisions - 1) * rect.size.width;
        CGPoint start = CGPointMake(xValue, 0);
        CGPoint end = CGPointMake(xValue, rect.size.height);
        drawLine(start, end);
    }
    
    static const int yDivisions = 4;
    for (int i = 1; i < yDivisions - 1; i++) {
        CGFloat yValue = i / (double)(yDivisions - 1) * rect.size.height;
        CGPoint start = CGPointMake(0, yValue);
        CGPoint end = CGPointMake(rect.size.width, yValue);
        drawLine(start, end);
    }
    
    // set thick gray
    CGContextSetLineWidth(ctx, 1.0f);
    CGContextSetStrokeColorWithColor(ctx, [[UIColor grayColor] CGColor]);
    CGContextAddPath(ctx, linePath);
    CGContextStrokePath(ctx);
    
    // set thin white
    CGContextSetLineWidth(ctx, 0.5f);
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextAddPath(ctx, linePath);
    CGContextStrokePath(ctx);
    CGPathRelease(linePath);
}

@end
