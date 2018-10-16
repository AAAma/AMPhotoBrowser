//
//  AMPhotoBrowser.m
//  BaseProjectObjC
//
//  Created by xiaoniu on 2018/7/12.
//  Copyright © 2018 AAAma. All rights reserved.
//

#import "AMPhotoBrowser.h"
#import "AMPhotoBrowserCell.h"
#import "AutoScale.h"

@interface AMPhotoBrowser ()<UICollectionViewDataSource, UICollectionViewDelegate, AMPhotoBrowserCellDelegate>
@property (nonatomic, copy) AMPhotoBrowserImageViewAliasBlock imageViewAlias;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, copy) NSArray *images;

@property (nonatomic, strong) UIView *superView;
@end

const CGFloat kMargin = 10.0f;

@implementation AMPhotoBrowser
- (void)dealloc {
    NSLog(@"AMPhotoBrowser has dealloc!");
}

#pragma mark - Init

- (instancetype)initWithImages:(NSArray *)images
                      curIndex:(NSInteger)curIndex
                     superView:(UIView *)superView
                imageViewAlias:(AMPhotoBrowserImageViewAliasBlock)imageViewAlias {
    self = [super init];
    if (self) {
        _superView = superView;
        _images = [images copy];
        _imageViewAlias = [imageViewAlias copy];
        _indexPath = [NSIndexPath indexPathForRow:curIndex inSection:0];
        
        [self setupSubView];
        [self setupConstraint];
    }
    return self;
}

#pragma mark - Public

+ (void)showWithImages:(NSArray *)images
              curIndex:(NSInteger)curIndex
             superView:(UIView *)superView
        imageViewAlias:(AMPhotoBrowserImageViewAliasBlock)imageViewAlias {
    
    AMPhotoBrowser *browser = [[AMPhotoBrowser alloc] initWithImages:images curIndex:curIndex superView:superView imageViewAlias:imageViewAlias];
    [browser showAlias];
}

#pragma mark - Layout

- (void)setupSubView {
    self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.000001f];
    
    [self addSubview:self.collectionView];
    [self.superView addSubview:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView layoutIfNeeded];
        [self.collectionView scrollToItemAtIndexPath:self.indexPath
                                    atScrollPosition:UICollectionViewScrollPositionNone
                                            animated:NO];
    });
}

- (void)setupConstraint {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self).offset(scaleX(-kMargin * 0.5f));
        make.right.equalTo(self).offset(scaleX(kMargin * 0.5f));
    }];
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.superView);
    }];
}

#pragma mark - Animation

- (void)showAlias {
    
    UIImageView *alias = nil;
    if (self.imageViewAlias) {
        alias = self.imageViewAlias(self.indexPath.row);
    }
    
    if (alias) {
        CGRect newAliasFrame = [alias convertRect:alias.bounds toView:self];
        
        UIImageView *newAlias = [[UIImageView alloc] initWithFrame:newAliasFrame];
        newAlias.image = alias.image;
        [self addSubview:newAlias];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAliasWithImageView:newAlias];
        });
    } else {
        [self hitShow];
    }
}

- (void)showAliasWithImageView:(UIImageView *)imageView {
    
    CGSize imgSize = imageView.image.size;
    CGFloat height = kScreenSize.width / imgSize.width * imgSize.height;
    CGFloat y = (kScreenSize.height - height) * 0.5f;
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         imageView.frame = CGRectMake(0.0f, y, kScreenSize.width, height);
                         self.backgroundColor =
                         [UIColor.blackColor colorWithAlphaComponent:1.0f];
                     } completion:^(BOOL finished) {
                         self.collectionView.hidden = NO;
                         [imageView removeFromSuperview];
                     }];
}

- (void)dismissAliasWithImageView:(UIImageView *)imageView
                             frame:(CGRect)frame
                          curIndex:(NSInteger)curIndex {
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         imageView.frame = frame;
                         self.backgroundColor =
                         [UIColor.blackColor colorWithAlphaComponent:0.000001f];
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)hitShow{
    self.alpha = 0.000001f;
    self.collectionView.hidden = NO;
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 1.0f;
        self.backgroundColor =
        [UIColor.blackColor colorWithAlphaComponent:self.alpha];
    }];
}

- (void)hitHide {
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 0.000001f;
        self.backgroundColor =
        [UIColor.blackColor colorWithAlphaComponent:self.alpha];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(AMPhotoBrowserCell.class)
                                                     forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(AMPhotoBrowserCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
     cell.delegate = self;
    [cell setupImage:self.images[indexPath.row]];
}

#pragma mark - <AMPhotoBrowserCellDelegate>

- (void)browserCellClickEvent:(AMPhotoBrowserCell *)cell {
    
    UIImageView *alias = nil;
    NSInteger idx = [self.collectionView indexPathForCell:cell].row;
    
    if (self.imageViewAlias) {
        alias = self.imageViewAlias(idx);
    }
    
    if (alias) {
        self.collectionView.hidden = YES;
        
        CGRect newAliasFrame = [alias convertRect:alias.bounds toView:self];
        
        CGRect newCellAliasFrame = [cell.imageView convertRect:cell.imageView.bounds toView:self];
        UIImageView *newCellAlias = [[UIImageView alloc] initWithFrame:newCellAliasFrame];
        newCellAlias.image = cell.imageView.image;
        
        [self insertSubview:newCellAlias aboveSubview:self.collectionView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissAliasWithImageView:newCellAlias frame:newAliasFrame curIndex:idx];
        });
    } else {
        [self hitHide];
    }
}

- (void)browserDragDownForOpaque:(CGFloat)opaqueValue {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:(1.0f - opaqueValue)];
}

- (void)browserDragDownStatus:(BOOL)drag {
    self.collectionView.scrollEnabled = !drag;
}

#pragma mark - Property

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(kScreenSize.width + scaleX(kMargin), kScreenSize.height);
        layout.minimumInteritemSpacing = 0.0f;
        layout.minimumLineSpacing = 0.0f;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionView registerClass:AMPhotoBrowserCell.class
            forCellWithReuseIdentifier:NSStringFromClass(AMPhotoBrowserCell.class)];
        
        _collectionView.hidden = YES;
    }
    return _collectionView;
}

@end
