//
//  TransDetailsViewController.m
//  JLPay
//
//  Created by jielian on 15/7/28.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "TransDetailsViewController.h"
#import "TotalAmountDisplayView.h"
#import "DetailsCell.h"
#import "RevokeViewController.h"
#import "ASIFormDataRequest.h"
#import "JLActivity.h"
#import "PublicInformation.h"

@interface TransDetailsViewController()<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) TotalAmountDisplayView* totalView;    // 总金额显示view
@property (nonatomic, strong) UITableView* tableView;               // 列出明细的表视图
@property (nonatomic, strong) UIButton* searchButton;               // 查询按钮
@property (nonatomic, strong) NSMutableArray* dataArray;            // 保存明细的数组
@property (nonatomic, strong) JLActivity* activitor;
@property (nonatomic, strong) NSMutableData* reciveData;

@end


@implementation TransDetailsViewController
@synthesize totalView = _totalView;
@synthesize tableView = _tableView;
@synthesize searchButton = _searchButton;
@synthesize dataArray = _dataArray;
@synthesize activitor = _activitor;
@synthesize reciveData = _reciveData;

#pragma mask ------ UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
// 加载单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"reuseCell";
    DetailsCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary* dataDic = [self.dataArray objectAtIndex:indexPath.row];
    [cell setCardNum:[dataDic objectForKey:@"pan"]];
    [cell setTime:[dataDic objectForKey:@"instTime"]];
    NSString* trantype = [dataDic objectForKey:@"txnNum"];
    UIColor* textColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1.0];
    if ([trantype isEqualToString:@"消费"]) {
        if ([[dataDic valueForKey:@"revsal_flag"] isEqualToString:@"1"]) {
            trantype = @"已冲正";
            textColor = [UIColor redColor];
        }
        else if ([[dataDic valueForKey:@"cancelFlag"] isEqualToString:@"1"]) {
            trantype = @"已撤销";
            textColor = [UIColor redColor];
        }
        else {
            trantype = @"消费成功";
        }
    } else {
        textColor = [UIColor redColor];
    }
    [cell setTranType:trantype withColor:textColor];
    [cell setAmount:[dataDic objectForKey:@"amtTrans"] withColor:textColor];

    return cell;
}
#pragma mask ------ UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;

    RevokeViewController* viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"revokeViewController"];
    viewController.dataDic = [self.dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];

}

#pragma mask ------ UIButton Action
- (IBAction) touchDown:(id)sender {
    UIButton* button = (UIButton*)sender;
    [UIView animateWithDuration:0.2 animations:^{
        button.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }];
}
- (IBAction) touchUpOutSide:(id)sender {
    UIButton* button = (UIButton*)sender;
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformIdentity;
    }];
}
- (IBAction) touchToSearch:(id)sender {
    UIButton* button = (UIButton*)sender;
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformIdentity;
    }];
    
    // 用卡号+金额查询流水明细
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"明细查询" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查询", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setPlaceholder:@"请输入需要查询的卡号或金额"];
    [alert show];

}
/*************************************
 * 功  能 : UIAlertView 的点击事件;
 *           执行查询步骤;
 * 参  数 :
 * 返  回 :
 *************************************/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![alertView.title isEqualToString:@"明细查询"]) {
        return;
    }
    if (buttonIndex == 1) { // 查询
        UITextField* textField = [alertView textFieldAtIndex:0];
        if (textField.text == nil || [textField.text length] == 0) {
            [self alertShow:@"查询条件为空,请输入卡号或金额"];
            return;
        }
        
        NSArray* selectedArray = [self detailsSelectedByCardOrMoney:textField.text];
        if (selectedArray.count == 0) {
            [self alertShow:@"未查询到匹配的明细"];
        } else {
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:selectedArray];
            // 重载 table 会将总金额也重载掉,所以要将第一个cell拆到tableView外面去
            [self.tableView reloadData];
        }
    }
}



