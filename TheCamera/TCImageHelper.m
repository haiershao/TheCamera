//
//  TCImageHelper.m
//  TheCamera
//
//  Created by honey.vi on 14-10-7.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import "TCImageHelper.h"

@implementation TCImageHelper

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
