//
//  DC_mposView.m
//  JLPay
//
//  Created by jielian on 16/9/6.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DC_mposView.h"
#import "Masonry.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>


@interface DC_mposView()



/* 数字按钮组 */
@property (nonatomic, strong) NSArray* numberBtns;

/* 显示屏 */
@property (nonatomic, strong) UIView* screenView;

/* 标题 */
@property (nonatomic, strong) UILabel* terminalTitleLab;


@end




@implementation DC_mposView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
        [self addKVOs];
        self.state = DC_VIEW_STATE_WAITTING;
        self.backgroundColor = [UIColor colorWithHex:0x4b9993 alpha:1];
        self.layer.cornerRadius = 20;
    }
    return self;
}

- (void) loadSubviews {
    [self addSubview:self.screenView];
    [self addSubview:self.terminalTitleLab];
    [self addSubview:self.stateTextLab];
    [self addSubview:self.activitor];
    [self addSubview:self.devicesTBV];
    [self addSubview:self.reScanBtn];
    [self addSubview:self.bindBtn];
    for (UILabel* numLab in self.numberBtns) {
        [self addSubview:numLab];
    }
}

- (void) addKVOs {
    @weakify(self);
    
    [RACObserve(self, state) subscribeNext:^(NSNumber* state) {
        @strongify(self);
        switch (state.integerValue) {
            case DC_VIEW_STATE_WAITTING:
            {
                [self.activitor show];
            }
                break;
            default:
            {
                [self.activitor hide];
            }
                break;
        }
    }];
}


- (void)updateConstraints {
    
    if (self.frame.size.height <= 0.00001) {
        [super updateConstraints];
        return;
    }
    
    CGFloat inset = 10 * [UIScreen mainScreen].bounds.size.height / 667.f;
    
    NameWeakSelf(wself);
    
    [self.screenView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(wself.mas_centerY).offset(-inset);
        make.height.mas_equalTo(wself.mas_height).multipliedBy(0.5 * 0.75);
        make.left.mas_equalTo(wself.mas_left).offset(inset * 2);
        make.right.mas_equalTo(wself.mas_right).offset(- inset * 2);
    }];
    
    UILabel* numLab0 = [self.numberBtns objectAtIndex:0];
    UILabel* numLab1 = [self.numberBtns objectAtIndex:1];
    UILabel* numLab2 = [self.numberBtns objectAtIndex:2];
    UILabel* numLab3 = [self.numberBtns objectAtIndex:3];
    UILabel* numLab4 = [self.numberBtns objectAtIndex:4];
    UILabel* numLab5 = [self.numberBtns objectAtIndex:5];
    UILabel* numLab6 = [self.numberBtns objectAtIndex:6];
    UILabel* numLab7 = [self.numberBtns objectAtIndex:7];
    UILabel* numLab8 = [self.numberBtns objectAtIndex:8];
    UILabel* numLab9 = [self.numberBtns objectAtIndex:9];
    
    [numLab0 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@[numLab1, numLab2]);
        make.height.mas_equalTo(@[numLab3, numLab6, numLab9]);
        make.left.mas_equalTo(inset * 2);
        make.top.mas_equalTo(wself.screenView.mas_bottom).offset(inset);
        make.bottom.mas_equalTo(numLab3.mas_top).offset(- inset);
    }];
    [numLab1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(numLab0.mas_right).offset(inset);
        make.right.mas_equalTo(numLab2.mas_left).offset(-inset);
        make.top.mas_equalTo(numLab0.mas_top);
        make.bottom.mas_equalTo(numLab0.mas_bottom);
    }];
    [numLab2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(wself.mas_right).offset(- inset * 2);
        make.top.mas_equalTo(numLab1.mas_top);
        make.bottom.mas_equalTo(numLab1.mas_bottom);
    }];
    
    [numLab3 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@[numLab4, numLab5]);
        make.left.mas_equalTo(inset * 2);
        make.top.mas_equalTo(numLab0.mas_bottom).offset(inset);
        make.bottom.mas_equalTo(numLab6.mas_top).offset(- inset);
    }];
    [numLab4 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(numLab3.mas_right).offset(inset);
        make.right.mas_equalTo(numLab5.mas_left).offset(- inset);
        make.top.mas_equalTo(numLab3.mas_top);
        make.bottom.mas_equalTo(numLab3.mas_bottom);
    }];
    [numLab5 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(wself.mas_right).offset(- inset * 2);
        make.top.mas_equalTo(numLab3.mas_top);
        make.bottom.mas_equalTo(numLab3.mas_bottom);
    }];
    
    [numLab6 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@[numLab7, numLab8]);
        make.left.mas_equalTo(inset * 2);
        make.top.mas_equalTo(numLab3.mas_bottom).offset(inset);
        make.bottom.mas_equalTo(numLab9.mas_top).offset(- inset);
    }];
    [numLab7 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(numLab6.mas_right).offset(inset);
        make.right.mas_equalTo(numLab8.mas_left).offset(- inset);
        make.top.mas_equalTo(numLab6.mas_top);
        make.bottom.mas_equalTo(numLab6.mas_bottom);
    }];
    [numLab8 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(wself.mas_right).offset(- inset * 2);
        make.top.mas_equalTo(numLab6.mas_top);
        make.bottom.mas_equalTo(numLab6.mas_bottom);
    }];
    
    [numLab9 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(numLab0);
        make.centerX.mas_equalTo(wself.mas_centerX);
        make.bottom.mas_equalTo(wself.mas_bottom).offset(- inset * 5);
    }];
    
    [self.reScanBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(numLab0.mas_left);
        make.width.mas_equalTo(numLab0);
        make.top.mas_equalTo(numLab9);
        make.bottom.mas_equalTo(wself.mas_bottom).offset(- inset * 2);
    }];
    [self.bindBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(numLab2);
        make.width.height.mas_equalTo(wself.reScanBtn);
        make.top.mas_equalTo(wself.reScanBtn);
    }];
    
    [self.activitor mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(wself.screenView);
        make.width.height.mas_equalTo(inset * 2);
        make.top.mas_equalTo(wself.screenView.mas_top).offset(inset);
    }];
    
    self.stateTextLab.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:inset * 2 scale:0.75]];
    [self.stateTextLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(wself.screenView);
        make.height.mas_equalTo(inset * 2);
        make.top.mas_equalTo(wself.activitor.mas_bottom).offset(inset * 0.5);
    }];
    
    [self.terminalTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(wself.screenView.mas_top);
    }];
    
    [self.devicesTBV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(wself.stateTextLab.mas_bottom).offset(10);
        make.bottom.mas_equalTo(wself.screenView.mas_bottom).offset(- 10);
        make.centerX.mas_equalTo(wself.screenView.mas_centerX);
        make.width.mas_equalTo(wself.screenView.mas_width).multipliedBy(0.9);
    }];
    
    [super updateConstraints];
}




