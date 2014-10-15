//
//  TCCameraGridView.m
//  TheCamera
//
//  Created by honey.vi on 14-10-15.
//  Copyright (c) 2014年 liunan. All rights reserved.
//

#import "TCCameraGridView.h"

@implementation TCCameraGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.lineColor = [UIColor colorWithRed:135.0f/255.0f green:120.0f/255.0f blue:121.0f/255.0f alpha:0.8f];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    
    CGContextMoveToPoint(context, self.bounds.size.width / 3, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width / 3, self.bounds.size.height);
    
    CGContextMoveToPoint(context, self.bounds.size.width * 2 / 3, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width * 2 / 3, self.bounds.size.height);

    CGContextMoveToPoint(context, 0, self.bounds.size.height / 3);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height / 3);
    
    CGContextMoveToPoint(context, 0, self.bounds.size.height * 2 / 3);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height * 2 / 3);
    
    CGContextStrokePath(context);
    UIGraphicsEndImageContext();
}


@end
