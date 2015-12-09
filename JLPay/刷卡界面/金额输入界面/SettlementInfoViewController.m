//
//  SettlementInfoViewController.m
//  JLPay
//
//  Created by jielian on 15/12/7.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "SettlementInfoViewController.h"
#import "HTTPRequestSettlementInfo.h"
#import "PublicInformation.h"

@interface SettlementInfoViewController()
<UITableViewDataSource, UITableViewDelegate>
{
    NSArray* keysOfCells;
    NSDictionary* titlesForKeys;
}


@end


@implementation SettlementInfoViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        keysOfCells = @[@"sFloatMoney",
                        kSettleInfoNameAmountLimit,
                        kSettleInfoNameAmountAvilable,
                        kSettleInfoNameMinCustAmount,
                        kSettleInfoNameT_0_Fee];
        titlesForKeys = @{@"sFloatMoney":@"刷卡金额:",
                          kSettleInfoNameAmountLimit:@"T+0单日限额:",
                          kSettleInfoNameAmountAvilable:@"T+0当日可刷额度:",
                          kSettleInfoNameMinCustAmount:@"T+0最小刷卡限额:",
                          kSettleInfoNameT_0_Fee:@"T+0增加费率:"
                          };
        
        self.title = @"结算信息";
        self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    }
    return self;
}

#pragma mask ---- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return keysOfCells.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cellIdentifier__";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    NSString* keyOfCell = [keysOfCells objectAtIndex:indexPath.row];
    NSString* titleOfCell = [titlesForKeys objectForKey:keyOfCell];
    
    cell.textLabel.text = titleOfCell;
    
    // 刷卡金额
    if ([keyOfCell isEqualToString:@"sFloatMoney"]) {
        cell.detailTextLabel.text = [self valueForKey:keyOfCell];
    }
    // 费率
    else if ([keyOfCell isEqualToString:kSettleInfoNameT_0_Fee]) {
        cell.detailTextLabel.text = [self formatFee:[self.settlementInformation valueForKey:kSettleInfoNameT_0_Fee]];
    }
    // 各种限额
    else {
        cell.detailTextLabel.text = [self.settlementInformation valueForKey:keyOfCell];
    }
    return cell;
}


/* 格式化: 费率 */
- (NSString*) formatFee:(NSString*)fee {
    return [NSString stringWithFormat:@"+%@%%",fee];
}


#pragma mask ---- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 100;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIButton* nextStepButton = [[UIButton alloc] initWithFrame:CGRectZero];
    CGRect frame = [tableView rectForFooterInSection:section];
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [view addSubview:nextStepButton];
    
    CGFloat inset = 20;
    nextStepButton.bounds = CGRectMake(0, 0, frame.size.width - inset*2, 50);
    nextStepButton.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
    nextStepButton.backgroundColor = [PublicInformation returnCommonAppColor:@"red"];
    [nextStepButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextStepButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextStepButton.layer.cornerRadius = 8.0;
    return view;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}




@end
