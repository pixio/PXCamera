//
//  PXCameraCaptureManager.h
//  Pixio
//
//  Created by Daniel Blakemore on 9/18/13.
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

#import "PXCameraCaptureManager.h"

@interface PXCameraCaptureManager (InternalUtilityMethods)
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) backFacingCamera;
- (AVCaptureDevice *) audioDevice;
- (NSURL *) tempFileURL;
- (void) removeFile:(NSURL *)outputFileURL;
- (void) copyFileToDocuments:(NSURL *)fileURL;
@end

@implementation PXCameraCaptureManager

- (id) init
{
    self = [super init];
    if (self != nil) {
		__unsafe_unretained id weakSelf = self;
        void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureDevice *device = [notification object];
			
			BOOL sessionHasDeviceWithMatchingMediaType = NO;
			NSString *deviceMediaType = nil;
			if ([device hasMediaType:AVMediaTypeAudio])
                deviceMediaType = AVMediaTypeAudio;
			else if ([device hasMediaType:AVMediaTypeVideo])
                deviceMediaType = AVMediaTypeVideo;
			
			if (deviceMediaType != nil) {
				for (AVCaptureDeviceInput *input in [_session inputs])
				{
					if ([[input device] hasMediaType:deviceMediaType]) {
						sessionHasDeviceWithMatchingMediaType = YES;
						break;
					}
				}
				
				if (!sessionHasDeviceWithMatchingMediaType) {
					NSError	*error;
					AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
					if ([_session canAddInput:input])
						[_session addInput:input];
				}
			}
            
			if ([_delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
				[_delegate captureManagerDeviceConfigurationChanged:self];
			}
        };
        void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureDevice *device = [notification object];
			
			if ([device hasMediaType:AVMediaTypeVideo]) {
				[_session removeInput:[weakSelf imageInput]];
				[weakSelf setImageInput:nil];
			}
			
			if ([_delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
				[_delegate captureManagerDeviceConfigurationChanged:self];
			}
        };
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [self setDeviceConnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:nil usingBlock:deviceConnectedBlock]];
        [self setDeviceDisconnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:nil usingBlock:deviceDisconnectedBlock]];
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
		_orientation = AVCaptureVideoOrientationPortrait;
    }
    
    return self;
}

- (void) dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:[self deviceConnectedObserver]];
    [notificationCenter removeObserver:[self deviceDisconnectedObserver]];
	[notificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        
    [_session stopRunning];
    [_session removeInput:_imageInput];
    [_session removeOutput:_stillImageOutput];
}

- (BOOL) setupSession
{
    return [self setupSessionWithDevicePosition:AVCaptureDevicePositionBack];
}

- (BOOL) setupSessionWithDevicePosition:(AVCaptureDevicePosition)position
{
    BOOL success = NO;
    
	// Set torch and flash mode to auto
	if ([[self backFacingCamera] hasFlash]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isFlashModeSupported:AVCaptureFlashModeAuto]) {
				[[self backFacingCamera] setFlashMode:AVCaptureFlashModeAuto];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
	if ([[self backFacingCamera] hasTorch]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isTorchModeSupported:AVCaptureTorchModeAuto]) {
				[[self backFacingCamera] setTorchMode:AVCaptureTorchModeAuto];
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
	
    // Init the device inputs
    AVCaptureDeviceInput *newVideoInput;
    switch (position) {
        case AVCaptureDevicePositionFront:
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:nil];
            break;
            
        case AVCaptureDevicePositionBack:
        default:
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
            break;
    }
    
	
    // Setup the still image file output
    AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [newStillImageOutput setOutputSettings:outputSettings];
    
    
    // Create session
    AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
    newCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    
    // Add inputs and output to the capture session
    if ([newCaptureSession canAddInput:newVideoInput]) {
        [newCaptureSession addInput:newVideoInput];
    }
    if ([newCaptureSession canAddOutput:newStillImageOutput]) {
        [newCaptureSession addOutput:newStillImageOutput];
    }
    
    [self setStillImageOutput:newStillImageOutput];
    [self setImageInput:newVideoInput];
    [self setSession:newCaptureSession];
    
    _stillImageConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[_stillImageOutput connections]];
    
    success = YES;
    
    return success;
}

- (BOOL) isFlashTypeSupported
{
    AVCaptureDevicePosition position = [[_imageInput device] position];
    AVCaptureDevice * camera;
    if (position == AVCaptureDevicePositionBack) {
        camera = [self backFacingCamera];
    } else if (position == AVCaptureDevicePositionFront) {
        camera = [self frontFacingCamera];
    }
    
    if ([camera hasFlash]) {
        return TRUE;
	}
    return FALSE;
}

