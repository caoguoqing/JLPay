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

@interface RevokeViewController()<UIAlertViewDelegate>
@property (nonatomic, strong) NSDictionary* detailNameIndex;
@end


#define CELL_LEFT_INSET             30.0

@implementation RevokeViewController
@synthesize dataDic = _dataDic;
@synthesize detailNameIndex = _detailNameIndex;



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"交易详情";
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
}



#pragma mask ::: section 的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mask ::: 多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.detailNameIndex allKeys].count + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 60;
    }
    return 40;
}

#pragma mask ::: cell 的重用及加载
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        // 商标
        cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
        cell.frame = frame;
        [self loadTitleCell:cell];
    } else if (indexPath.row == [tableView numberOfRowsInSection:0] - 1) {
        // 撤销单元格
        cell = [tableView dequeueReusableCellWithIdentifier:@"revokeCell"];
        cell.frame = frame;
        [self loadRevokeCell:cell];
    } else {
        // 明细单元格
        cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
        cell.frame = frame;
        [self loadDetailCell:cell atIndexPath: indexPath];
    }
    return cell;
}


#pragma mask ---- 除了撤销的cell，其他都不能高亮
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        return YES;
    }
    return NO;
}

#pragma mask ---- 点击撤销单元格:执行撤销
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {    // 撤销单元格
        cell.selected = NO;
        
        // 撤销代码 -- 发起撤销前，要弹窗提示商户是否确定要撤销
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"是否发起撤销?" message:nil delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        // 可撤销状态时，才能响应点击事件
        if (![[self.dataDic objectForKey:@"cancelFlag"] isEqualToString:@"1"] &&
            ![[self.dataDic objectForKey:@"revsal_flag"] isEqualToString:@"1"]) {
            [alert show];
        }
    }
}

// 撤销弹窗提示的点击事件 -- 确定撤销或否定
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {     // 否:不撤销
        
    } else {                    // 是:撤销
        // 返回的金额已经是无小数点的金额串12位
        NSString* amount = [self.dataDic objectForKey:@"amtTrans"];
        // 保存原始消费金额
        [[NSUserDefaults standardUserDefaults] setValue:amount forKey:SuccessConsumerMoney];
        // 保存原消费流水号
        [[NSUserDefaults standardUserDefaults] setValue:[self.dataDic objectForKey:@"retrivlRef"] forKey:Consumer_Get_Sort];
        // 切换到刷卡界面
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BrushViewController *viewcon = [storyboard instantiateViewControllerWithIdentifier:@"brush"];
        // 保存原消费签到批次号;用于撤销报文的61.1域 Last_FldReserved_Number   Last_FldReserved_Number
        [[NSUserDefaults standardUserDefaults] setValue:[self.dataDic objectForKey:@"fldReserved"] forKey:Last_FldReserved_Number];
        // 保存原消费系统流水号;用于撤销报文的61.2域 Last_Exchange_Number
        [[NSUserDefaults standardUserDefaults] setValue:[self.dataDic objectForKey:@"sysSeqNum"] forKey:Last_Exchange_Number]; //retrivlRef sysSeqNum
        // 设置交易类型:消费撤销
        viewcon.stringOfTranType = TranType_ConsumeRepeal;
        // 注册交易类型到本地配置
        [[NSUserDefaults standardUserDefaults] setValue:TranType_ConsumeRepeal forKey:TranType];
        [self.navigationController pushViewController:viewcon animated:YES];
    }
}



#pragma mask ::: 加载标题单元格
- (void) loadTitleCell: (UITableViewCell*)cell {
    CGFloat inset = 9.0;
    CGFloat height = cell.bounds.size.height - inset * 2;
    CGFloat width = 3.0 * height;
    CGRect frame  = CGRectMake((cell.bounds.size.width - width)/2.0, inset, width, height);
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [UIImage imageNamed:@"logo"];
    
    [cell addSubview:imageView];
}

#pragma mask ::: 加载明细详情单元格
- (void) loadDetailCell: (UITableViewCell*)cell atIndexPath: (NSIndexPath*)indexPath{
    CGFloat leftWidth = cell.bounds.size.width / 4.0;
    
    // key
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(CELL_LEFT_INSET, 0, leftWidth, cell.bounds.size.height)];
    label.text = [[self.detailNameIndex allKeys] objectAtIndex:indexPath.row - 1];
    [cell addSubview:label];
    NSString* key = [self.detailNameIndex objectForKey:label.text];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(CELL_LEFT_INSET + leftWidth + CELL_LEFT_INSET/2.0,
                                                      0,
                                                      cell.bounds.size.width - leftWidth - CELL_LEFT_INSET*2.0,
                                                      cell.bounds.size.height)];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textColor = [UIColor colorWithRed:82.0/255.0 green:82.0/255.0 blue:82.0/255.0 alpha:1.0];
    // 值
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
    }
    [cell addSubview:label];
}

#pragma mask ::: 加载撤销按钮的单元格
- (void) loadRevokeCell: (UITableViewCell*)cell {
    CGFloat leftWidth = cell.bounds.size.width / 4.0;
    CGFloat width = 40.0;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(CELL_LEFT_INSET,
                                                               0,
                                                               leftWidth,
                                                               cell.bounds.size.height)];
    label.text = @"是否撤销";
    [cell addSubview:label];
    
    // button
    width *= 2.0;
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(CELL_LEFT_INSET + leftWidth + CELL_LEFT_INSET/2.0,
                                                                  5,
                                                                  width,
                                                                  cell.bounds.size.height - 10)];
    button.layer.cornerRadius = 3.0;
    
    // 检查交易是否能被撤销
    if (![[self.dataDic objectForKey:@"cancelFlag"] isEqualToString:@"1"] &&
        ![[self.dataDic objectForKey:@"revsal_flag"] isEqualToString:@"1"]) {
        // 可撤销
        button.backgroundColor = [UIColor colorWithRed:100.0/255.0 green:193.0/255.0 blue:35.0/255.0 alpha:1];
        [button setTitle:@"未撤销" forState:UIControlStateNormal];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [button setEnabled:YES];
    } else {
        // 不可撤销
        [button setEnabled:NO];
        button.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:58.0/255.0 blue:66.0/255.0 alpha:1];
        [button setTitle:@"已撤销" forState:UIControlStateNormal];
    }
    
    [cell addSubview:button];
}



#pragma mask ::: getter & setter
// 保存单条明细记录数据
- (NSDictionary *)dataDic {
    if (_dataDic == nil) {
        _dataDic = [[NSDictionary alloc] init];
    }
    return _dataDic;
}
// 数据字典:保存字段描述和字段名
- (NSDictionary *)detailNameIndex {
    if (_detailNameIndex == nil) {
        NSArray* keys = [NSArray arrayWithObjects:
                         @"商户编号",
                         @"订单编号",
                         @"终端编号",
                         @"交易卡号",
                         @"交易时间",
                         @"交易金额", nil];
        NSArray* objects    = [NSArray arrayWithObjects:
                               @"cardAccpId",
                               @"retrivlRef",
                               @"cardAccpTermId",
                               @"pan",
                               @"instTime",
                               @"amtTrans", nil];
        _detailNameIndex = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    }
    return _detailNameIndex;
}

@end
