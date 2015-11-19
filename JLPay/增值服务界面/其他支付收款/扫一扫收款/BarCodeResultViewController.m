//
//  BarCodeResultViewController.m
//  JLPay
//
//  Created by jielian on 15/11/9.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "BarCodeResultViewController.h"
#import "PublicInformation.h"

@interface BarCodeResultViewController()
{
    UIColor* curGreenColor;
}
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
    self.tabBarController.tabBar.hidden = NO;

    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mask ---- 界面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"收款结果";
    curGreenColor = [PublicInformation returnCommonAppColor:@"green"];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.labelResult];
    [self.view addSubview:self.labelMoney];
    [self.view addSubview:self.buttonDone];
    
    [self layoutSubviewsAll];
    [self.navigationItem setHidesBackButton:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}
- (void) layoutSubviewsAll {
    CGFloat heightStates = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat heightNavi = self.navigationController.navigationBar.frame.size.height;
    CGFloat widthImageView = 60;
    CGFloat heightLabelResult = 30;
    CGFloat heightButton = 45;
    CGFloat inset = 15;
    
    CGRect frame = CGRectMake((self.view.frame.size.width - widthImageView)/2.0,
                              heightStates + heightNavi*2,
                              widthImageView,
                              widthImageView);
    [self.imageView setFrame:frame];
    
    frame.origin.y += frame.size.height + inset;
    frame.origin.x = 0;
    frame.size.width = self.view.frame.size.width;
    frame.size.height = heightLabelResult;
    [self.labelResult setFrame:frame];
    
    frame.origin.y += frame.size.height + inset;
    [self.labelMoney setFrame:frame];
    
    frame.origin.y += frame.size.height + inset;
    frame.origin.x = inset;
    frame.size.width = self.view.frame.size.width - inset*2;
    frame.size.height = heightButton;
    [self.buttonDone setFrame:frame];
    
}

#pragma mask ---- getter
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        if (self.result) {
            _imageView.image = [UIImage imageNamed:@"paySuccess1"];
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
            _labelResult.textColor = curGreenColor;
        } else {
            [displayText appendString:@"失败"];
            _labelResult.textColor = [UIColor redColor];

        }
        _labelResult.font = [UIFont systemFontOfSize:20];
        _labelResult.text = displayText;
        _labelResult.textAlignment = NSTextAlignmentCenter;
    }
    return _labelResult;
}
- (UIButton *)buttonDone {
    if (_buttonDone == nil) {
        _buttonDone = [[UIButton alloc] initWithFrame:CGRectZero];
        [_buttonDone setTitle:@"完成" forState:UIControlStateNormal];
        [_buttonDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _buttonDone.backgroundColor = curGreenColor;
        _buttonDone.layer.cornerRadius = 5.0;
        
        [_buttonDone addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_buttonDone addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpOutside];
        [_buttonDone addTarget:self action:@selector(touchToBackVC:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _buttonDone;
}


@end