- (void) setFlashType:(PXFlashType)flashType
{
    AVCaptureDevicePosition position = [[_imageInput device] position];
    AVCaptureDevice * camera;
    if (position == AVCaptureDevicePositionBack) {
        camera = [self backFacingCamera];
    } else if (position == AVCaptureDevicePositionFront) {
        camera = [self frontFacingCamera];
    }
    
    AVCaptureFlashMode flashMode;
    
    switch (flashType) {
        case PXFlashTypeAuto:
            flashMode = AVCaptureFlashModeAuto;
            break;
            
        case PXFlashTypeOn:
            flashMode = AVCaptureFlashModeOn;
            break;
            
        case PXFlashTypeOff:
        default:
            flashMode = AVCaptureFlashModeOff;
            break;
    }
    
    if ([camera hasFlash]) {
		if ([camera lockForConfiguration:nil]) {
			if ([camera isFlashModeSupported:flashMode]) {
				[camera setFlashMode:flashMode];
			}
			[camera unlockForConfiguration];
		}
	}
}

- (void) captureStillImageWithBlock:(void(^)(UIImage*))block
{
    if ([_stillImageConnection isVideoOrientationSupported]) {
        [_stillImageConnection setVideoOrientation:_orientation];
    }
    
    [[self stillImageOutput]
     captureStillImageAsynchronouslyFromConnection:_stillImageConnection
     completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         if (imageDataSampleBuffer != NULL) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             
             // Fix front facing camera so the image represents the preview
//             if ([self position] == AVCaptureDevicePositionFront) {
//                 UIImage* correctedImage = [UIImage imageWithCGImage:[image CGImage] scale:[image scale] orientation:UIImageOrientationLeftMirrored];
//                 image = correctedImage;
//             }
             
             if (block) {
                 block(image);
             }
         }
         
         if ([[self delegate] respondsToSelector:@selector(captureManagerStillImageCaptured:)]) {
             [[self delegate] captureManagerStillImageCaptured:self];
         }
     }];
}

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

// Toggle between the front and back camera, if both are present.
- (BOOL) toggleCamera
{
    AVCaptureDevicePosition position = [[_imageInput device] position];
    
    switch (position) {
        case AVCaptureDevicePositionFront:
            return [self setCameraPosition:AVCaptureDevicePositionBack];
            break;
            
        case AVCaptureDevicePositionBack:
            return [self setCameraPosition:AVCaptureDevicePositionFront];
            break;
        default:
            break;
    }
    
    return FALSE;
}

- (AVCaptureDevicePosition) position
{
    return [[_imageInput device] position];
}

- (BOOL) setCameraPosition:(AVCaptureDevicePosition)position
{
    static BOOL toggling = FALSE;
    
    if (toggling) {
        return FALSE;
    }
    
    AVCaptureDevicePosition oldPosition = [[_imageInput device] position];
    if (oldPosition == position) {
        return TRUE;
    }
    
    toggling = TRUE;
    BOOL success = NO;
    
    if ([self cameraCount] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newImageInput = nil;
        
        switch (position) {
            case AVCaptureDevicePositionFront:
                newImageInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
                break;
            case AVCaptureDevicePositionBack:
                newImageInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
                break;
            default:
                break;
        }

        if (newImageInput != nil) {
            [[self session] beginConfiguration];
            [[self session] removeInput:[self imageInput]];
            if ([[self session] canAddInput:newImageInput]) {
                [[self session] addInput:newImageInput];
                [self setImageInput:newImageInput];
            } else {
                [[self session] addInput:[self imageInput]];
            }
            [[self session] commitConfiguration];
            success = YES;
            _stillImageConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[_stillImageOutput connections]];
        } else if (error) {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
    }
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        toggling = FALSE;
    });

    return success;
}


#pragma mark Device Counts
- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger) micCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}


#pragma mark Camera Properties
// Perform an auto focus at the specified point. The focus mode will automatically change to locked once the auto focus is complete.
- (void) autoFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self imageInput] device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
    }
}

// Switch to continuous auto focus mode at the specified point
- (void) continuousFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [[self imageInput] device];
	
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:point];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
		} else {
			if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
			}
		}
	}
}

// Keep track of current device orientation so it can be applied to movie recordings and still image captures
- (void)deviceOrientationDidChange
{
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
	if (deviceOrientation == UIDeviceOrientationPortrait)
		_orientation = AVCaptureVideoOrientationPortrait;
	else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
		_orientation = AVCaptureVideoOrientationPortraitUpsideDown;
	
	// AVCapture and UIDevice have opposite meanings for landscape left and right (AVCapture orientation is the same as UIInterfaceOrientation)
	else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
		_orientation = AVCaptureVideoOrientationLandscapeRight;
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
		_orientation = AVCaptureVideoOrientationLandscapeLeft;
	
	// Ignore device orientations for which there is no corresponding still image orientation (e.g. UIDeviceOrientationFaceUp)
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

// Find and return an audio device, returning nil if one is not found
- (AVCaptureDevice *) audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}

@end