# pragma mask 4 getter

- (UITableView *)devicesTBV {
    if (!_devicesTBV) {
        _devicesTBV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _devicesTBV.backgroundColor = [UIColor clearColor];
        _devicesTBV.tableFooterView = [UIView new];
        _devicesTBV.separatorStyle = UITableViewCellSelectionStyleNone;
    }
    return _devicesTBV;
}

- (UIView *)screenView {
    if (!_screenView) {
        _screenView = [UIView new];
        _screenView.layer.cornerRadius = 14.f;
        _screenView.backgroundColor = [UIColor colorWithHex:0x27384b alpha:1];
    }
    return _screenView;
}

- (UILabel *)terminalTitleLab {
    if (!_terminalTitleLab) {
        _terminalTitleLab = [UILabel new];
        _terminalTitleLab.text = @"MPOS蓝牙设备";
        _terminalTitleLab.textAlignment = NSTextAlignmentCenter;
        _terminalTitleLab.textColor = [UIColor whiteColor];
        _terminalTitleLab.font = [UIFont boldSystemFontOfSize:14];
    }
    return _terminalTitleLab;
}

- (UILabel *)stateTextLab {
    if (!_stateTextLab) {
        _stateTextLab = [UILabel new];
        _stateTextLab.textAlignment = NSTextAlignmentCenter;
        _stateTextLab.textColor = [UIColor whiteColor];
        _stateTextLab.numberOfLines = 0;
        _stateTextLab.adjustsFontSizeToFitWidth = YES;
        _stateTextLab.minimumScaleFactor = 0.5;
        _stateTextLab.text = @"正在扫描设备...";
    }
    return _stateTextLab;
}

- (MLActivitor *)activitor {
    if (!_activitor) {
        _activitor = [[MLActivitor alloc] init];
        _activitor.tintColor = [UIColor whiteColor];
    }
    return _activitor;
}
- (UIButton *)reScanBtn {
    if (!_reScanBtn) {
        _reScanBtn = [UIButton new];
        [_reScanBtn setTitle:@"重新\n扫描" forState:UIControlStateNormal];
        _reScanBtn.titleLabel.numberOfLines = 0;
        _reScanBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _reScanBtn.backgroundColor = [UIColor colorWithHex:0x27384b alpha:1];
        [_reScanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_reScanBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.4] forState:UIControlStateHighlighted];
        _reScanBtn.layer.cornerRadius = 6.f;
    }
    return _reScanBtn;
}

- (UIButton *)bindBtn {
    if (!_bindBtn) {
        _bindBtn = [UIButton new];
        [_bindBtn setTitle:@"绑定\n设备" forState:UIControlStateNormal];
        _bindBtn.titleLabel.numberOfLines = 0;
        _bindBtn.backgroundColor = [UIColor colorWithHex:0x27384b alpha:1];
        _bindBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_bindBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_bindBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.4] forState:UIControlStateHighlighted];
        [_bindBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.4] forState:UIControlStateDisabled];
        _bindBtn.layer.cornerRadius = 6.f;
    }
    return _bindBtn;
}

- (NSArray *)numberBtns {
    if (!_numberBtns) {
        NSMutableArray* btns = [NSMutableArray array];
        for (int i = 1; i <= 10; i++) {
            UILabel* numLab = [UILabel new];
            numLab.backgroundColor = [UIColor colorWithHex:0x27384b alpha:1];
            numLab.textColor = [UIColor whiteColor];
            numLab.textAlignment = NSTextAlignmentCenter;
            numLab.layer.masksToBounds = YES;
            numLab.layer.cornerRadius = 6.f;
            numLab.text = [NSString stringWithFormat:@"%d", i%10];
            numLab.font = [UIFont boldSystemFontOfSize:15];
            [btns addObject:numLab];
        }
        _numberBtns = [NSArray arrayWithArray:btns];
    }
    return _numberBtns;
}

@end
