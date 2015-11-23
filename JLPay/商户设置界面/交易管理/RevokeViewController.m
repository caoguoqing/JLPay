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

@interface RevokeViewController()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIButton* revokeButton;
@property (nonatomic, strong) UIImageView* imageView;

//@property (nonatomic, strong) NSMutableDictionary* detailNameIndex;
//@property (nonatomic, strong) NSMutableArray* cellNames;

@property (nonatomic, strong) NSArray* cellNamesForPOS;
@property (nonatomic, strong) NSArray* cellNamesForOtherPay;
@property (nonatomic, strong) NSDictionary* detailTransInfoForPOS;
@property (nonatomic, strong) NSDictionary* detailTransInfoForOtherPay;

@end



@implementation RevokeViewController
@synthesize dataDic = _dataDic;
//@synthesize detailNameIndex = _detailNameIndex;
@synthesize tableView = _tableView;
@synthesize revokeButton = _revokeButton;
//@synthesize cellNames = _cellNames;



- (void)viewDidLoad {
    // 第三方交易详情要去掉卡号
//    if ([self.tradePlatform isEqualToString:NameTradePlatformOtherPay]) {
//        NSInteger index = 0;
//        for (int i = 0; i < self.cellNames.count; i++) {
//            if ([[self.cellNames objectAtIndex:i] isEqualToString:@"交易卡号"]) {
//                index = i;
//            }
//        }
//        [self.cellNames removeObjectAtIndex:index];
//    }
    
    [super viewDidLoad];
    self.title = @"交易详情";
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat inset = 10;
    CGFloat naviAndStatusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.bounds.size.height;
    CGRect frame = CGRectMake(self.view.bounds.size.width/4.0,
                              inset + naviAndStatusHeight,
                              self.view.bounds.size.width/2.0,
                              self.imageView.image.size.height/self.imageView.image.size.width * self.view.bounds.size.width/2.0);
    // 商标
    [self.imageView setFrame:frame];
    
    // 表视图
    frame.origin.x = 0;
    frame.origin.y += inset + frame.size.height;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = self.view.bounds.size.height - frame.origin.y - /*inset*2.0 - buttonHeight -*/ self.tabBarController.tabBar.bounds.size.height;
    self.tableView.frame = frame;
}

#pragma mask ::: section 的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mask ::: 多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    if ([self.tradePlatform isEqualToString:NameTradePlatformMPOSSwipe]) {
        number = self.cellNamesForPOS.count;
    }
    else if ([self.tradePlatform isEqualToString:NameTradePlatformOtherPay]) {
        number = self.cellNamesForOtherPay.count;
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

    cell.textLabel.text = [self titleAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.text = [self valueAtIndex:indexPath.row];
    
    return cell;
}

#pragma mask ---- 除了撤销的cell，其他都不能高亮
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}




#pragma mask ---- 数据提取: 标题
- (NSString*) titleAtIndex:(NSInteger)index {
    NSString* title = nil;
    if ([self.tradePlatform isEqualToString:NameTradePlatformMPOSSwipe]) {
        title = [self.cellNamesForPOS objectAtIndex:index];
    }
    else if ([self.tradePlatform isEqualToString:NameTradePlatformOtherPay]) {
        title = [self.cellNamesForOtherPay objectAtIndex:index];
    }
    return title;
}
- (NSString*) keyForTitle:(NSString*)title {
    NSString* key = nil;
    if ([self.tradePlatform isEqualToString:NameTradePlatformMPOSSwipe]) {
        key = [self.detailTransInfoForPOS valueForKey:title];
    }
    else if ([self.tradePlatform isEqualToString:NameTradePlatformOtherPay]) {
        key = [self.detailTransInfoForOtherPay valueForKey:title];
    }
    return key;
}
#pragma mask ---- 数据提取: 值
- (NSString*) valueAtIndex:(NSInteger)index {
    NSString* value = nil;
    // 标题
    NSString* cellTitle = [self titleAtIndex:index];
    // 键: 标题对应的键
    NSString* key = [self keyForTitle:cellTitle];
    // 格式化需要展示的值
    if ([cellTitle isEqualToString:@"交易状态"]) {
        if ([self.tradePlatform isEqualToString:NameTradePlatformMPOSSwipe]) {
            if (![[self.dataDic objectForKey:@"cancelFlag"] isEqualToString:@"0"]) {
                value = @"已撤销";
            } else if (![[self.dataDic objectForKey:@"revsal_flag"] isEqualToString:@"0"]) {
                value = @"已冲正";
            } else {
                value = @"交易成功";
            }
        }
        else if ([self.tradePlatform isEqualToString:NameTradePlatformOtherPay]) {
            if ([[self.dataDic valueForKey:@"respCode"] intValue] == 0) {
                value = @"交易成功";
            } else {
                value = @"交易失败";
            }
        }

    } else { // 格式化数据的显示
        value = [self.dataDic valueForKey:key];
        if ([key isEqualToString:@"amtTrans"]) { // 金额
            value = [NSString stringWithFormat:@"%@ 元", [PublicInformation dotMoneyFromNoDotMoney:value]];
        }
        else if ([key isEqualToString:@"pan"]) { // 卡号
            value = [PublicInformation cuttingOffCardNo:value];
        }
        else if ([key isEqualToString:@"instDate"]) { // 交易日期
            value = [NSString stringWithFormat:@"%@/%@/%@",[value substringToIndex:4],[value substringWithRange:NSMakeRange(4, 2)],[value substringFromIndex:6]];
        }
        else if ([key isEqualToString:@"instTime"]) { // 交易时间
            value = [NSString stringWithFormat:@"%@:%@:%@",[value substringToIndex:2],[value substringWithRange:NSMakeRange(2, 2)],[value substringFromIndex:4]];
        }
        else if ([key isEqualToString:@"channelType"]) { // 渠道类型
            if ([[value substringFromIndex:1] isEqualToString:@"3"]) {
                value = @"微信";
            }
            else if ([[value substringFromIndex:1] isEqualToString:@"4"]) {
                value = @"支付宝";
            }
        }
    }
    return value;
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
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.image = [UIImage imageNamed:@"logo"];
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

#pragma mask ---- model
/* 标题数组: POS刷卡交易 */
- (NSArray *)cellNamesForPOS {
    if (_cellNamesForPOS == nil) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        [array addObject:@"交易类型"];
        [array addObject:@"商户编号"];
        [array addObject:@"商户名称"];
        [array addObject:@"交易金额"];
        [array addObject:@"交易卡号"];
        [array addObject:@"交易日期"];
        [array addObject:@"交易时间"];
        [array addObject:@"交易状态"];
        [array addObject:@"订单编号"];
        [array addObject:@"终端编号"];
        _cellNamesForPOS = [NSArray arrayWithArray:array];
    }
    return _cellNamesForPOS;
}
/* 标题数组: 第三方交易 */
- (NSArray *)cellNamesForOtherPay {
    if (_cellNamesForOtherPay == nil) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        [array addObject:@"交易类型"];
        [array addObject:@"渠道类型"];
        [array addObject:@"商户编号"];
        [array addObject:@"商户名称"];
        [array addObject:@"交易金额"];
        [array addObject:@"交易日期"];
        [array addObject:@"交易时间"];
        [array addObject:@"交易状态"];
        [array addObject:@"订单编号"];
        [array addObject:@"终端编号"];
        _cellNamesForOtherPay = [NSArray arrayWithArray:array];
    }
    return _cellNamesForOtherPay;
}

