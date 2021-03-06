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
#import "JLActivitor.h"
#import "PublicInformation.h"
#import "DatePickerView.h"
#import "SelectIndicatorView.h"
#import "DoubleLayerButton.h"
#import "Toast+UIView.h"
#import "Define_Header.h"

@interface TransDetailsViewController()
<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate,UIAlertViewDelegate
,DatePickerViewDelegate,SelectIndicatorViewDelegate>

@property (nonatomic, strong) TotalAmountDisplayView* totalView;    // 总金额显示view
@property (nonatomic, strong) UITableView* tableView;               // 列出明细的表视图
@property (nonatomic, strong) UIButton* searchButton;               // 查询按钮

@property (nonatomic, strong) UIButton* dateButton;                 // 日期按钮


@property (nonatomic, strong) NSMutableArray* dataArrayDisplay;     // 用来展示的明细的数组
@property (nonatomic, strong) NSArray* oldArraySaving;              // 保存的刚刚下载下来的数据数组
@property (nonatomic, strong) NSMutableData* reciveData;            // 接收HTTP的返回的数据缓存

@property (nonatomic, strong) NSMutableArray* years;
@property (nonatomic, strong) NSMutableArray* months;
@property (nonatomic, strong) NSMutableArray* days;
@property (nonatomic, retain) ASIHTTPRequest* HTTPRequest;      // HTTP入口

@property (nonatomic) CGRect activitorFrame;
@end


@implementation TransDetailsViewController
@synthesize totalView = _totalView;
@synthesize tableView = _tableView;
@synthesize searchButton = _searchButton;
@synthesize dataArrayDisplay = _dataArrayDisplay;
@synthesize reciveData = _reciveData;
@synthesize years = _years;
@synthesize months = _months;
@synthesize days = _days;
@synthesize HTTPRequest = _HTTPRequest;
@synthesize dateButton = _dateButton;
@synthesize activitorFrame;

#pragma mask ------ UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArrayDisplay.count;
}
// 加载单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"reuseCell";
    DetailsCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary* dataDic = [self.dataArrayDisplay objectAtIndex:indexPath.row];
    [cell setCardNum:[dataDic objectForKey:@"pan"]];
    [cell setTime:[dataDic objectForKey:@"instTime"]];
    NSString* trantype = [dataDic objectForKey:@"txnNum"];
    UIColor* textColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1.0];
    if ([trantype isEqualToString:@"消费"]) {
        if ([[dataDic valueForKey:@"revsal_flag"] isEqualToString:@"1"]) {
            trantype = @"消费,已冲正";
            textColor = [UIColor redColor];
        }
        else if ([[dataDic valueForKey:@"cancelFlag"] isEqualToString:@"1"]) {
            trantype = @"消费,已撤销";
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

    RevokeViewController* viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"revokeVC"];
    viewController.dataDic = [self.dataArrayDisplay objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];

}



#pragma mask ------ DatePickerViewDelegate
- (void)datePickerView:(DatePickerView *)datePickerView didChoosedDate:(id)choosedDate {
    // 设置按钮日期
    [self dateButtonSetTitle:choosedDate];

    // 清空列表
    [self cleanTranDetailsList];
    
    // 重新获取列表信息
    [self requestDataOnDate:choosedDate];
}


#pragma mask ------ UIButton Action
- (IBAction) touchDown:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformMakeScale(0.95, 0.95);
}
- (IBAction) touchUpOutSide:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformIdentity;
}
- (IBAction) touchToSearch:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformIdentity;
    
    // 用卡号+金额查询流水明细
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"明细查询" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查询", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setPlaceholder:@"请输入需要查询的后4位卡号或金额"];
    [alert show];

}
- (IBAction) touchToFrushData:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.transform = CGAffineTransformIdentity;

    CGRect frame = CGRectMake(0,
                              self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height,
                              self.view.frame.size.width,
                              self.view.frame.size.height - self.navigationController.navigationBar.bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - self.tabBarController.tabBar.frame.size.height);
    
    NSMutableString* datestring = [[NSMutableString alloc] init];
    [datestring appendString:[button.titleLabel.text substringToIndex:4]];
    [datestring appendString:[button.titleLabel.text substringWithRange:NSMakeRange(4+1, 2)]];
    [datestring appendString:[button.titleLabel.text substringFromIndex:button.titleLabel.text.length - 2]];

    DatePickerView* pickerView = [[DatePickerView alloc] initWithFrame:frame andDate:datestring];
    [pickerView setDelegate: self];
    [self.view addSubview:pickerView];
}

