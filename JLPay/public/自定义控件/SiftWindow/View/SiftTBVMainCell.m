//
//  SiftTBVMainCell.m
//  JLPay
//
//  Created by jielian on 16/6/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SiftTBVMainCell.h"
#import "Masonry.h"
#import "Define_Header.h"

@implementation SiftTBVMainCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.siftCountLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat heightCountLabel = self.frame.size.height * 0.4;
    
    self.siftCountLabel.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightCountLabel scale:0.7]];
    self.siftCountLabel.layer.cornerRadius = heightCountLabel * 0.5;
    
    NameWeakSelf(wself);
    [self.siftCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.mas_right).offset(-5);
        make.centerY.equalTo(wself.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(heightCountLabel, heightCountLabel));
    }];
    
}


# pragma mask 4 getter

- (UILabel *)siftCountLabel {
    if (!_siftCountLabel) {
        _siftCountLabel = [UILabel new];
        _siftCountLabel.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.75];
        _siftCountLabel.textAlignment = NSTextAlignmentCenter;
        _siftCountLabel.textColor = [UIColor whiteColor];
        _siftCountLabel.layer.masksToBounds = YES;
    }
    return _siftCountLabel;
}

@end
