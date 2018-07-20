//
//  AMPhotoBrowserCell.h
//  BaseProjectObjC
//
//  Created by xiaoniu on 2018/7/12.
//  Copyright © 2018 AAAma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "AMMacroUtils.h"

@class AMPhotoBrowserCell;
@protocol AMPhotoBrowserCellDelegate <NSObject>
- (void)browserCellClickEvent:(AMPhotoBrowserCell *)cell;
- (void)browserDragDownForOpaque:(CGFloat)opaqueValue;
- (void)browserDragDownStatus:(BOOL)drag;
@end

@interface AMPhotoBrowserCell : UICollectionViewCell
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, weak) id<AMPhotoBrowserCellDelegate> delegate;

- (void)setupImage:(UIImage *)image;
@end
