//
//  BusinessInfoTableViewCell.m
//  JLPay
//
//  Created by jielian on 15/11/19.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "BusinessInfoTableViewCell.h"


@implementation BusinessInfoTableViewCell




#pragma mask ---- 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = [PublicInformation returnCommonAppColor:@"red"];
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.labelUserId];
        [self.contentView addSubview:self.labelBusinessName];
        [self.contentView addSubview:self.labelBusinessNo];
        [self.contentView addSubview:self.labelCheckedState];
    }
    return self;
}

#pragma mask ---- 加载子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat inset = 15;
    CGFloat fontRate = 0.96;
    CGFloat heightImageV = self.frame.size.height * 0.85;
    
    CGFloat heightLabelT = self.frame.size.height - inset * 0.66 * 2;
    CGFloat heightBigLabel = heightLabelT * 0.46;
    CGFloat heightMinLabel = (heightLabelT - heightBigLabel) * 0.5;
    
    NameWeakSelf(wself);
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.contentView.mas_left).offset(inset);
        make.centerY.equalTo(wself.contentView.mas_centerY);
        make.width.mas_equalTo(heightImageV);
        make.height.mas_equalTo(heightImageV);
        wself.headImageView.layer.cornerRadius = heightImageV * 0.5;
    }];
    [self.labelUserId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.headImageView.mas_right).offset(inset);
        make.top.equalTo(wself.contentView.mas_top).offset(inset * 0.66);
        make.height.mas_equalTo(heightBigLabel);
        make.width.mas_equalTo([wself.labelUserId.text resizeAtHeight:heightBigLabel scale:1].width);
        wself.labelUserId.font = [UIFont systemFontOfSize:[wself.labelUserId.text resizeFontAtHeight:heightBigLabel scale:fontRate]];
    }];
    [self.labelBusinessName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.labelUserId.mas_left);
        make.top.equalTo(wself.labelUserId.mas_bottom);
        make.height.mas_equalTo(heightMinLabel);
        make.width.mas_equalTo([wself.labelBusinessName.text resizeAtHeight:heightMinLabel scale:1].width );
        wself.labelBusinessName.font = [UIFont systemFontOfSize:[wself.labelBusinessName.text resizeFontAtHeight:heightMinLabel scale:fontRate]];
    }];
    [self.labelBusinessNo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.labelBusinessName.mas_left);
        make.top.equalTo(wself.labelBusinessName.mas_bottom);
        make.height.mas_equalTo(heightMinLabel);
        make.width.mas_equalTo([wself.labelBusinessNo.text resizeAtHeight:heightMinLabel scale:1].width);
        wself.labelBusinessNo.font = [UIFont systemFontOfSize:[wself.labelBusinessNo.text resizeFontAtHeight:heightMinLabel scale:fontRate]];
    }];
    [self.labelCheckedState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.labelUserId.mas_right).offset(10);
        make.centerY.equalTo(wself.labelUserId.mas_centerY);
        make.height.mas_equalTo(heightBigLabel);
        make.width.mas_equalTo([wself.labelCheckedState.text resizeAtHeight:heightBigLabel scale:1].width);
        wself.labelCheckedState.font = [UIFont systemFontOfSize:[wself.labelCheckedState.text resizeFontAtHeight:heightBigLabel scale:0.5]];
        wself.labelCheckedState.layer.cornerRadius = heightBigLabel * 0.5;
    }];
}


#pragma mask ---- getter
- (UIImageView *)headImageView {
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _headImageView.backgroundColor = [UIColor whiteColor];
        _headImageView.image = [UIImage imageNamed:@"01_01"];
    }
    return _headImageView;
}

/* 登陆名 */
- (UILabel *)labelUserId {
    if (_labelUserId == nil) {
        _labelUserId = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelUserId.textColor = [UIColor whiteColor];
        _labelUserId.textAlignment = NSTextAlignmentLeft;
    }
    return _labelUserId;
}
/* 商户名 */
- (UILabel *)labelBusinessName {
    if (_labelBusinessName == nil) {
        _labelBusinessName = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelBusinessName.textColor = [UIColor whiteColor];
        _labelBusinessName.textAlignment = NSTextAlignmentLeft;
    }
    return _labelBusinessName;
}
/* 商户号 */
- (UILabel *)labelBusinessNo {
    if (_labelBusinessNo == nil) {
        _labelBusinessNo = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelBusinessNo.textColor = [UIColor whiteColor];
        _labelBusinessNo.textAlignment = NSTextAlignmentLeft;
    }
    return _labelBusinessNo;
}
- (UILabel *)labelCheckedState {
    if (!_labelCheckedState) {
        _labelCheckedState = [UILabel new];
        _labelCheckedState.backgroundColor = [UIColor whiteColor];
        _labelCheckedState.textAlignment = NSTextAlignmentCenter;
        _labelCheckedState.textColor = [PublicInformation returnCommonAppColor:@"red"];
        _labelCheckedState.layer.masksToBounds = YES;
    }
    return _labelCheckedState;
}

@end