// 清空交易明细列表数据
- (void)cleanTranDetailsList {
    if (self.dataArrayDisplay.count == 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        // 刷新前先清空数据
        [self.dataArrayDisplay removeAllObjects];
        [self calculateTotalAmount];
        [self.tableView reloadData];
    });
}
- (void) requestDataOnDate:(NSString*)dateString {
    NSDictionary* dictInfo = [[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfBinded];
    [self.HTTPRequest addRequestHeader:@"queryBeginTime" value:dateString];
    [self.HTTPRequest addRequestHeader:@"queryEndTime" value:dateString];
    [_HTTPRequest addRequestHeader:@"termNo" value:[dictInfo valueForKey:KeyInfoDictOfBindedTerminalNum]];
    [_HTTPRequest addRequestHeader:@"mchntNo" value:[dictInfo valueForKey:KeyInfoDictOfBindedBussinessNum]];
    [self.HTTPRequest setDelegate:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.HTTPRequest startAsynchronous];  // 异步获取数据
        [[JLActivitor sharedInstance] startAnimatingInFrame:self.activitorFrame];
    });
}


/*************************************
 * 功  能 : UIAlertView 的点击事件;
 *           执行查询步骤;
 * 参  数 :
 * 返  回 :
 *************************************/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"明细查询"]) {
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
                [self.view makeToast:@"查询成功"];
                [self.dataArrayDisplay removeAllObjects];
                [self.dataArrayDisplay addObjectsFromArray:selectedArray];
                // 重载 table 会将总金额也重载掉,所以要将第一个cell拆到tableView外面去
                [self.tableView reloadData];
            }
        }
    }
    else if ([alertView.message hasPrefix:@"未绑定设备"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mask ::: ASIHTTPRequest 的数据接收协议
// HTTP 接收成功
- (void)requestFinished:(ASIHTTPRequest *)request {
    [self.reciveData appendData:[request responseData]];
    [request clearDelegatesAndCancel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self analysisJSONDataToDisplay];
        [[JLActivitor sharedInstance] stopAnimating];
        // 删掉请求,需要时重建
        self.HTTPRequest = nil;
    });

}
// HTTP 接收失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    [request clearDelegatesAndCancel];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* alerView = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"网络异常，请重新查询" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alerView show];
        [[JLActivitor sharedInstance] stopAnimating];

    });
    self.HTTPRequest = nil;

}
#pragma mask ::: 解析从后台获取的JSON格式明细，并展示到表视图
- (void) analysisJSONDataToDisplay {
    NSError* error;
    NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:self.reciveData options:NSJSONReadingMutableLeaves error:&error];

    [self.dataArrayDisplay addObjectsFromArray:[[dataDic objectForKey:@"MchntInfoList"] copy]];
    if (self.dataArrayDisplay.count == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前没有交易明细" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        self.oldArraySaving = [self.dataArrayDisplay copy];
        // 计算总金额
        [self calculateTotalAmount];
        // 重载数据
        [self.tableView reloadData];
    }
    self.reciveData = nil;
}
// 扫描明细数组,计算总金额，总笔数
- (void) calculateTotalAmount {
    CGFloat tAmount = 0.0;
    int tAcount = 0;
    int tSucCount = 0;
    int tRevokeCount = 0;
    for (int i = 0; i < self.dataArrayDisplay.count; i++) {
        // 总金额 = 总消费金额 仅限成功的 (退货等交易的没有加进来)
        NSDictionary* data = [self.dataArrayDisplay objectAtIndex:i];
        if ([[data valueForKey:@"txnNum"] isEqualToString:@"消费"]) {
            tSucCount++;
            if ([[data objectForKey:@"cancelFlag"] isEqualToString:@"0"] &&
                [[data objectForKey:@"revsal_flag"] isEqualToString:@"0"]) {
                tAmount += [[data objectForKey:@"amtTrans"] floatValue];
            }
        } else if ([[data valueForKey:@"txnNum"] isEqualToString:@"消费撤销"]) {
            tRevokeCount++;
        }
        tAcount++;
    }
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
    [self.view addSubview:self.dateButton];
    [self.view addSubview:self.searchButton];
    CGFloat naviAndState = self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    self.activitorFrame = CGRectMake(0,
                                     naviAndState,
                                     self.view.bounds.size.width,
                                     self.view.bounds.size.height - naviAndState - self.tabBarController.tabBar.bounds.size.height);

    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(backToLastViewController)];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    // 先校验是否绑定了
    if ([self deviceBinded]) {
        // 请求数据
        [self requestDataOnDate:[self nowDate]];
    } else {
        [self alertShow:@"未绑定设备,请先绑定设备"];
    }

}
- (void) backToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 总金额显示框
    CGFloat inset = 15;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    CGRect frame = CGRectMake(0,
                              self.navigationController.navigationBar.bounds.size.height + statusBarHeight,
                              self.view.bounds.size.width,
                              (self.view.frame.size.height - self.navigationController.navigationBar.bounds.size.height)/4.0);
    self.totalView.frame = frame;
    
    // 日期按钮
    frame.origin.x = 0;
    frame.origin.y += frame.size.height + inset/3.0 + inset/3.0;
    frame.size.height = 40;
    frame.size.width = 140;
    [self.dateButton setFrame:frame];
    [self dateButtonSetTitle:[self nowDate]];

    
    // 查询按钮
    frame.origin.x = self.view.bounds.size.width - inset - frame.size.height;
    frame.origin.y -= inset/3.0 ;
    frame.size.width = frame.size.height;
    self.searchButton.frame = frame;
    
    // 分割线
    frame.origin.x = 0;
    frame.origin.y += frame.size.height + inset/3.0 - 1;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = 0.5;
    UIView* line = [[UIView alloc] initWithFrame:frame];
    line.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [self.view addSubview:line];
    
    // 表视图
    frame.origin.y += 1;
    frame.size.height = self.view.bounds.size.height - frame.origin.y - self.tabBarController.tabBar.bounds.size.height;
    self.tableView.frame = frame;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[JLActivitor sharedInstance] stopAnimating];
    if (self.HTTPRequest != nil) {        
        [self.HTTPRequest clearDelegatesAndCancel];
        self.HTTPRequest = nil;
    }
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
    for (NSDictionary* dataDic in self.oldArraySaving) {
        NSString* cardNum = [dataDic valueForKey:@"pan"];
        CGFloat money = [[dataDic valueForKey:@"amtTrans"] floatValue]/100.0;
        // 金额或卡号后4位能匹配上
        if (cardOrMoney.length == 4) {
            if ([cardNum hasSuffix:cardOrMoney] || money == cardOrMoney.floatValue) {
                [selectedArray addObject:[dataDic copy]];
            }
        }
        else {
            if (money == cardOrMoney.floatValue) {
                [selectedArray addObject:[dataDic copy]];
            }
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


// 获取当前系统日期
- (NSString*) nowDate {
    NSString* nDate ;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    nDate = [dateFormatter stringFromDate:[NSDate date]];
    nDate = [nDate substringToIndex:8];
    return nDate;
}


// 给日期按钮设置日期
- (void) dateButtonSetTitle:(NSString*)dateString {
    NSString* year = [dateString substringToIndex:4];
    NSString* month = [dateString substringWithRange:NSMakeRange(4, 2)];
    NSString* day = [dateString substringFromIndex:4+2];
    NSString* fortmatString = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    [self.dateButton setTitle:fortmatString forState:UIControlStateNormal];
    
    // titleLabel 文字添加下划线
    NSMutableAttributedString* sublineString = [[NSMutableAttributedString alloc] initWithString:fortmatString];
    [sublineString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, fortmatString.length)];
    [self.dateButton.titleLabel setAttributedText:sublineString];
}

// 检查是否绑定了设备
- (BOOL) deviceBinded {
    BOOL binded = YES;
    NSDictionary* bindedInfos = [[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfBinded];
    if (bindedInfos == nil) {
        binded = NO;
    }
    return binded;
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
        [_searchButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_searchButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_searchButton addTarget:self action:@selector(touchToSearch:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _searchButton;
}
- (UIButton *)dateButton {
    if (_dateButton == nil) {
        _dateButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _dateButton.layer.cornerRadius = 5.0;
        [_dateButton setTitleColor:[UIColor colorWithWhite:0.3 alpha:1] forState:UIControlStateNormal];
        
        [_dateButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_dateButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_dateButton addTarget:self action:@selector(touchToFrushData:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dateButton;
}

- (NSMutableData *)reciveData {
    if (_reciveData == nil) {
        _reciveData = [[NSMutableData alloc] init];
    }
    return _reciveData;
}
- (NSMutableArray *)dataArrayDisplay {
    if (_dataArrayDisplay == nil) {
        _dataArrayDisplay = [[NSMutableArray alloc] init];
    }
    return _dataArrayDisplay;
}
- (NSMutableArray *)years {
    if (_years == nil) {
        _years = [[NSMutableArray alloc] init];
        NSString* nDate = [self nowDate];
        for (int i = [[nDate substringToIndex:4] intValue]; i >= 2015; i--) {
            [_years addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _years;
}
- (NSMutableArray *)months {
    if (_months == nil) {
        _months = [[NSMutableArray alloc] init];
        for (int i = 0; i < 12; i++) {
            [_months addObject:[NSString stringWithFormat:@"%d",i+1]];
        }
    }
    return _months;
}
- (NSMutableArray *)days {
    if (_days == nil) {
        _days = [[NSMutableArray alloc] init];
        for (int i = 0; i < 31; i++) {
            [_days addObject:[NSString stringWithFormat:@"%d",i+1]];
        }
    }
    return _days;
}
- (ASIHTTPRequest *)HTTPRequest {
    if (_HTTPRequest == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getMchntInfo", [PublicInformation getDataSourceIP], [PublicInformation getDataSourcePort] ];
        _HTTPRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [_HTTPRequest setUseCookiePersistence:NO];
        [_HTTPRequest setDelegate:self];
    }
    return _HTTPRequest;
}


@end
