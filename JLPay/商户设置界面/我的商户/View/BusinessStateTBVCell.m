//
//  BusinessStateTBVCell.m
//  JLPay
//
//  Created by jielian on 16/5/4.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BusinessStateTBVCell.h"

@implementation BusinessStateTBVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.stateLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat heightStateLabel = self.frame.size.height * 0.5;
    CGFloat widthStateLabel = [@"teststring" resizeAtHeight:heightStateLabel scale:0.68].width + 10;
    
    NameWeakSelf(wself);
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(wself.contentView.mas_centerY);
        make.right.equalTo(wself.contentView.mas_right).offset(-15);
        make.height.mas_equalTo(heightStateLabel);
        make.width.mas_equalTo(widthStateLabel);
        wself.stateLabel.layer.cornerRadius = heightStateLabel * 0.5;
        wself.stateLabel.font = [UIFont systemFontOfSize:[wself.stateLabel.text resizeFontAtHeight:heightStateLabel scale:0.68]];
    }];
}

# pragma mask 4 getter
- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [UILabel new];
        _stateLabel.backgroundColor = [PublicInformation returnCommonAppColor:@"red"];
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.layer.masksToBounds = YES;
    }
    return _stateLabel;
}

@end
