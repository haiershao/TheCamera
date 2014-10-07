//
//  TCAssetCacheManager.h
//  TheCamera
//
//  Created by honey.vi on 14-10-7.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCAssetCacheManager : NSObject

+ (TCAssetCacheManager *)defaultManager;
- (void)cacheImageData:(NSData *)data metaData:(NSDictionary *)metaData;
- (NSArray *)assetList;

+ (NSString *)UUID;
+ (NSString *)rootPath;

@end
