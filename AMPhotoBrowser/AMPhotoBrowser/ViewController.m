//
//  ViewController.m
//  AMPhotoBrowser
//
//  Created by xiaoniu on 2018/7/20.
//  Copyright © 2018 AAAma. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+AM.h"
#import "UIImage+AM.h"
#import "AMMacroUtils.h"

#import "AMPhotoBrowser.h"

@interface ViewController ()
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *imageViews;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}


- (void)setupSubviews {
    NSInteger order = 3;
    CGFloat w = self.view.frame.size.width / 3;
    
    NSMutableArray *images = [NSMutableArray array];
    NSMutableArray *imageViews = [NSMutableArray array];
    for (NSInteger i = 0; i < pow(order, 2); ++i) {
        
        NSInteger row = i / order;
        NSInteger col = i % order;
        
        CGFloat x = col * w;
        CGFloat y = row * w;
        
        UIImageView *item = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, w)];
        item.userInteractionEnabled = YES;
        item.tag = i;
        
        item.image = [UIImage imageWithColor:UIColor.randomColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapEvent:)];
        
        [item addGestureRecognizer:tap];
        [self.view addSubview:item];
        
        [images addObject:item.image];
        [imageViews addObject:item];
    }
    
    self.images = [NSArray arrayWithArray:images];
    self.imageViews = [NSArray arrayWithArray:imageViews];
}

- (void)singleTapEvent:(UITapGestureRecognizer *)gesture {
    @AMWeakify(self);
    [AMPhotoBrowser showWithImages:self.images
                          curIndex:gesture.view.tag
                         superView:self.view
                    imageViewAlias:^UIImageView *(NSInteger idx) {
                        @AMStrongify(self);
                        return self.imageViews[idx];
                    }];
}

@end
