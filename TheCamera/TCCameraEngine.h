//
//  TCCameraEngine.h
//  TheCamera
//
//  Created by honey.vi on 14-10-3.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class TCCameraPreview;
@protocol TCCameraHelperDelegate;

@interface TCCameraEngine : NSObject

@property (nonatomic, readonly) TCCameraPreview *preview;
@property (nonatomic, weak) id<TCCameraHelperDelegate> delegate;

//闪光灯
@property (nonatomic, assign) AVCaptureFlashMode currentFlashMode;//闪光灯模式

//白平衡
@property (nonatomic, assign) AVCaptureWhiteBalanceMode whiteBalanceMode;
@property (nonatomic, assign) float whiteBalanceTemp;
@property (nonatomic, readonly) AVCaptureWhiteBalanceGains whiteBalanceGanis;

//曝光
@property (nonatomic, assign) CMTime shutterSpeed;
@property (nonatomic, assign) float ISOValue;

+ (TCCameraEngine *)sharedInstance;
- (void)changeCameraWithCompletion:(void (^)(void))completion;
- (void)startRunning;
- (void)stopRunning;
- (void)snapStillImage:(void (^)(NSData *))completion;

//曝光
- (void)setExposureAutoMode;

@end

@protocol TCCameraHelperDelegate <NSObject>

//@required
//- (UIInterfaceOrientation)cameraOrientation;

@optional
- (void)cameraEngineCapturingStillImage:(TCCameraEngine *)engine;
- (void)cameraEngine:(TCCameraEngine *)engine sessionIsRunning:(BOOL)running;

@end
