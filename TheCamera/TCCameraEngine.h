//
//  TCCameraEngine.h
//  TheCamera
//
//  Created by honey.vi on 14-10-3.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCCameraPreview;
@protocol TCCameraHelperDelegate;

@interface TCCameraEngine : NSObject

@property (nonatomic, readonly) TCCameraPreview *preview;
@property (nonatomic, weak) id<TCCameraHelperDelegate> delegate;

+ (TCCameraEngine *)sharedInstance;
- (void)changeCameraWithCompletion:(void (^)(void))completion;
- (void)startRunning;
- (void)stopRunning;
- (void)snapStillImage:(void (^)(NSData *))completion;

@end

@protocol TCCameraHelperDelegate <NSObject>

//@required
//- (UIInterfaceOrientation)cameraOrientation;

@optional
- (void)cameraEngineCapturingStillImage:(TCCameraEngine *)engine;
- (void)cameraEngine:(TCCameraEngine *)engine sessionIsRunning:(BOOL)running;

@end
