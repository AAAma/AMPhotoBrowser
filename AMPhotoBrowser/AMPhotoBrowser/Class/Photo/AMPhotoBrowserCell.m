//
//  AMPhotoBrowserCell.m
//  BaseProjectObjC
//
//  Created by xiaoniu on 2018/7/12.
//  Copyright © 2018 AAAma. All rights reserved.
//

#import "AMPhotoBrowserCell.h"

@interface AMPhotoBrowserCell ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) BOOL isPanning;
@property (nonatomic, assign) BOOL canDismiss;

@property (nonatomic, strong) NSValue *startOrigin;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CGPoint imageAnchorPoint;
@property (nonatomic, assign) CGPoint imagePosition;

@property (nonatomic, assign) CGFloat scrollOffsetX;
@property (nonatomic, assign) CGFloat opaqueValue;
@end

const CGFloat maxMoveOfY = 150.0f;
const CGFloat minZoomSizeScale = 0.6f;

@implementation AMPhotoBrowserCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubView];
        [self setupConstraint];
    }
    return self;
}


#pragma mark - Layout
- (void)setupSubView {
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
}

- (void)setupConstraint {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.size.mas_equalTo(kScreenSize);
    }];
}

#pragma mark - Public

- (void)setupImage:(UIImage *)image {
    
    self.scrollView.zoomScale = 1.0f;
    
    self.imageView.image = image;
    
    CGFloat height = kScreenSize.width / image.size.width * image.size.height;
    CGFloat y = (kScreenSize.height - height) * 0.5f;
    self.imageView.frame = CGRectMake(0.0f, y, kScreenSize.width, height);
    self.scrollView.contentSize = self.imageView.frame.size;
}

#pragma mark - <UIScrollViewDelegate>

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Event

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(browserCellClickEvent:)]) {
        [self.delegate browserCellClickEvent:self];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint touchPoint = [sender locationInView:sender.view];
        BOOL zoomOut = (self.scrollView.zoomScale == self.scrollView.minimumZoomScale);
        CGFloat scale = (zoomOut ? self.scrollView.maximumZoomScale : self.scrollView.minimumZoomScale);
        
        [UIView animateWithDuration:0.2f animations:^{
            self.scrollView.zoomScale = scale;
            if (zoomOut) {
                CGFloat x = touchPoint.x * scale - CGRectGetWidth(self.scrollView.bounds) * 0.5f;
                CGFloat max_x = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.bounds);
                CGFloat min_x = 0.0f;
                x = x > max_x ? max_x : x;
                x = x < min_x ? min_x : x;
                
                CGFloat y = touchPoint.y * scale - CGRectGetHeight(self.scrollView.bounds) * 0.5f;
                CGFloat max_y = self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds);
                CGFloat min_y = 0.0f;
                y = y > max_y ? max_y : y;
                y = y < min_y ? min_y : y;
                
                self.scrollView.contentOffset = CGPointMake(x, y);
            }
        }];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender {
    CGPoint movePoint = [sender translationInView:self];
    CGPoint curPoint = [sender locationInView:self];
    
    if ((sender.numberOfTouches > 1) ||
        (self.scrollView.zoomScale > 1.0f) ||
        (!self.isPanning && !(movePoint.y > 0 && movePoint.x == 0))) {
        return;
    }
    
    if (!self.startOrigin) {
        self.isPanning = YES;
        if ([self.delegate respondsToSelector:@selector(browserDragDownStatus:)]) {
            [self.delegate browserDragDownStatus:YES];
        }
        
        self.startOrigin = [NSValue valueWithCGPoint:curPoint];
        self.imageSize = self.imageView.frame.size;
        
        CGPoint origin = self.imageView.frame.origin;
        CGSize size = self.imageView.frame.size;
        
        CGFloat anchorX = curPoint.x / kScreenSize.width;
        CGFloat anchorY = curPoint.y / kScreenSize.height;
        self.imageAnchorPoint = self.imageView.layer.anchorPoint;
        self.imageView.layer.anchorPoint = CGPointMake(anchorX, anchorY);
        
        CGFloat positionX = origin.x + anchorX * size.width;
        CGFloat positionY = origin.y + anchorY * size.height;
        self.imagePosition = self.imageView.layer.position;
        self.imageView.layer.position = CGPointMake(positionX, positionY);
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        [self panChangedWithMovePoint:movePoint
                             curPoint:curPoint
                           panGesture:sender];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self panEnded];
    }
}

