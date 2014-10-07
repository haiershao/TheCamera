//
//  TCAsset.h
//  TheCamera
//
//  Created by honey.vi on 14-10-7.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCAsset : NSObject <NSCoding>

@property (nonatomic, copy) NSString *assetID;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, copy) NSString *dataPath;

@property (nonatomic, copy) NSString *thumbPath;
@property (nonatomic, strong) UIImage *thumbImage;

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) NSDictionary *metaData;

- (id)init;

@end
