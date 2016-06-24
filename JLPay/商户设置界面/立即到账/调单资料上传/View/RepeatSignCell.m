//
//  RepeatSignCell.m
//  JLPay
//
//  Created by jielian on 16/5/25.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "RepeatSignCell.h"
#import "Masonry.h"
#import "Define_Header.h"


@implementation RepeatSignCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.signImgView];
        [self addSubview:self.backImgView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    
    CGFloat widthImgView = self.frame.size.width * 0.92;
    CGFloat heightImgView = self.frame.size.height * 0.95;
    
    if (self.signImgView.image) {
        
        self.backImgView.hidden = YES;
        CGSize imgSize = self.signImgView.image.size;
        
        if (imgSize.height > imgSize.width) {
            if (imgSize.width/imgSize.height >= heightImgView/widthImgView) {
                widthImgView = heightImgView * imgSize.height / imgSize.width;
            } else {
                heightImgView = widthImgView * imgSize.width / imgSize.height;
            }
        } else {
        }
    } else {
        heightImgView = self.frame.size.width * 0.8;
        widthImgView = self.frame.size.height * 0.95;
        self.backImgView.hidden = NO;
    }
    
    [self.backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wself.mas_centerX);
        make.centerY.equalTo(wself.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    self.signImgView.bounds = CGRectMake(0, 0, heightImgView, widthImgView);
    self.signImgView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    
    if (self.signImgView.image && (widthImgView > heightImgView)) {
        self.signImgView.transform = CGAffineTransformMakeRotation(- M_PI_2);
    } else {
        self.signImgView.transform = CGAffineTransformMakeRotation(0);
    }
}


# pragma mask 4 getter
- (UIImageView *)backImgView {
    if (!_backImgView) {
        _backImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sign_gray"]];
    }
    return _backImgView;
}
- (UIImageView *)signImgView {
    if (!_signImgView) {
        _signImgView = [[UIImageView alloc] init];
        _signImgView.layer.cornerRadius = 8.f;
        _signImgView.backgroundColor = [UIColor colorWithHex:0xecf0f1 alpha:1];
    }
    return _signImgView;
}


@end
