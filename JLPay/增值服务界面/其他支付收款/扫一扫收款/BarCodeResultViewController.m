//
//  BarCodeResultViewController.m
//  JLPay
//
//  Created by jielian on 15/11/9.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "BarCodeResultViewController.h"

@interface BarCodeResultViewController()

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* labelResult;
@property (nonatomic, strong) UILabel* labelMoney;
@property (nonatomic, strong) UIButton* buttonDone;

@end

@implementation BarCodeResultViewController

#pragma mask ---- 按钮事件
- (IBAction) touchDown:(UIButton*)sender {
    sender.transform = CGAffineTransformMakeScale(0.95, 0.95);
}
- (IBAction) touchOut:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
}
- (IBAction) touchToBackVC:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
}

#pragma mask ---- 界面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.labelResult];
    [self.view addSubview:self.labelMoney];
    [self.view addSubview:self.buttonDone];
}

#pragma mask ---- getter
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        if (self.result) {
            _imageView.image = [UIImage imageNamed:@"paySuccess"];
        } else {
            _imageView.image = [UIImage imageNamed:@"payFail"];
        }
    }
    return _imageView;
}
- (UILabel *)labelMoney {
    if (_labelMoney == nil) {
        _labelMoney = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelMoney.textColor = [UIColor blackColor];
        _labelMoney.textAlignment = NSTextAlignmentCenter;
        _labelMoney.font = [UIFont systemFontOfSize:30];
        _labelMoney.text = [NSString stringWithFormat:@"￥%@",self.money];
    }
    return _labelMoney;
}
- (UILabel *)labelResult {
    if (_labelResult == nil) {
        _labelResult = [[UILabel alloc] initWithFrame:CGRectZero];
        NSMutableString* displayText = [[NSMutableString alloc] initWithString:self.payCollectType];
        if (self.result) {
            [displayText appendString:@"成功"];
        } else {
            [displayText appendString:@"失败"];
        }
        _labelResult.text = displayText;
    }
    return _labelResult;
}
- (UIButton *)buttonDone {
    if (_buttonDone == nil) {
        _buttonDone = [[UIButton alloc] initWithFrame:CGRectZero];
        [_buttonDone setTitle:@"完成" forState:UIControlStateNormal];
        [_buttonDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _buttonDone.backgroundColor = [UIColor greenColor];
        
    }
    return _buttonDone;
}


@end
