//
//  TCCameraPreview.h
//  TheCamera
//
//  Created by honey.vi on 14-10-3.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface TCCameraPreview : UIView

@property (nonatomic) AVCaptureSession *session;

@end
