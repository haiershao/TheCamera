//
//  TCCameraEngine.m
//  TheCamera
//
//  Created by honey.vi on 14-10-3.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import "TCCameraEngine.h"
#import "TCCameraPreview.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface TCCameraEngine ()

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, assign) BOOL isDeviceAuthorized;

@end

@implementation TCCameraEngine

+ (id)sharedInstance
{
    static TCCameraEngine *cameraHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void) {
        cameraHelper = [[TCCameraEngine alloc] init];
    });
    return cameraHelper;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetPhoto;
        _preview = [[TCCameraPreview alloc] init];
        _preview.session = _session;
        [self checkDeviceAuthorizationStatus];
        
        _sessionQueue = dispatch_queue_create("TCCamerHelperSessionQueue", DISPATCH_QUEUE_SERIAL);
        
//        dispatch_async(_sessionQueue, ^{
        
            NSError *error = nil;
            
            AVCaptureDevice *videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
            _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
            
            if (error)
            {
                NSLog(@"%@", error);
            }
            
            if ([_session canAddInput:_videoDeviceInput])
            {
                [_session addInput:_videoDeviceInput];

                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [[(AVCaptureVideoPreviewLayer *)[_preview layer] connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
                });
            }
        
            
            _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            if ([_session canAddOutput:_stillImageOutput])
            {
                [_stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
                [_session addOutput:_stillImageOutput];
            }
//        });
    }
    return self;
}

- (void)startRunning
{
    if (self.session.isRunning) {
        return;
    }

    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAVCaptureSessionRuntimeErrorNotification:) name:AVCaptureSessionRuntimeErrorNotification object:nil];
        
    [self.session startRunning];
}

- (void)onAVCaptureSessionRuntimeErrorNotification:(NSNotification *)notification
{
    [self.session startRunning];
}

- (void)stopRunning
{
    if (!self.session.isRunning) {
        return;
    }
    
    [self.session stopRunning];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:nil];
    
    dispatch_async([self sessionQueue], ^{
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
    });
}

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            _isDeviceAuthorized = YES;
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                                            message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                _isDeviceAuthorized = NO;
            });
        }
    }];
}

- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

- (AVCaptureDevice *)currentCaptureDevice
{
    AVCaptureDevice *currentVideoDevice = [self.videoDeviceInput device];
    AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
    AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
    
    switch (currentPosition)
    {
        case AVCaptureDevicePositionUnspecified:
            preferredPosition = AVCaptureDevicePositionBack;
            break;
        case AVCaptureDevicePositionBack:
            preferredPosition = AVCaptureDevicePositionFront;
            break;
        case AVCaptureDevicePositionFront:
            preferredPosition = AVCaptureDevicePositionBack;
            break;
    }
    
    return [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
}

- (void)changeCameraWithCompletion:(void (^)(void))completion
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [self.videoDeviceInput device];
        AVCaptureDevice *videoDevice = [self currentCaptureDevice];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [[self session] beginConfiguration];
        
        [[self session] removeInput:[self videoDeviceInput]];
        if ([[self session] canAddInput:videoDeviceInput])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [self setFlashMode:_currentFlashMode forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else
        {
            [[self session] addInput:[self videoDeviceInput]];
        }
        
        [[self session] commitConfiguration];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)snapStillImage:(void (^)(NSData *))completion
{
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[self.preview layer] connection] videoOrientation]];
        
        [self setFlashMode:self.currentFlashMode forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer)
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//                UIImage *image = [[UIImage alloc] initWithData:imageData];
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(imageData);
                    });
                }
//                [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
            }
        }];
    });
}

- (void)setFocusAndExposedPonit:(CGPoint)point
{
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:point monitorSubjectAreaChange:YES];
}

- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext)
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage)
        {
            if ([self.delegate respondsToSelector:@selector(cameraEngineCapturingStillImage:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate cameraEngineCapturingStillImage:self];
                });
            }
        }
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        if ([self.delegate respondsToSelector:@selector(cameraEngine:sessionIsRunning:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate cameraEngine:self sessionIsRunning:isRunning];
            });
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

@end