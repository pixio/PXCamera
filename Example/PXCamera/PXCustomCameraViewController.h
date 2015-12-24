//
//  PXCustomCameraViewController.h
//  PXCamera
//
//  Created by Daniel Blakemore on 12/23/15.
//  Copyright © 2015 Daniel Blakemore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PXCustomCameraViewController : UIViewController

- (instancetype)initWithCompletion:(void(^)(UIImage * image, BOOL pictureTaken))completion;

@end
