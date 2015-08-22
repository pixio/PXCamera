//
//  PXCameraButton.m
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

#import "PXCameraButton.h"

@implementation PXCameraButton
{
    NSString * _countDown;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _countDown = @"";
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self setNeedsDisplay];
}

- (NSString *)countDown
{
    return _countDown;
}

- (void)setCountDown:(NSString *)countDown
{
    _countDown = countDown;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat minDimm;
    CGFloat newX;
    CGFloat newY;
    if (rect.size.width < rect.size.height) {
        minDimm = rect.size.width;
        newX = rect.origin.x;
        newY = rect.origin.y + ((rect.size.height - minDimm) / 2);
    } else {
        minDimm = rect.size.height;
        newX = rect.origin.x + ((rect.size.width - minDimm) / 2);
        newY = rect.origin.y;
    }
    
    CGRect innerSquare = CGRectMake(newX, newY, minDimm, minDimm);
    
    // draw button
    CGContextClearRect(context, rect); // clear da screen
    [[UIColor clearColor] setFill];
    CGContextFillRect(context, rect);
    
    // draw da circle on da outzide
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 3.0f);
    CGContextStrokeEllipseInRect(context, CGRectInset(innerSquare, 1.5, 1.5));
    
    // innar cirkle
    if ([self isHighlighted]) {
        [[UIColor darkGrayColor] setFill];
    } else {
        [[UIColor whiteColor] setFill];
    }
    CGContextFillEllipseInRect(context, CGRectInset(innerSquare, 5, 5));
    
    // cut out text n shit
    CGContextSaveGState(context);
    UIFont * daFont; //.com
    daFont = [UIFont boldSystemFontOfSize:49];
    CGSize sizeOfFont = [_countDown sizeWithAttributes:@{NSFontAttributeName : daFont}];
    
    // translate to center font
    CGContextTranslateCTM(context, (innerSquare.size.width - sizeOfFont.width) / 2, (innerSquare.size.height - sizeOfFont.height) / 2);
    
    [[UIColor clearColor] setFill];
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    [_countDown drawInRect:innerSquare withAttributes:@{NSFontAttributeName : daFont}];
    CGContextRestoreGState(context);
}

@end