// 数据字典:保存字段描述和字段名
- (NSDictionary *) detailTransInfoForPOS {
    if (_detailTransInfoForPOS == nil) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setValue:@"txnNum" forKey:@"交易类型"];
        [dict setValue:@"cardAccpId" forKey:@"商户编号"];
        [dict setValue:@"cardAccpName" forKey:@"商户名称"];
        [dict setValue:@"amtTrans" forKey:@"交易金额"];
        [dict setValue:@"pan" forKey:@"交易卡号"];
        [dict setValue:@"instDate" forKey:@"交易日期"];
        [dict setValue:@"instTime" forKey:@"交易时间"];
        [dict setValue:@"retrivlRef" forKey:@"订单编号"];
        [dict setValue:@"cardAccpTermId" forKey:@"终端编号"];
        _detailTransInfoForPOS = [NSDictionary dictionaryWithDictionary:dict];
    }
    return _detailTransInfoForPOS;
}
- (NSDictionary *) detailTransInfoForOtherPay {
    if (_detailTransInfoForOtherPay == nil) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setValue:@"txnNum" forKey:@"交易类型"];
        [dict setValue:@"channelType" forKey:@"渠道类型"];
        [dict setValue:@"cardAccpId" forKey:@"商户编号"];
        [dict setValue:@"cardAccpName" forKey:@"商户名称"];
        [dict setValue:@"amtTrans" forKey:@"交易金额"];
        [dict setValue:@"instDate" forKey:@"交易日期"];
        [dict setValue:@"instTime" forKey:@"交易时间"];
        [dict setValue:@"sysSeqNum" forKey:@"订单编号"];
        [dict setValue:@"cardAccpTermId" forKey:@"终端编号"];
        _detailTransInfoForOtherPay = [NSDictionary dictionaryWithDictionary:dict];
    }
    return _detailTransInfoForOtherPay;
}



//- (NSMutableArray *)cellNames {
//    if (_cellNames == nil) {
//        _cellNames = [[NSMutableArray alloc] init];
//        [_cellNames addObject:@"交易类型"];
//        [_cellNames addObject:@"商户编号"];
//        [_cellNames addObject:@"商户名称"];
//        [_cellNames addObject:@"交易金额"];
//        [_cellNames addObject:@"交易卡号"];
//        [_cellNames addObject:@"交易日期"];
//        [_cellNames addObject:@"交易时间"];
//        [_cellNames addObject:@"交易状态"];
//        [_cellNames addObject:@"订单编号"];
//        [_cellNames addObject:@"终端编号"];
//    }
//    return _cellNames;
//}
// 数据字典:保存字段描述和字段名
//- (NSDictionary *)detailNameIndex {
//    if (_detailNameIndex == nil) {
//        _detailNameIndex = [[NSMutableDictionary alloc] init];
//        [_detailNameIndex setValue:@"txnNum" forKey:@"交易类型"];
//        [_detailNameIndex setValue:@"cardAccpId" forKey:@"商户编号"];
//        [_detailNameIndex setValue:@"cardAccpName" forKey:@"商户名称"];
//        [_detailNameIndex setValue:@"amtTrans" forKey:@"交易金额"];
//        [_detailNameIndex setValue:@"pan" forKey:@"交易卡号"];
//        [_detailNameIndex setValue:@"instDate" forKey:@"交易日期"];
//        [_detailNameIndex setValue:@"instTime" forKey:@"交易时间"];
//        [_detailNameIndex setValue:@"retrivlRef" forKey:@"订单编号"];
//        [_detailNameIndex setValue:@"cardAccpTermId" forKey:@"终端编号"];
//    }
//    return _detailNameIndex;
//}

@end
