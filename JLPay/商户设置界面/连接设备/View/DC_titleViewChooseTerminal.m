//
//  DC_titleViewChooseTerminal.m
//  JLPay
//
//  Created by jielian on 16/9/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DC_titleViewChooseTerminal.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>



@implementation DC_titleViewChooseTerminal

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
        [self addKVOs];
    }
    return self;
}


- (void) addKVOs {
    @weakify(self);
    [RACObserve(self, disclosured) subscribeNext:^(NSNumber* disclosured) {
        if (disclosured.boolValue) {
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                self.switchBtn.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                self.switchBtn.transform = CGAffineTransformIdentity;
            }];
        }
    }];
    
    [RACObserve(self.contentLabel, text) subscribeNext:^(id x) {
        @strongify(self);
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        [self layoutIfNeeded];
    }];
}


- (void) loadSubviews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.switchBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat heightTitleLab = self.frame.size.height * 0.33;
    CGFloat heightContentLab = self.frame.size.height - heightTitleLab;

    self.titleLabel.font = [UIFont boldSystemFontOfSize:[NSString resizeFontAtHeight:heightTitleLab scale:0.9]];
    self.contentLabel.font = [UIFont boldSystemFontOfSize:[NSString resizeFontAtHeight:heightContentLab scale:0.7]];
    self.switchBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:heightContentLab scale:0.8]];
    
    

}


- (void)updateConstraints {
    
    NameWeakSelf(wself);
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(wself.mas_height).multipliedBy(0.33);
    }];
    
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(wself.mas_height).multipliedBy(1 - 0.33);
    }];
    
    [self.switchBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(wself.contentLabel.mas_centerX).offset([wself.contentLabel.text sizeWithAttributes:@{NSFontAttributeName:wself.contentLabel.font}].width * 0.5 + 10);
        make.top.bottom.mas_equalTo(wself.contentLabel);
        make.width.mas_equalTo(wself.switchBtn.mas_height);
    }];

    
    [super updateConstraints];
}


# pragma mask 3 IBAction 
- (IBAction) clickedSwitchBtn:(id)sender {
    self.disclosured = !self.disclosured;
}


# pragma mask 4 getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.textColor = [UIColor whiteColor];
    }
    return _contentLabel;
}

- (UIButton *)switchBtn {
    if (!_switchBtn) {
        _switchBtn = [UIButton new];
        [_switchBtn setTitle:[NSString fontAwesomeIconStringForEnum:FACaretDown] forState:UIControlStateNormal];
        [_switchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_switchBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.5] forState:UIControlStateHighlighted];
        [_switchBtn addTarget:self action:@selector(clickedSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchBtn;
}




@end
