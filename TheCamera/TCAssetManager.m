//
//  TCAssetManager.m
//  TheCamera
//
//  Created by honey.vi on 14-10-5.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import "TCAssetManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface TCAssetManager ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *internelAssets;

@end

@implementation TCAssetManager

+ (instancetype)defaultManager
{
    static TCAssetManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void) {
        manager = [[TCAssetManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        _internelAssets = [[NSMutableArray alloc] initWithCapacity:128];
        self.status = TCAssetManagerStatus_Init;
    }
    return self;
}

- (NSArray *)assetList
{
    if (self.status == TCAssetManagerStatus_Ready) {
        return self.internelAssets;
    }
    return nil;
}

- (void)scanAssets
{
    if (self.status == TCAssetManagerStatus_Scanning) {
        return;
    }
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [self.internelAssets addObject:result];
                }
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                self.status = TCAssetManagerStatus_Ready;
                [[NSNotificationCenter defaultCenter] postNotificationName:kTCAssetDidChangedNotification object:nil];
            });
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.status = TCAssetManagerStatus_Failed;
            [[NSNotificationCenter defaultCenter] postNotificationName:kTCAssetDidChangedNotification object:error];
        });
    };
    
    self.status = TCAssetManagerStatus_Scanning;
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                             usingBlock:resultsBlock
                                           failureBlock:failureBlock];
}


@end
