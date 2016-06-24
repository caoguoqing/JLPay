//
//  TransDetailInfoViewController.m
//  JLPay
//
//  Created by jielian on 16/5/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "TransDetailInfoViewController.h"

@implementation TransDetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    self.title = @"交易详情";
    [self addSubviews];
    [self layoutSubviews];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void) addSubviews {
    [self.infoTableView addSubview:self.logoImgView];
    [self.view addSubview:self.infoTableView];
}

- (void) layoutSubviews {
    NameWeakSelf(wself);
    [self.infoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.view.mas_bottom);
    }];
    CGFloat widthImage = self.view.frame.size.width * 0.5;
    CGFloat heightImage = self.logoImgView.image.size.height/self.logoImgView.image.size.width * widthImage;
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(wself.infoTableView.mas_top).offset(-10);
        make.centerX.equalTo(wself.infoTableView.mas_centerX);
        make.width.mas_equalTo(widthImage);
        make.height.mas_equalTo(heightImage);
        wself.infoTableView.contentInset = UIEdgeInsetsMake(heightImage + 20, 0, 0, 0);
    }];
}

# pragma mask 4 getter
- (UITableView *)infoTableView {
    if (!_infoTableView) {
        _infoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _infoTableView.delegate = self.dataSource;
        _infoTableView.dataSource = self.dataSource;
        _infoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _infoTableView;
}

- (UIImageView *)logoImgView {
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc] initWithImage:[PublicInformation logoImageOfApp]];
    }
    return _logoImgView;
}
- (id)dataSource {
    if (!_dataSource) {
        if ([self.platform isEqualToString:TransPlatformTypeSwipe]) {
            _dataSource = [[VMMposDetailInfo alloc] init];
        } else {
            _dataSource = [[VMOtherPayDetailInfo alloc] init];
        }
    }
    return _dataSource;
}


@end
