//
//  PXCameraDisplayView.m
//
//  Created by Daniel Blakemore on 8/21/15.
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

#import "PXCameraDisplayView.h"

#import "PXCameraGridLayer.h"

@implementation PXCameraDisplayView
{
    PXCameraGridLayer * _gridLayer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:(CGRect)frame];
    if (self) {
        _gridLayer = [[PXCameraGridLayer alloc] init];
//        [_gridLayer setZPosition:10];
        [_gridLayer setSpeed:1000];
        [[self layer] addSublayer:_gridLayer];
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [_gridLayer setFrame:[layer bounds]];
}

- (BOOL)gridHidden
{
    return [_gridLayer gridHidden];
}

- (void)setGridHidden:(BOOL)gridHidden
{
    [_gridLayer setGridHidden:gridHidden];
}

@end
