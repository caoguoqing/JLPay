//
//  RevokeViewController.m
//  JLPay
//
//  Created by jielian on 15/6/11.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "RevokeViewController.h"
#import "Define_Header.h"
#import "BrushViewController.h"
#import "DeviceManager.h"
#import "DetailsCell.h"
#import "TransDetailsViewController.h"
#import "Packing8583.h"
#import "ViewModelMPOSDetails.h"
#import "ViewModelOtherPayDetails.h"

@interface RevokeViewController()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIButton* revokeButton;
@property (nonatomic, strong) UIImageView* imageView;


@end



@implementation RevokeViewController
@synthesize dataDic = _dataDic;
@synthesize tableView = _tableView;
@synthesize revokeButton = _revokeButton;



- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"交易详情";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.imageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat naviAndStatusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.bounds.size.height;
    CGRect frame = CGRectMake(0,
                              naviAndStatusHeight,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height - naviAndStatusHeight - self.tabBarController.tabBar.bounds.size.height);
    self.tableView.frame = frame;
    self.tableView.contentInset = UIEdgeInsetsMake(self.imageView.frame.size.height + 30, 0, 0, 0);
    self.tableView.contentOffset = CGPointMake(0, -30 - self.imageView.frame.size.height);
}

#pragma mask ::: section 的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mask ::: 多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    if ([self.tradePlatform isEqualToString:NameTradePlatformMPOSSwipe]) {
        number = [ViewModelMPOSDetails titlesNeedDisplayedForNode:self.dataDic].count;
    }
    else if ([self.tradePlatform isEqualToString:NameTradePlatformOtherPay]) {
        number = [ViewModelOtherPayDetails titlesNeedDisplayedForNode:self.dataDic].count;
    }
    return number;
}

#pragma mask ::: 高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

#pragma mask ::: cell 的重用及加载
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifier = @"detailsCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }

    if ([self.tradePlatform isEqualToString:NameTradePlatformMPOSSwipe]) {
        [cell.textLabel setText:[[ViewModelMPOSDetails titlesNeedDisplayedForNode:self.dataDic] objectAtIndex:indexPath.row]];
        [cell.detailTextLabel setText:[ViewModelMPOSDetails valueForTitleNeedDisplayed:cell.textLabel.text ofNode:self.dataDic]];
    }
    else if ([self.tradePlatform isEqualToString:NameTradePlatformOtherPay]) {
        [cell.textLabel setText:[[ViewModelOtherPayDetails titlesNeedDisplayedForNode:self.dataDic] objectAtIndex:indexPath.row]];
        [cell.detailTextLabel setText:[ViewModelOtherPayDetails valueForTitleNeedDisplayed:cell.textLabel.text ofNode:self.dataDic]];
    }
    
    return cell;
}

#pragma mask ---- 除了撤销的cell，其他都不能高亮
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}





#pragma mask ---- RevokeButton 的点击事件
- (IBAction) touchDown:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        UIButton* button = (UIButton*)sender;
        button.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }];
}
- (IBAction) touchUpOutSide:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        UIButton* button = (UIButton*)sender;
        button.transform = CGAffineTransformIdentity;
    }];

}
- (IBAction) touchToRequreRevoke:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        UIButton* button = (UIButton*)sender;
        button.transform = CGAffineTransformIdentity;
    }];
    // 撤销代码 -- 发起撤销前，要弹窗提示商户是否确定要撤销
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"是否发起撤销?" message:nil delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [alert show];
}


// 撤销弹窗提示的点击事件 -- 确定撤销或否定
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {     // 否:不撤销
        
    } else {                    // 是:撤销
        // 返回的金额已经是无小数点的金额串12位
        [[NSUserDefaults standardUserDefaults] setValue:TranType_ConsumeRepeal forKey:TranType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // 切换到刷卡界面
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BrushViewController *viewcon = [storyboard instantiateViewControllerWithIdentifier:@"brush"];
        [self.navigationController pushViewController:viewcon animated:YES];
    }
}


#pragma mask ::: getter & setter
- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImage* image = [PublicInformation logoImageOfApp];
        CGFloat imageWidth = self.view.frame.size.width/2.f;
        CGFloat imageHeight = imageWidth * image.size.height/image.size.width;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - imageWidth)/2.f, - imageHeight - 15, imageWidth, imageHeight)];
        _imageView.image = image;
    }
    return _imageView;
}
// 保存单条明细记录数据
- (NSDictionary *)dataDic {
    if (_dataDic == nil) {
        _dataDic = [[NSDictionary alloc] init];
    }
    return _dataDic;
}
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.layer.borderWidth = 0.5;
        _tableView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        [_tableView setTableFooterView:view];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];

        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return _tableView;
}
- (UIButton *)revokeButton {
    if (_revokeButton == nil) {
        _revokeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_revokeButton setTitle:@"撤销" forState:UIControlStateNormal];
        [_revokeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_revokeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_revokeButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_revokeButton setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        _revokeButton.layer.cornerRadius = 8.0;
        _revokeButton.layer.masksToBounds = YES;
        [_revokeButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_revokeButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_revokeButton addTarget:self action:@selector(touchToRequreRevoke:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _revokeButton;
}


@end
