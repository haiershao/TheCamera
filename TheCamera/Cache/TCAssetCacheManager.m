//
//  TCAssetCacheManager.m
//  TheCamera
//
//  Created by honey.vi on 14-10-7.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import "TCAssetCacheManager.h"
#import "TCAsset.h"
#import "TCImageHelper.h"

@interface TCAssetCacheManager ()

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation TCAssetCacheManager

+ (TCAssetCacheManager *)defaultManager
{
    static TCAssetCacheManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void) {
        manager = [[TCAssetCacheManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        _queue = dispatch_queue_create("TCAssetCacheManager_dispatch", NULL);
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:[[self class] rootPath]]) {
            [fm createDirectoryAtPath:[[self class] rootPath] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *dataPath = [self assetsDataPath];
        if ([fm fileExistsAtPath:dataPath]) {
            @try {
                _assets = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
            }
            @catch (NSException *exception) {
                _assets = [[NSMutableArray alloc] init];
            }
        }
        else {
            _assets = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}

- (void)cacheImageData:(NSData *)data metaData:(NSDictionary *)metaData
{
    if (!data) {
        return;
    }
    
    dispatch_async(self.queue, ^(void) {
        TCAsset *asset = [[TCAsset alloc] init];
        [data writeToFile:asset.dataPath atomically:YES];
        
        UIImage *oriImage = [UIImage imageWithData:data];
        UIImage *thumbImage = [TCImageHelper imageWithImage:oriImage scaledToSize:CGSizeMake(180, 180)];
        NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 0.9f);
        [thumbData writeToFile:asset.thumbPath atomically:NO];
        
        [self.assets addObject:asset];
        [NSKeyedArchiver archiveRootObject:self.assets toFile:[self assetsDataPath]];
    });
}

- (NSArray *)assetList
{
    return self.assets;
}

- (NSString *)assetsDataPath
{
    return [[[self class] rootPath] stringByAppendingString:@"/assets.data"];
}

+ (NSString *)rootPath
{
    static NSString *rootPath = nil;
    if (rootPath) {
        return rootPath;
    }
    
    rootPath = [[self docPath] stringByAppendingPathComponent:@"data"];
    return rootPath;
}

+ (NSString *)UUID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strUuid = CFUUIDCreateString(kCFAllocatorDefault,uuid);
    NSString * str = [NSString stringWithString:(__bridge NSString *)strUuid];
    CFRelease(strUuid);
    CFRelease(uuid);
    return str;	
}

+ (NSString *)docPath
{
    static NSString *documentsDirectory = nil;
    if (documentsDirectory) {
        return documentsDirectory;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
@end
