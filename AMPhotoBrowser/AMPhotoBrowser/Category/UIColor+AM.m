//
//  UIColor+AM.m
//  BaseProjectObjC
//
//  Created by xiaoniu on 2018/7/4.
//  Copyright © 2018年 AAAma. All rights reserved.
//

#import "UIColor+AM.h"

@implementation UIColor (AM)
+ (instancetype)hex:(UInt32)hex {
    return [self hex:hex alpha:1.0f];
}

+ (instancetype)hex:(UInt32)hex alpha:(CGFloat)alpha {
    return [self colorWithRed:(((hex & 0xFF0000) >> 16) / 255.0f)
                        green:(((hex & 0xFF00) >> 8) / 255.0f)
                         blue:((hex & 0xFF) / 255.0f)
                        alpha:alpha];
}

+ (instancetype)randomColor {
    return [self colorWithRed:(arc4random_uniform(255) / 255.0f)
                        green:(arc4random_uniform(255) / 255.0f)
                         blue:(arc4random_uniform(255) / 255.0f)
                        alpha:1.0f];
}

@end
