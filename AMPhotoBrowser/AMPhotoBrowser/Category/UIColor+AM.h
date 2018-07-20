//
//  UIColor+AM.h
//  BaseProjectObjC
//
//  Created by xiaoniu on 2018/7/4.
//  Copyright © 2018年 AAAma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (AM)
+ (instancetype)hex:(UInt32)hex;
+ (instancetype)hex:(UInt32)hex alpha:(CGFloat)alpha;
+ (instancetype)randomColor;
@end
