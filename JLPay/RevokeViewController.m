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

@interface RevokeViewController()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableDictionary* detailNameIndex;
@property (nonatomic, strong) NSMutableArray* cellNames;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIButton* revokeButton;
@end


#define CELL_LEFT_INSET             30.0

@implementation RevokeViewController
@synthesize dataDic = _dataDic;
@synthesize detailNameIndex = _detailNameIndex;
@synthesize tableView = _tableView;
@synthesize revokeButton = _revokeButton;
@synthesize cellNames = _cellNames;



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"交易详情";
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.revokeButton];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat inset = 10;
    CGFloat buttonHeight = 45;
    CGFloat naviAndStatusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.bounds.size.height;
    UIImage* image = [UIImage imageNamed:@"logo"];
    CGRect frame = CGRectMake(self.view.bounds.size.width/4.0,
                              inset + naviAndStatusHeight,
                              self.view.bounds.size.width/2.0,
                              image.size.height/image.size.width * self.view.bounds.size.width/2.0);
    // 商标
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = image;
    [self.view addSubview:imageView];
    // 表视图
    frame.origin.x = 0;
    frame.origin.y += inset + frame.size.height;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = self.view.bounds.size.height - frame.origin.y - inset*2.0 - buttonHeight - self.tabBarController.tabBar.bounds.size.height;
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    self.tableView.frame = frame;
    // 撤销按钮
    frame.origin.y += frame.size.height + inset;
    frame.size.height = buttonHeight;
    self.revokeButton.frame = frame;
    self.revokeButton.enabled = NO;
    if ([[_dataDic objectForKey:@"txnNum"] isEqualToString:@"消费"] &&
        [[_dataDic objectForKey:@"cancelFlag"] isEqualToString:@"0"] &&
        [[_dataDic objectForKey:@"revsal_flag"] isEqualToString:@"0"]) {
        self.revokeButton.enabled = YES;
    }
    NSLog(@"明细:[%@]",_dataDic);
}



#pragma mask ::: section 的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mask ::: 多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellNames.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

#pragma mask ::: cell 的重用及加载
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifier = @"detailsCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
    cell.frame = frame;
    [self loadDetailCell:cell atIndexPath: indexPath];
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
        NSString* amount = [self.dataDic objectForKey:@"amtTrans"];
        // 保存原始消费金额
        [[NSUserDefaults standardUserDefaults] setValue:amount forKey:SuccessConsumerMoney];
        CGFloat money = [amount floatValue]/100.0;
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%.02f", money] forKey:Consumer_Money];
        // 保存原消费流水号
        [[NSUserDefaults standardUserDefaults] setValue:[self.dataDic objectForKey:@"retrivlRef"] forKey:Consumer_Get_Sort];
        // 保存原消费批次号 用于撤销报文的61.1域
        [[NSUserDefaults standardUserDefaults] setValue:[self.dataDic objectForKey:@"fldReserved"] forKey:Last_FldReserved_Number];
        // 保存原消费系统流水号;用于撤销报文的61.2域 Last_Exchange_Number
        [[NSUserDefaults standardUserDefaults] setValue:[self.dataDic objectForKey:@"sysSeqNum"] forKey:Last_Exchange_Number];
        // 注册交易类型到本地配置
        [[NSUserDefaults standardUserDefaults] setValue:TranType_ConsumeRepeal forKey:TranType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // 切换到刷卡界面
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BrushViewController *viewcon = [storyboard instantiateViewControllerWithIdentifier:@"brush"];
        [self.navigationController pushViewController:viewcon animated:YES];
    }
}


