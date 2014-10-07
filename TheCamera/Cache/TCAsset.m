//
//  TCAsset.m
//  TheCamera
//
//  Created by honey.vi on 14-10-7.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import "TCAsset.h"
#import "TCAssetCacheManager.h"

@interface TCAsset ()

@property (nonatomic, copy) NSString *path;

@end

@implementation TCAsset

- (id)init
{
    self = [super init];
    if (self) {
        _timeInterval = [NSDate timeIntervalSinceReferenceDate];
        _assetID = [NSString stringWithFormat:@"%lu_%@", (unsigned long)_timeInterval, [TCAssetCacheManager UUID]];
        
        _path = [[TCAssetCacheManager rootPath] stringByAppendingPathComponent:@"photos"];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:_path]) {
            [fm createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _dataPath = [_path stringByAppendingFormat:@"/%@.jpg", _assetID];
        _thumbPath = [_path stringByAppendingFormat:@"/%@_thumb.jpg", _assetID];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.assetID forKey:@"assetID"];
    [aCoder encodeObject:self.dataPath forKey:@"dataPath"];
    [aCoder encodeObject:self.metaData forKey:@"metaData"];
    [aCoder encodeDouble:self.timeInterval forKey:@"timeInterval"];
    [aCoder encodeObject:self.thumbPath forKey:@"thumbPath"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.assetID = [aDecoder decodeObjectForKey:@"assetID"];
        self.dataPath = [aDecoder decodeObjectForKey:@"dataPath"];
        self.metaData = [aDecoder decodeObjectForKey:@"metaData"];
        self.timeInterval = [aDecoder decodeDoubleForKey:@"timeInterval"];
        self.thumbPath = [aDecoder decodeObjectForKey:@"thumbPath"];
    }
    return self;
}

- (UIImage *)thumbImage
{
    if (!_thumbImage) {
        _thumbImage = [UIImage imageWithContentsOfFile:self.thumbPath];
    }
    return _thumbImage;
}

- (UIImage *)originalImage
{
    return [UIImage imageWithContentsOfFile:self.dataPath];
}

@end
