//
//  TestCheckViewController.m
//  CustomViewMaker
//
//  Created by jielian on 16/3/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "TestCheckViewController.h"
#import "ConcentricCirclesCheckView.h"
#import "Masonry.h"

@interface TestCheckViewController()

@property (nonatomic, strong) ConcentricCirclesCheckView* checkView;
@property (nonatomic, strong) UIButton* checkOn;
@property (nonatomic, strong) UIButton* checkOff;


@end

@implementation TestCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addSubviews];
    [self relayoutSubviews];
}
- (void) addSubviews {
    [self.view addSubview:self.checkView];
    [self.view addSubview:self.checkOn];
    [self.view addSubview:self.checkOff];
}
- (void) relayoutSubviews {
    CGFloat widthButton = 100;
    CGFloat heightButton = 35;
    CGFloat widthCheckView = 30;
    __weak typeof(self)wself = self;

    [self.checkOn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(widthButton, heightButton));
        make.right.equalTo(wself.view.mas_centerX);
        make.top.equalTo(wself.view.mas_top).offset(64 + 30);
    }];
    
    [self.checkOff mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(wself.checkOn);
        make.top.equalTo(wself.checkOn.mas_top);
        make.left.equalTo(wself.checkOn.mas_right);
    }];
    
    [self.checkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(widthCheckView, widthCheckView));
        make.centerX.equalTo(wself.view.mas_centerX);
        make.centerY.equalTo(wself.view.mas_centerY);
    }];

}


#pragma mask 2 IBAction
- (IBAction) clickToCheckOn:(UIButton*)sender {
    self.checkView.checked = YES;
}
- (IBAction) clickToCheckOff:(UIButton*)sender {
    self.checkView.checked = NO;
}

#pragma mask 4 getter 
- (ConcentricCirclesCheckView *)checkView {
    if (!_checkView) {
        _checkView = [[ConcentricCirclesCheckView alloc] init];
        _checkView.tintColor = [UIColor blackColor];
        _checkView.lineWidth = 3.f;
    }
    return _checkView;
}
- (UIButton *)checkOn {
    if (!_checkOn) {
        _checkOn = [UIButton new];
        [_checkOn setTitle:@"checkOn" forState:UIControlStateNormal];
        [_checkOn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_checkOn addTarget:self action:@selector(clickToCheckOn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkOn;
}
- (UIButton *)checkOff {
    if (!_checkOff) {
        _checkOff = [UIButton new];
        [_checkOff setTitle:@"checkOff" forState:UIControlStateNormal];
        [_checkOff setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_checkOff addTarget:self action:@selector(clickToCheckOff:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkOff;
}


@end
