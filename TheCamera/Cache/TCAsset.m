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

- (NSString *)dataPath
{
    return [_path stringByAppendingFormat:@"/%@.jpg", _assetID];
}

- (NSString *)thumbPath
{
    return [_path stringByAppendingFormat:@"/%@_thumb.jpg", _assetID];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.assetID forKey:@"assetID"];
    [aCoder encodeObject:self.metaData forKey:@"metaData"];
    [aCoder encodeDouble:self.timeInterval forKey:@"timeInterval"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.assetID = [aDecoder decodeObjectForKey:@"assetID"];
        self.metaData = [aDecoder decodeObjectForKey:@"metaData"];
        self.timeInterval = [aDecoder decodeDoubleForKey:@"timeInterval"];
        _path = [[TCAssetCacheManager rootPath] stringByAppendingPathComponent:@"photos"];
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
