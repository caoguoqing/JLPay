//
//  TLVC_vCell.m
//  CPPay
//
//  Created by jielian on 2016/12/26.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "TLVC_vCell.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>

@implementation TLVC_vCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self loadSubviews];
        [self addKVO];
    }
    return self;
}

- (void) addKVO {
    RAC(self.stateLabel.layer, cornerRadius) = [RACObserve(self.stateLabel, bounds) map:^id(NSValue* value) {
        return @([value CGRectValue].size.height * 0.5);
    }];
}

- (void) loadSubviews {
    [self addSubview:self.bearView];
    [self.bearView addSubview:self.titleLabel];
    [self.bearView addSubview:self.stateLabel];
    [self.bearView addSubview:self.subTitleLabel];
    [self.bearView addSubview:self.contextLabel];
    [self.bearView addSubview:self.subContextLabel];
    [self.bearView addSubview:self.moreLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self makeMasonries];
}

- (void) makeMasonries {
    NameWeakSelf(wself);
    CGFloat insetV = ScreenWidth * 5/320.f;
    CGFloat insetH = ScreenWidth * 10/320.f;
    CGFloat insetB = ScreenWidth * 30/320.f;
    
    CGFloat widthTitle = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].width + insetH;
    CGFloat widthState = ScreenWidth * 40/320.f;
    
    [self.bearView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(insetB);
        make.right.mas_equalTo(- insetB * 0.5);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(- insetV);
    }];
 
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(insetH);
        make.top.mas_equalTo(insetV);
        make.width.mas_equalTo(widthTitle);
        make.height.mas_equalTo(wself.subTitleLabel.mas_height).multipliedBy(1.3);
    }];
    
    [self.subTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.titleLabel.mas_left);
        make.top.mas_equalTo(wself.titleLabel.mas_bottom);
        make.bottom.mas_equalTo(-insetV);
        make.width.mas_equalTo(wself.subContextLabel.mas_width).multipliedBy(1.5);
    }];
    
    [self.stateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.titleLabel.mas_right);
        make.width.mas_equalTo(widthState);
        make.centerY.mas_equalTo(wself.titleLabel.mas_centerY);
        make.height.mas_equalTo(wself.titleLabel.mas_height).multipliedBy(0.618);
    }];
    
    [self.contextLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(wself.moreLabel.mas_left);
        make.top.bottom.mas_equalTo(wself.titleLabel);
        make.left.mas_equalTo(wself.stateLabel.mas_right);
    }];
    
    [self.subContextLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(wself.contextLabel.mas_bottom);
        make.bottom.mas_equalTo(wself.subTitleLabel.mas_bottom);
        make.right.mas_equalTo(wself.contextLabel.mas_right);
        make.left.mas_equalTo(wself.subTitleLabel.mas_right);
    }];
    
    [self.moreLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(wself.moreLabel.mas_height).multipliedBy(0.618);
    }];
}



# pragma mask 4 getter

- (UIView *)bearView {
    if (!_bearView) {
        _bearView = [UIView new];
        _bearView.backgroundColor = [UIColor colorWithHex:0xeeeeee alpha:0.8];
        _bearView.layer.cornerRadius = ScreenWidth * 8 / 320.f;
    }
    return _bearView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor colorWithHex:0x27384b alpha:1];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel new];
        _subTitleLabel.textColor = [UIColor colorWithHex:0x888888 alpha:0.9];
        _subTitleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _subTitleLabel;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [UILabel new];
        _stateLabel.textColor = [UIColor colorWithHex:0xffffff alpha:1];
        _stateLabel.backgroundColor = [UIColor colorWithHex:0xef454b alpha:0.9];
        _stateLabel.font = [UIFont boldSystemFontOfSize:7];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.layer.masksToBounds = YES;
    }
    return _stateLabel;
}

- (UILabel *)contextLabel {
    if (!_contextLabel) {
        _contextLabel = [UILabel new];
        _contextLabel.textColor = [UIColor colorWithHex:0x27384b alpha:1];
        _contextLabel.font = [UIFont boldSystemFontOfSize:17];
        _contextLabel.textAlignment = NSTextAlignmentRight;
    }
    return _contextLabel;
}

- (UILabel *)subContextLabel {
    if (!_subContextLabel) {
        _subContextLabel = [UILabel new];
        _subContextLabel.textColor = [UIColor colorWithHex:0x888888 alpha:1];
        _subContextLabel.font = [UIFont systemFontOfSize:11];
        _subContextLabel.textAlignment = NSTextAlignmentRight;
    }
    return _subContextLabel;
}

- (UILabel *)moreLabel {
    if (!_moreLabel) {
        _moreLabel = [UILabel new];
        _moreLabel.textColor = [UIColor colorWithHex:0xaaaaaa alpha:1];
        _moreLabel.textAlignment = NSTextAlignmentCenter;
        _moreLabel.text = [NSString fontAwesomeIconStringForEnum:FAEllipsisV];
        _moreLabel.font = [UIFont fontAwesomeFontOfSize:15];
    }
    return _moreLabel;
}

@end