#pragma mask ::: 加载明细详情单元格
- (void) loadDetailCell: (UITableViewCell*)cell atIndexPath: (NSIndexPath*)indexPath{
    CGFloat leftWidth = cell.bounds.size.width / 4.0;
    NSString* cellName = [self.cellNames objectAtIndex:indexPath.row];
    // key
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(CELL_LEFT_INSET, 0, leftWidth, cell.bounds.size.height)];
    label.text = cellName;
    [cell addSubview:label];
    
    // value
    label = [[UILabel alloc] initWithFrame:CGRectMake(CELL_LEFT_INSET + leftWidth + CELL_LEFT_INSET/2.0,
                                                      0,
                                                      cell.bounds.size.width - leftWidth - CELL_LEFT_INSET*2.0,
                                                      cell.bounds.size.height)];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textColor = [UIColor colorWithRed:82.0/255.0 green:82.0/255.0 blue:82.0/255.0 alpha:1.0];
    // 特定值
    NSString* key = [self.detailNameIndex objectForKey:cellName];
    if (key == nil) {
        if ([cellName isEqualToString:@"交易状态"]) {
            if (![[self.dataDic objectForKey:@"cancelFlag"] isEqualToString:@"0"]) {
                label.text = @"已撤销";
                label.textColor = [UIColor redColor];
            } else if (![[self.dataDic objectForKey:@"revsal_flag"] isEqualToString:@"0"]) {
                label.text = @"已冲正";
                label.textColor = [UIColor redColor];
            } else {
                label.text = @"交易成功";
            }
        }
    } else {
        if ([key isEqualToString:@"amtTrans"]) { // 金额
            NSString* amount = [self.dataDic objectForKey:key];
            CGFloat fAmount = [amount floatValue]/100.0;
            label.text = [NSString stringWithFormat:@"%.02f", fAmount];
        } else if ([key isEqualToString:@"pan"]) { // 卡号
            NSString* cardNo = [self.dataDic objectForKey:key];
            label.text = [NSString stringWithFormat:@"%@******%@",
                          [cardNo substringToIndex:6],
                          [cardNo substringFromIndex:[cardNo length] - 1 - 4]];
        }
        else {
            label.text = [self.dataDic objectForKey:key];
            if ([key isEqualToString:@"txnNum"] && ![label.text isEqualToString:@"消费"]) {
                label.textColor = [UIColor redColor];
            }
        }
    }
    
    [cell addSubview:label];
}




#pragma mask ::: getter & setter
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
        [_tableView setTableFooterView:view];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return _tableView;
}
- (UIButton *)revokeButton {
    if (_revokeButton == nil) {
        _revokeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_revokeButton setTitle:@"撤销" forState:UIControlStateNormal];
        [_revokeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_revokeButton setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        _revokeButton.layer.cornerRadius = 8.0;
        _revokeButton.layer.masksToBounds = YES;
        [_revokeButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_revokeButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_revokeButton addTarget:self action:@selector(touchToRequreRevoke:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _revokeButton;
}
- (NSMutableArray *)cellNames {
    if (_cellNames == nil) {
        _cellNames = [[NSMutableArray alloc] init];
        [_cellNames addObject:@"交易类型"];
        [_cellNames addObject:@"交易金额"];
        [_cellNames addObject:@"交易卡号"];
        [_cellNames addObject:@"交易时间"];
        [_cellNames addObject:@"交易状态"];
        [_cellNames addObject:@"订单编号"];
        [_cellNames addObject:@"商户编号"];
        [_cellNames addObject:@"终端编号"];
    }
    return _cellNames;
}
// 数据字典:保存字段描述和字段名
- (NSDictionary *)detailNameIndex {
    if (_detailNameIndex == nil) {
        _detailNameIndex = [[NSMutableDictionary alloc] init];
        [_detailNameIndex setValue:@"txnNum" forKey:@"交易类型"];
        [_detailNameIndex setValue:@"cardAccpId" forKey:@"商户编号"];
        [_detailNameIndex setValue:@"retrivlRef" forKey:@"订单编号"];
        [_detailNameIndex setValue:@"cardAccpTermId" forKey:@"终端编号"];
        [_detailNameIndex setValue:@"pan" forKey:@"交易卡号"];
        [_detailNameIndex setValue:@"instTime" forKey:@"交易时间"];
        [_detailNameIndex setValue:@"amtTrans" forKey:@"交易金额"];
    }
    return _detailNameIndex;
}

@end
