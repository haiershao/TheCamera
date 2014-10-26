//
//  TCUtils.m
//  TheCamera
//
//  Created by honey.vi on 14-10-26.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import "TCUtils.h"

@implementation TCUtils

+ (NSString *)shutterSpeedString:(CMTime)time
{
    static NSArray *decimals = nil;
    if (!decimals) {
        decimals = @[@0.00025f, @0.0003125f, @0.0004f, @0.0005f,  @0.000625f,
                     @0.0008f,  @0.001f,     @0.00125, @0.00156f, @0.002f,
                     @0.0025f,  @0.003125f,  @0.004f,  @0.005f,   @0.00625f,
                     @0.008f,   @0.01f,      @0.0125f, @0.01667f, @0.02f,
                     @0.025f,   @0.033333f,  @0.04f,   @0.05f,    @0.06667f,
                     @0.0769f,  @0.1f,       @0.125f,  @0.16667f, @0.2f,
                     @0.25f,    @0.333333f,  @0.4f,    @0.5f,     @0.625f,
                     @0.769f,   @1.0f,       @1.3f,    @1.6f,     @2.0f,
                     @2.5f,     @3.0f,       @4.0f,    @5.0f];
    }
    
    static NSArray *strs = nil;
    if (!strs) {
        strs = @[
                 @"1/4000", @"1/3200", @"1/2500", @"1/2000", @"1/1600",
                 @"1/1250", @"1/1000", @"1/800",  @"1/640",  @"1/500",
                 @"1/400",  @"1/320",  @"1/250",  @"1/200",  @"1/160",
                 @"1/125",  @"1/100",  @"1/80",   @"1/60",   @"1/50",
                 @"1/40",   @"1/30",   @"1/25",   @"1/20",   @"1/15",
                 @"1/13",   @"1/10",   @"1/8",    @"1/6",    @"1/5",
                 @"1/4",    @"1/3",    @"1/2.5",  @"1/2",    @"1/1.6",
                 @"1/1.3",  @"1",      @"1.3",    @"1.6",    @"2",
                 @"2.5",    @"3",      @"4",      @"5"];
    }
    
    if (time.timescale == 0 || time.value == 0) {
        return @"";
    }
    
    float f = (float)time.value / time.timescale;
    __block NSInteger resultIndex = -1;
    __block float minGap = 1;
    
    [decimals enumerateObjectsUsingBlock:^(id number, NSUInteger index, BOOL *stop) {
        float a = [number floatValue] - f;
        if (a < 0) {
            a *= -1;
        }
        
        if (a < minGap) {
            minGap = a;
        }
        else {
            resultIndex = (NSInteger)index - 1;
            *stop = YES;
        }
    }];

    if (resultIndex < 0 || resultIndex >= strs.count) {
        NSLog(@"f:%f", f);
    }
    return strs[resultIndex];
}

@end
