//
//  BRPC_chooseCell.m
//  JLPay
//
//  Created by jielian on 16/8/30.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BRPC_chooseCell.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"


@interface BRPC_chooseCell()

@property (nonatomic, strong) UIView* selectedBarView;

@end

@implementation BRPC_chooseCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.selectedBarView];
        
        RAC(self.selectedBarView, hidden) = [RACObserve(self, brpc_selected) map:^id(id value) {
            return @(![value boolValue]);
        }];
        
        CGFloat width = 6;
        
        NameWeakSelf(wself);
        [self.selectedBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(wself.mas_left);
            make.width.mas_equalTo(width);
            make.top.bottom.mas_equalTo(wself);
        }];

    }
    return self;
}




# pragma mask 4 getter

- (UIView *)selectedBarView {
    if (!_selectedBarView) {
        _selectedBarView = [UIView new];
        _selectedBarView.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
    }
    return _selectedBarView;
}

@end