#pragma mark - Private

- (void)panChangedWithMovePoint:(CGPoint)movePoint
                       curPoint:(CGPoint)curPoint
                     panGesture:(UIPanGestureRecognizer *)sender {
    
    CGFloat molecular = (curPoint.y - self.startOrigin.CGPointValue.y);
    CGFloat denominator = (CGRectGetHeight(self.frame) - self.startOrigin.CGPointValue.y);
    
    self.canDismiss = (molecular > maxMoveOfY);
    self.opaqueValue = [self valueWithMolecular:molecular
                                    denominator:denominator];
    
    CGFloat scale = [self valueWithMolecular:(molecular * (1 - minZoomSizeScale))
                                 denominator:denominator];
    
    if (curPoint.y > self.startOrigin.CGPointValue.y) {
        self.imageView.bounds = ({
            CGRect rect = self.imageView.bounds;
            rect.size.width = self.imageSize.width * (1 - scale);
            rect.size.height = self.imageSize.height * (1 - scale);
            rect;
        });
    }
    
    self.imageView.transform =
    CGAffineTransformTranslate(self.imageView.transform, movePoint.x, movePoint.y);
    [sender setTranslation:CGPointZero inView:self];
}

- (void)panEnded {
    self.isPanning = NO;
    if ([self.delegate respondsToSelector:@selector(browserDragDownStatus:)]) {
        [self.delegate browserDragDownStatus:NO];
    }
    
    if (!self.canDismiss) {
        [UIView animateWithDuration:0.2f animations:^{
            self.opaqueValue = 0.0f;
            self.imageView.transform = CGAffineTransformIdentity;
            self.imageView.bounds = ({
                CGRect rect = self.imageView.bounds;
                rect.size = self.imageSize;
                rect;
            });
        } completion:^(BOOL finished) {
            self.startOrigin = nil;
            self.imageSize = CGSizeZero;
            self.imageView.layer.anchorPoint = self.imageAnchorPoint;
            self.imageView.layer.position = self.imagePosition;
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(browserCellClickEvent:)]) {
            [self.delegate browserCellClickEvent:self];
        }
    }
}

- (CGFloat)valueWithMolecular:(CGFloat)molecular denominator:(CGFloat)denominator {
    CGFloat value = molecular / denominator;
    return (value > 1.0f ? 1.0f : value);
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGSize size = scrollView.bounds.size;
    CGSize contentSize = scrollView.contentSize;

    CGFloat offsetX = 0.0f;
    if (size.width > contentSize.width) {
        offsetX = (size.width - contentSize.width) * 0.5f;
    }

    CGFloat offsetY = 0.0f;
    if (size.height > contentSize.height) {
        offsetY = (size.height - contentSize.height) * 0.5f;
    }

    return CGPointMake(contentSize.width * 0.5 + offsetX, contentSize.height * 0.5 + offsetY);
}

- (void)configScrollView:(UIScrollView *)scrollView {
    
    scrollView.delegate = self;
    scrollView.maximumZoomScale = 2.5f;
    scrollView.minimumZoomScale = 1.0f;
    
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    scrollView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *singleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer *doubleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    
    UIPanGestureRecognizer *pan =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    pan.maximumNumberOfTouches = 1;
    pan.delegate = self;;
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [singleTap requireGestureRecognizerToFail:pan];
    
    [scrollView addGestureRecognizer:singleTap];
    [scrollView addGestureRecognizer:doubleTap];
    [scrollView addGestureRecognizer:pan];
}

#pragma mark - Property

- (void)setOpaqueValue:(CGFloat)opaqueValue {
    _opaqueValue = opaqueValue;
    
    if ([self.delegate respondsToSelector:@selector(browserDragDownForOpaque:)]) {
        [self.delegate browserDragDownForOpaque:opaqueValue];
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [self configScrollView:_scrollView];
    }
    return _scrollView;
}

@end