#pragma mask ------ Data Source Func
#pragma mask --------------------------- 异步获取/解析后台交易明细数据
- (void) requestDataFromURL: (NSString*)urlString {
    NSURL* url = [NSURL URLWithString:urlString];
    if (url == nil) return;
    
    // 取当前日期的年月日
    NSDateFormatter* dateFomater = [[NSDateFormatter alloc] init];
    [dateFomater setDateFormat:@"yyyyMMddHHmmss"];
    NSString* dateStr = [[dateFomater stringFromDate:[NSDate date]] substringToIndex:8];
    // 设置HTTP header参数
    NSMutableDictionary* dicOfHeader = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                                   [PublicInformation returnTerminal],
                                                                                   [PublicInformation returnBusiness],
                                                                                   dateStr,
                                                                                   dateStr, nil]
                                                                          forKeys:[NSArray arrayWithObjects:
                                                                                   @"termNo",
                                                                                   @"mchntNo",
                                                                                   @"queryBeginTime",
                                                                                   @"queryEndTime", nil]
                                        ];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestHeaders:dicOfHeader];
    [request startAsynchronous];  // 异步获取数据
    
#pragma mask ********************** 需要修改:不要用 block ，改用 delegate
    __weak ASIFormDataRequest* blockRequest = request;
    // 返回数据的处理 -- 不用 delegate, 改用 block
    [request setCompletionBlock:^{
        [self.reciveData appendData:[blockRequest responseData]];
        [self analysisJSONDataToDisplay];
        if ([self.activitor isAnimating]) [self.activitor stopAnimating];
    }];
    
    // 返回失败的处理
    [request setFailedBlock:^{
        UIAlertView* alerView = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"网络异常，请重新查询" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alerView show];
        if ([self.activitor isAnimating]) [self.activitor stopAnimating];
    }];
    
}

#pragma mask ::: ASIHTTPRequest 的数据接收协议
- (void)requestFinished:(ASIHTTPRequest *)request {
    [self.reciveData appendData:[request responseData]];
    [self analysisJSONDataToDisplay];
    if ([self.activitor isAnimating]) [self.activitor stopAnimating];
}
- (void)requestFailed:(ASIHTTPRequest *)request {
    UIAlertView* alerView = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"网络异常，请重新查询" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alerView show];
    if ([self.activitor isAnimating]) [self.activitor stopAnimating];
}
#pragma mask ::: 解析从后台获取的JSON格式明细，并展示到表视图
- (void) analysisJSONDataToDisplay {
    NSError* error;
    NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:self.reciveData options:NSJSONReadingMutableLeaves error:&error];
    
    NSLog(@"接收到得数据:[%@]", dataDic);
    //    self.dataArray = [dataDic objectForKey:@"MchntInfoList"];
    [self.dataArray addObjectsFromArray:[[dataDic objectForKey:@"MchntInfoList"] copy]];
    if (self.dataArray.count == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前没有交易明细" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        // 计算总金额
        [self calculateTotalAmount];
        // 重载数据
        [self.tableView reloadData];
    }
}
// 扫描明细数组,计算总金额，总笔数
- (void) calculateTotalAmount {
    CGFloat tAmount = 0.0;
    int tAcount = 0;
    int tSucCount = 0;
    int tRevokeCount = 0;
    for (int i = 0; i < self.dataArray.count; i++) {
        NSDictionary* data = [self.dataArray objectAtIndex:i];
        if ([[data objectForKey:@"cancelFlag"] isEqualToString:@"1"]) {
            tRevokeCount++;
            tAmount -= [[data objectForKey:@"amtTrans"] floatValue];
        } else {
            tAmount += [[data objectForKey:@"amtTrans"] floatValue];
        }
        tAcount++;
    }
    tSucCount = tAcount - tRevokeCount;
    tAmount /= 100.0;
    [self.totalView setTotalAmount:[NSString stringWithFormat:@"%.02f", tAmount]];
    [self.totalView setTotalRows:[NSString stringWithFormat:@"%d", tAcount]];
    [self.totalView setSucRows:[NSString stringWithFormat:@"%d", tSucCount]];
    [self.totalView setRevokeRows:[NSString stringWithFormat:@"%d", tRevokeCount]];

}



