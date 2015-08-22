//
//  PXLibraryButton.m
//
//  Created by Daniel Blakemore on 7/21/14.
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

#import "PXLibraryButton.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation PXLibraryButton
{
    UIImageView * _backgroundImage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setClipsToBounds:TRUE];
        
        _backgroundImage = [[UIImageView alloc] init];
        [_backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
        [_backgroundImage setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_backgroundImage];
        
        NSDictionary* views = NSDictionaryOfVariableBindings(_backgroundImage);
        NSDictionary* metrics = @{};
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImage]|" options:0 metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImage]|" options:0 metrics:metrics views:views]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(loadNewestPhoto) 
                                                     name:ALAssetsLibraryChangedNotification 
                                                   object:nil];
        
        [self loadNewestPhoto];
        
    }
    return self;
}

- (void)dealloc
{
    // unobserve(d catheters)
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:ALAssetsLibraryChangedNotification 
                                                  object:nil];
}

#pragma mark - photo methods

- (void)loadNewestPhoto
{
    // http://stackoverflow.com/a/10200857/579405
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     if (nil != group) {
                                         // be sure to filter the group so you only get photos
                                         [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                         
                                         [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                             if (nil != result) {
                                                 ALAssetRepresentation *repr = [result defaultRepresentation];
                                                 // this is the most recent saved photo
                                                 [self setNewPhoto:[UIImage imageWithCGImage:[repr fullScreenImage]]];
                                                 // we only need the first (most recent) photo -- stop the enumeration
                                                 *stop = YES;
                                             }
                                         }];
                                     }
                                     
                                     *stop = NO;
                                 } failureBlock:^(NSError *error) {
                                     NSLog(@"error: %@", error);
                                 }];
}

- (void)setNewPhoto:(UIImage*)photo
{    
    [_backgroundImage setImage:photo];
}

#pragma mark - Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // brool story co
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // brool story co
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // touch time
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // brool story co
}

@end
