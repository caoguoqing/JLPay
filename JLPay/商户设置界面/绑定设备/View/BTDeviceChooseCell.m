//
//  BTDeviceChooseCell.m
//  JLPay
//
//  Created by jielian on 16/4/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BTDeviceChooseCell.h"



@implementation BTDeviceChooseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.checkView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.height * 0.45;
    NameWeakSelf(wself);
    [self.checkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself).offset(- 15);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(width);
        make.centerY.equalTo(wself.mas_centerY);
        wself.checkView.layer.cornerRadius = width * 0.5;
    }];
}

# pragma mask 4 getter 
- (CentreCircleCheckView *)checkView {
    if (!_checkView) {
        _checkView = [[CentreCircleCheckView alloc] initWithFrame:CGRectZero];
        _checkView.centreCircleView.backgroundColor = [UIColor whiteColor];
        _checkView.layer.borderColor = [UIColor whiteColor].CGColor;
        _checkView.layer.borderWidth = 1.5f;
    }
    return _checkView;
}

@end