#pragma mask ------ View Controller Load/Appear/DisAppear
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"交易明细";
    [self.view addSubview:self.totalView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchButton];
    [self.view addSubview:self.activitor];
    
    [self.searchButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.searchButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    [self.searchButton addTarget:self action:@selector(touchToSearch:) forControlEvents:UIControlEventTouchUpInside];
    
    // 从后台异步获取交易明细数据
    NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getMchntInfo", [PublicInformation getDataSourceIP], [PublicInformation getDataSourcePort] ];
    [self requestDataFromURL:urlString];
    [self.activitor startAnimating];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
    CGFloat inset = 15;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    CGRect frame = CGRectMake(0,
                              self.navigationController.navigationBar.bounds.size.height + statusBarHeight,
                              self.view.bounds.size.width,
                              (self.view.frame.size.height - self.navigationController.navigationBar.bounds.size.height)/4.0);
    self.totalView.frame = frame;
    
    
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset/3.0;
    frame.size.height = 40;
    frame.size.width = self.view.bounds.size.width - inset*2 - frame.size.height;
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.text = @"交易明细";
    label.font = [UIFont boldSystemFontOfSize:18.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    [self.view addSubview:label];
    
    frame.origin.x += frame.size.width;
    frame.size.width = frame.size.height;
    self.searchButton.frame = frame;
    
    frame.origin.x = 0;
    frame.origin.y += frame.size.height + inset/3.0 - 1;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = 0.5;
    UIView* line = [[UIView alloc] initWithFrame:frame];
    line.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [self.view addSubview:line];
    
    frame.origin.y += 1;
    frame.size.height = self.view.bounds.size.height - frame.origin.y;
    self.tableView.frame = frame;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}




/*************************************
 * 功  能 : 从明细列表中模糊查询出匹配的记录:卡号或金额;
 * 参  数 :
 *          (NSString*)cardOrMoney 需要查询的卡号或金额
 * 返  回 :
 *          (NSArray*)             查询到的明细数组
 *************************************/
- (NSArray*) detailsSelectedByCardOrMoney:(NSString*)cardOrMoney {
    NSMutableArray* selectedArray = [[NSMutableArray alloc] init];
    for (NSDictionary* dataDic in self.dataArray) {
        NSString* cardNum = [dataDic valueForKey:@"pan"];
        CGFloat money = [[dataDic valueForKey:@"amtTrans"] floatValue]/100.0;
        if ([cardNum isEqualToString:cardOrMoney] || money == [cardOrMoney floatValue]) {
            [selectedArray addObject:[dataDic copy]];
        }
    }
    return selectedArray;
}

/*************************************
 * 功  能 : 简化代码;
 *************************************/
- (void) alertShow:(NSString*)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}



#pragma mask ::: getter & setter 
- (TotalAmountDisplayView *)totalView {
    if (_totalView == nil) {
        _totalView = [[TotalAmountDisplayView alloc] initWithFrame:CGRectZero];
    }
    return _totalView;
}
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        [_tableView setTableFooterView:view];
    }
    return _tableView;
}
- (UIButton *)searchButton {
    if (_searchButton == nil) {
        _searchButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _searchButton.backgroundColor = [UIColor clearColor];
        [_searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    }
    return _searchButton;
}
- (JLActivity *)activitor {
    if (_activitor == nil) {
        _activitor = [[JLActivity alloc] init];
    }
    return _activitor;
}
- (NSMutableData *)reciveData {
    if (_reciveData == nil) {
        _reciveData = [[NSMutableData alloc] init];
    }
    return _reciveData;
}
- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
@end
