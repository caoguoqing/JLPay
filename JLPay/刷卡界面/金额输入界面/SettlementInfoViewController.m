//
//  SettlementInfoViewController.m
//  JLPay
//
//  Created by jielian on 15/12/7.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "SettlementInfoViewController.h"
#import "PublicInformation.h"
#import "BrushViewController.h"
#import "Packing8583.h"
#import "Define_Header.h"
#import "ModelSettlementInformation.h"
#import "VMT_0InfoRequester.h"

@interface SettlementInfoViewController()
<UITableViewDataSource, UITableViewDelegate>
//{
//    NSArray* keysOfCells;
//    NSDictionary* titlesForKeys;
//}
@property (nonatomic, strong) NSArray* titles;
@property (nonatomic, strong) NSDictionary* titleAndValues;


@end


@implementation SettlementInfoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"结算信息";
        self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        self.tableView.canCancelContentTouches = NO;
        self.tableView.delaysContentTouches = NO;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    
    if (NeedPrintLog) {
        NSLog(@"传入的金额:[%@]",self.sFloatMoney);
    }
}

#pragma mask ---- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cellIdentifier__";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.textLabel.text = [self.titles objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.titleAndValues objectForKey:cell.textLabel.text];
    return cell;
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
    [nextStepButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    nextStepButton.layer.cornerRadius = 8.0;
    
    [nextStepButton addTarget:self action:@selector(touchToPushToBrushVC:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mask ---- 跳转到刷卡界面
- (IBAction) touchToPushToBrushVC:(UIButton*)sender {
    // 跳转刷卡界面
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    BrushViewController *viewcon = [storyboard instantiateViewControllerWithIdentifier:@"brush"];
    [viewcon setStringOfTranType:TranType_Consume];
    [viewcon setSFloatMoney:self.sFloatMoney];
    [viewcon setSIntMoney:[PublicInformation intMoneyFromDotMoney:self.sFloatMoney]];
    [self.navigationController pushViewController:viewcon animated:YES];
}

- (void)setSFloatMoney:(NSString *)sFloatMoney {
    _sFloatMoney = [NSString stringWithString:sFloatMoney];
}

#pragma mask 4 getter 
- (NSArray *)titles {
    return @[@"交易金额",@"单日限额",@"单日可刷额度",@"单笔最小限额",@"手续费率",@"转账手续费"];
}
- (NSDictionary *)titleAndValues {
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSString stringWithFormat:@"￥%@",self.sFloatMoney] forKey:@"交易金额"];
    [dic setObject:[NSString stringWithFormat:@"￥%@",[[VMT_0InfoRequester sharedInstance] amountLimit]] forKey:@"单日限额"];
    [dic setObject:[NSString stringWithFormat:@"￥%@",[[VMT_0InfoRequester sharedInstance] amountAvilable]] forKey:@"单日可刷额度"];
    [dic setObject:[NSString stringWithFormat:@"￥%@",[[VMT_0InfoRequester sharedInstance] amountMinCust]] forKey:@"单笔最小限额"];
    [dic setObject:[NSString stringWithFormat:@"+%@%%",[[VMT_0InfoRequester sharedInstance] T_0MoreRate]] forKey:@"手续费率"];
    [dic setObject:[NSString stringWithFormat:@"￥%@",[[VMT_0InfoRequester sharedInstance] T_0ExtraFee]] forKey:@"转账手续费"];
    return [NSDictionary dictionaryWithDictionary:dic];
}

@end
