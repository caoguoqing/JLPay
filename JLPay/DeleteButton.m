//
//  DeleteButton.m
//  JLPay
//
//  Created by jielian on 15/5/18.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DeleteButton.h"

@interface DeleteButton ()

@property (nonatomic, strong)  UIImageView *imageView;

@end



@implementation DeleteButton

@synthesize imageView = _imageView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
        self.imageView                      = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/4.0, frame.size.height/4.0, frame.size.width/2.0, frame.size.height/2.0)];
        self.imageView.image                = [UIImage imageNamed:@"delete"];
        [self addSubview:self.imageView];
    }
    return self;
}

//- (void)layoutSubviews {
////    self.titleLabel.font                   = [UIFont f];
////    self.titleLabel.textColor                = [UIColor clearColor];
//}

@end
