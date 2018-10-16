//
//  AMPhotoBrowser.h
//  BaseProjectObjC
//
//  Created by xiaoniu on 2018/7/12.
//  Copyright © 2018 AAAma. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIImageView *(^AMPhotoBrowserImageViewAliasBlock)(NSInteger idx);

@interface AMPhotoBrowser : UIView
+ (void)showWithImages:(NSArray *)images
              curIndex:(NSInteger)curIndex
             superView:(UIView *)superView
        imageViewAlias:(AMPhotoBrowserImageViewAliasBlock)imageViewAlias;
@end
