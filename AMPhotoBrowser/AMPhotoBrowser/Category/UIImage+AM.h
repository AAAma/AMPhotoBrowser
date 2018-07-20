//
//  UIImage+AM.h
//  BaseProjectObjC
//
//  Created by xiaoniu on 2018/7/12.
//  Copyright © 2018 AAAma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AM)
- (CGSize)imageSizeWithSize:(CGSize)size;
- (CGFloat)scaleToSize:(CGSize)size;
- (UIImage *)scaleImageToSize:(CGSize)size;
- (UIImage *)newImageToScale:(float)scale;
- (UIImage *)clipImageWithFrame:(CGRect)rect;

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)shotsImageWithView:(UIView *)view;
@end
