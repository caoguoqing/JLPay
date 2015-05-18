//
//  DynamicScrollView.m
//  JLPay
//
//  Created by jielian on 15/5/18.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DynamicScrollView.h"


@interface DynamicScrollView ()

@end



@implementation DynamicScrollView



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化
        self.backgroundColor    = [UIColor orangeColor];
        self.contentSize        = CGSizeMake(frame.size.width, frame.size.height);
        
        [self addImageView];
    }
    return self;
}



////////////////////////   -- 测试用：临时添加 image，后续动态实现
- (void) addImageView {
    UIImageView * imageView     = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.image             = [UIImage imageNamed:@"01_03"];
    [self addSubview:imageView];
}
////////////////////////




@end
