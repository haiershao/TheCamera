//
//  TCAssetManager.h
//  TheCamera
//
//  Created by honey.vi on 14-10-5.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTCAssetDidChangedNotification @"kTCAssetDidChangedNotification"

typedef enum _TCAssetManagerStatus {
    TCAssetManagerStatus_Init = 0,
    TCAssetManagerStatus_Ready,
    TCAssetManagerStatus_Scanning,
    TCAssetManagerStatus_Failed,
} TCAssetManagerStatus;

@interface TCAssetManager : NSObject

@property (nonatomic, readonly) NSArray *assetList;
@property (nonatomic, assign) TCAssetManagerStatus status;

+ (instancetype)defaultManager;
- (void)scanAssets;

@end
