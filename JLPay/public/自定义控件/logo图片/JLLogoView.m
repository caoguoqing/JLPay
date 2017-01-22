//
//  JLLogoView.m
//  JLPay
//
//  Created by jielian on 2017/1/20.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "JLLogoView.h"
#import "Define_Header.h"
#import "Masonry.h"

@interface JLLogoView()

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* logoTitileLabel;
@property (nonatomic, strong) UILabel* urlLabel;

@end
@implementation JLLogoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.logoTitileLabel];
        [self addSubview:self.urlLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    CGFloat inset = ScreenWidth * 3/320.f;
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(0);
        make.width.mas_equalTo(wself.imageView.mas_height);
    }];
    [self.urlLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(0);
        make.right.mas_equalTo(wself.imageView.mas_left).mas_offset(- inset);
        make.height.mas_equalTo(wself.mas_height).multipliedBy(0.25);
    }];
    [self.logoTitileLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(wself.urlLabel);
        make.bottom.mas_equalTo(wself.urlLabel.mas_top);
        make.height.mas_equalTo(wself.urlLabel.mas_height).multipliedBy(1.5);
    }];
}

# pragma mask 4 getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[PublicInformation logoImageOfApp]];
    }
    return _imageView;
}
- (UILabel *)logoTitileLabel {
    if (!_logoTitileLabel) {
        _logoTitileLabel = [UILabel new];
        _logoTitileLabel.text = [PublicInformation appNameOnDifferentBranch];
        _logoTitileLabel.textColor = [UIColor colorWithHex:0xef454b alpha:1];
        _logoTitileLabel.textAlignment = NSTextAlignmentRight;
        _logoTitileLabel.font = [UIFont boldSystemFontOfSize:11];
    }
    return _logoTitileLabel;
}
- (UILabel *)urlLabel {
    if (!_urlLabel) {
        _urlLabel = [UILabel new];
        _urlLabel.text = [PublicInformation urlOfCompany];
        _urlLabel.textColor = [UIColor colorWithHex:0xef454b alpha:1];
        _urlLabel.textAlignment = NSTextAlignmentRight;
        _urlLabel.font = [UIFont boldSystemFontOfSize:7];
    }
    return _urlLabel;
}


@end
