//
//  RateViewController.m
//  JLPay
//
//  Created by jielian on 15/7/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "RateViewController.h"
#import "PublicInformation.h"
#import "Define_Header.h"


@interface RateViewController()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIButton* sureButton;
@property (nonatomic, strong) NSMutableDictionary* rateDic;
@property (nonatomic, strong) NSString* selectedRate;
@property (nonatomic, strong) NSMutableArray* rateNameArray;
@end

@implementation RateViewController
@synthesize tableView = _tableView;
@synthesize sureButton = _sureButton;
@synthesize rateDic = _rateDic;
@synthesize selectedRate = _selectedRate;
@synthesize rateNameArray = _rateNameArray;

#pragma mask --- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rateNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseIdentifier = @"reuseIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.text = [self.rateNameArray objectAtIndex:indexPath.row];

    if ([[self.rateDic valueForKey:cell.textLabel.text] isEqualToString:self.selectedRate]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}
#pragma mask --- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedRate = [self.rateDic valueForKey:cell.textLabel.text];
    // 去掉其他已标记的cell
    for (int i = 0; i < [self.tableView numberOfRowsInSection:indexPath.section]; i++) {
        UITableViewCell* innerCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        if (![cell.textLabel.text isEqualToString:innerCell.textLabel.text] &&
            innerCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            innerCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}


#pragma mask --- 按钮事件
- (IBAction) touchDown:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformMakeScale(0.95, 0.95);
}
- (IBAction) touchUpOutSide:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformIdentity;

}
- (IBAction) touchToSaveRate:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformIdentity;

    NSString* rate = [[NSUserDefaults standardUserDefaults] valueForKey:Key_RateOfPay];
    if (![rate isEqualToString:self.selectedRate]) {
        [[NSUserDefaults standardUserDefaults] setValue:self.selectedRate forKey:Key_RateOfPay];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        [self.navigationController popViewControllerAnimated:YES];
    } completion:nil];
}




#pragma mask --- 视图控制部分
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"费率选择";
    [self.view addSubview:self.tableView];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.sureButton];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat inset = 15;
    CGFloat buttonHeight =  50;
    CGFloat statusHeight = [PublicInformation returnStatusHeight];
    CGFloat navigationHeight = self.navigationController.navigationBar.bounds.size.height;
    
    CGRect frame = CGRectMake(0,
                              0,
                              self.view.frame.size.width,
                              self.view.frame.size.height - statusHeight - navigationHeight - buttonHeight - inset*2);
    self.tableView.frame = frame;
    
    frame.origin.y += frame.size.height + inset;
    frame.size.height = buttonHeight;
    self.sureButton.frame = frame;
    self.sureButton.layer.cornerRadius = self.sureButton.frame.size.height/2.0;
    self.sureButton.layer.masksToBounds = YES;
    
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mask --- getter & setter 
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView setTableFooterView:view];
        [_tableView setDelegate:self];
    }
    return _tableView;
}
- (UIButton *)sureButton {
    if (_sureButton == nil) {
        _sureButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_sureButton setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [_sureButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_sureButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchDown];
        [_sureButton addTarget:self action:@selector(touchToSaveRate:) forControlEvents:UIControlEventTouchDown];

    }
    return _sureButton;
}
- (NSDictionary *)rateDic {
    if (_rateDic == nil) {
        _rateDic = [[NSMutableDictionary alloc] init];
        [_rateDic setValue:@"0" forKey:@"通用/默认"];
        [_rateDic setValue:@"1" forKey:@"费率 0.78 不封顶"];
        [_rateDic setValue:@"2" forKey:@"费率 0.78 35封顶"];
        [_rateDic setValue:@"3" forKey:@"费率 1.25 不封顶"];
    }
    return _rateDic;
}
- (NSMutableArray *)rateNameArray {
    if (_rateNameArray == nil) {
        _rateNameArray = [[NSMutableArray alloc] init];
        [_rateNameArray addObject:@"通用/默认"];    //
        [_rateNameArray addObject:@"费率 0.78 不封顶"];
        [_rateNameArray addObject:@"费率 0.78 35封顶"];
        [_rateNameArray addObject:@"费率 1.25 不封顶"];
    }
    return _rateNameArray;
}

- (NSString *)selectedRate {
    if (_selectedRate == nil) {
        _selectedRate = [[NSUserDefaults standardUserDefaults] valueForKey:Key_RateOfPay];
        if (_selectedRate == nil || [_selectedRate isEqualToString:@""]) {
            _selectedRate = @"0";
        }
    }
    return _selectedRate;
}




@end
