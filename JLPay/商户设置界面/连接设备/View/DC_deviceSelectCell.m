//
//  DC_deviceSelectCell.m
//  JLPay
//
//  Created by 冯金龙 on 16/9/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DC_deviceSelectCell.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>



@interface DC_deviceSelectCell()



@end


@implementation DC_deviceSelectCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.deviceSelected = NO;
        [self loadSubviews];
        [self addKVOs];
    }
    return self;
}

- (void) loadSubviews {
    [self.contentView addSubview:self.checkLabel];
}

- (void) addKVOs {
    
    RAC(self.checkLabel, backgroundColor) = [RACObserve(self, deviceSelected) map:^id(id value) {
        return ([value boolValue]) ? ([UIColor orangeColor]) : ([UIColor colorWithWhite:1 alpha:0.4]);
    }];
    RAC(self.checkLabel, textColor) = [RACObserve(self, deviceSelected) map:^id(id value) {
        return ([value boolValue]) ? ([UIColor whiteColor]) : ([UIColor colorWithHex:0x27384b alpha:0.5]);
    }];
    
}



- (void)updateConstraints {
    
    NameWeakSelf(wself);
    
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(1, 0, 0, 0));
    }];
    
    [self.checkLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(wself.contentView.mas_centerY);
        make.right.mas_equalTo(wself.contentView.mas_right).offset(- 8);
        make.height.mas_equalTo(wself.contentView.mas_height).multipliedBy(0.45);
        make.width.mas_equalTo(wself.checkLabel.mas_height);
    }];
    
    [super updateConstraints];
}

# pragma mask : getter


- (UILabel *)checkLabel {
    if (!_checkLabel) {
        _checkLabel = [UILabel new];
        _checkLabel.text = [NSString fontAwesomeIconStringForEnum:FACheck];
        _checkLabel.textAlignment = NSTextAlignmentCenter;
        _checkLabel.textColor = [UIColor colorWithHex:0x27384b alpha:0.5];
//        _checkLabel.textColor = [UIColor colorWithWhite:1 alpha:0.2];
        _checkLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
        _checkLabel.layer.masksToBounds = YES;
        _checkLabel.layer.cornerRadius = 3.f;
    }
    return _checkLabel;
}


@end
