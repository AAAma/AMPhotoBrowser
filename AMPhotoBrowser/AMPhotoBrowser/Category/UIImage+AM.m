//
//  UIImage+AM.m
//  BaseProjectObjC
//
//  Created by xiaoniu on 2018/7/12.
//  Copyright © 2018 AAAma. All rights reserved.
//

#import "UIImage+AM.h"

@implementation UIImage (AM)

#pragma mark - Objc

- (CGSize)imageSizeWithSize:(CGSize)size {
    CGFloat rate = [self scaleToSize:size];
    return CGSizeMake(self.size.width * rate, self.size.height * rate);
}

//缩放比例，取宽，高缩放比例中的较小值
- (CGFloat)scaleToSize:(CGSize)size {
    return MIN((size.width / self.size.width) , (size.height / self.size.height));
}

//把Image缩放到指定size
- (UIImage *)scaleImageToSize:(CGSize)size {
    return [self newImageToScale:[self scaleToSize:size]];
}

//使用指定缩放比例对Image进行缩放
- (UIImage *)newImageToScale:(float)scale {
    
    CGSize imgSize = self.size;
    CGSize resultImageSize = CGSizeMake(imgSize.width * scale, imgSize.height * scale);
    
    UIGraphicsBeginImageContext(resultImageSize);
    [self drawInRect:CGRectMake(0, 0, resultImageSize.width, resultImageSize.height)];
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (UIImage *)clipImageWithFrame:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

#pragma mark - Class

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1.0f, 1.0f)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)shotsImageWithView:(UIView *)view {
    
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 0.0f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
