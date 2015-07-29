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
#import "DatePickerView.h"

@interface TransDetailsViewController()<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate,UIAlertViewDelegate,
UIPickerViewDataSource,UIPickerViewDelegate,DatePickerViewDelegate>
@property (nonatomic, strong) TotalAmountDisplayView* totalView;    // 总金额显示view
@property (nonatomic, strong) UITableView* tableView;               // 列出明细的表视图
@property (nonatomic, strong) UIButton* searchButton;               // 查询按钮
@property (nonatomic, strong) UIButton* dateButton;                 // 日期按钮:用来切换时间
@property (nonatomic, strong) UIButton* frushButotn;                // 刷新数据的按钮
@property (nonatomic, strong) NSMutableArray* dataArrayDisplay;     // 用来展示的明细的数组
@property (nonatomic, strong) NSArray* oldArraySaving;              // 保存的刚刚下载下来的数据数组
@property (nonatomic, strong) JLActivity* activitor;                // 转轮
@property (nonatomic, strong) NSMutableData* reciveData;            // 接收HTTP的返回的数据缓存

@property (nonatomic, strong) NSMutableArray* years;
@property (nonatomic, strong) NSMutableArray* months;
@property (nonatomic, strong) NSMutableArray* days;
@end


@implementation TransDetailsViewController
@synthesize totalView = _totalView;
@synthesize tableView = _tableView;
@synthesize searchButton = _searchButton;
@synthesize dataArrayDisplay = _dataArrayDisplay;
@synthesize activitor = _activitor;
@synthesize reciveData = _reciveData;
@synthesize dateButton = _dateButton;
@synthesize frushButotn = _frushButotn;
@synthesize years = _years;
@synthesize months = _months;
@synthesize days = _days;

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
    viewController.dataDic = [self.dataArrayDisplay objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];

}



#pragma mask ------ UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString* titleString = nil;
    switch (component) {
        case 0:
            titleString = [self.years objectAtIndex:row];
            break;
        case 1:
            titleString = [self.months objectAtIndex:row];
            break;
        case 2:
            titleString = [self.days objectAtIndex:row];
            break;
        default:
            break;
    }
    return titleString;
}
#pragma mask ------ UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    switch (component) {
        case 0:
            numberOfRows = self.years.count;
            break;
        case 1:
            numberOfRows = self.months.count;
            break;
        case 2:
            numberOfRows = self.days.count;
            break;
        default:
            break;
    }
    return numberOfRows;
}

#pragma mask ------ DatePickerViewDelegate
- (void)datePickerView:(DatePickerView *)datePickerView didChoosedDate:(id)choosedDate {
    [self.dateButton setTitle:choosedDate forState:UIControlStateNormal];
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
- (IBAction) touchToChangeDate:(id)sender {
    UIButton* button = (UIButton*)sender;
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformIdentity;
    }];

    NSString* ndate = self.dateButton.titleLabel.text;
    CGFloat naviAndStatusHeight = self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGRect frame = CGRectMake(0, 0+naviAndStatusHeight, self.view.bounds.size.width, self.view.bounds.size.height - naviAndStatusHeight);
    DatePickerView* pickerView = [[DatePickerView alloc] initWithFrame:frame andDate:ndate];
    [pickerView setDelegate: self];
    [self.view addSubview:pickerView];

}
- (IBAction) touchToFrushData:(id)sender {
    UIButton* button = (UIButton*)sender;
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformIdentity;
    }];
    NSString* text = self.dateButton.titleLabel.text;
    NSString* dates = [NSString stringWithFormat:@"%@%@%@",[text substringToIndex:4],[text substringWithRange:NSMakeRange(4+1, 2)],[text substringFromIndex:text.length - 2]];
    [self startToLoadHTTPDataWithDate:dates];
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
            [self.dataArrayDisplay removeAllObjects];
            [self.dataArrayDisplay addObjectsFromArray:selectedArray];
            // 重载 table 会将总金额也重载掉,所以要将第一个cell拆到tableView外面去
            [self.tableView reloadData];
        }
    }
}



#pragma mask ------ Data Source Func
#pragma mask --------------------------- 异步获取/解析后台交易明细数据
- (void) requestDataFromURL:(NSString*)urlString withDate:(NSString*)ndate{
    NSURL* url = [NSURL URLWithString:urlString];
    if (url == nil) return;
    
    // 设置HTTP header参数
    NSMutableDictionary* dicOfHeader = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                                   [PublicInformation returnTerminal],
                                                                                   [PublicInformation returnBusiness],
                                                                                   ndate,
                                                                                   ndate, nil]
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
        [request clearDelegatesAndCancel];
        [self.reciveData appendData:[blockRequest responseData]];
        [self analysisJSONDataToDisplay];
        if ([self.activitor isAnimating]) [self.activitor stopAnimating];
    }];
    
    // 返回失败的处理
    [request setFailedBlock:^{
        [request clearDelegatesAndCancel];
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
}
// 扫描明细数组,计算总金额，总笔数
- (void) calculateTotalAmount {
    CGFloat tAmount = 0.0;
    int tAcount = 0;
    int tSucCount = 0;
    int tRevokeCount = 0;
    for (int i = 0; i < self.dataArrayDisplay.count; i++) {
        NSDictionary* data = [self.dataArrayDisplay objectAtIndex:i];
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

// 发起HTTP数据请求,并同步接受响应
- (void) startToLoadHTTPDataWithDate:(NSString*)ndate {
    NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getMchntInfo", [PublicInformation getDataSourceIP], [PublicInformation getDataSourcePort] ];
    [self requestDataFromURL:urlString withDate:ndate];
    [self.activitor startAnimating];

}


#pragma mask ------ View Controller Load/Appear/DisAppear
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"交易明细";
    [self.view addSubview:self.totalView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchButton];
    [self.view addSubview:self.frushButotn];
    [self.view addSubview:self.dateButton];
    [self.view addSubview:self.activitor];
    // 从后台异步获取交易明细数据
    [self startToLoadHTTPDataWithDate:[self nowDate]];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    // 总金额显示框
    CGFloat inset = 15;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    CGRect frame = CGRectMake(0,
                              self.navigationController.navigationBar.bounds.size.height + statusBarHeight,
                              self.view.bounds.size.width,
                              (self.view.frame.size.height - self.navigationController.navigationBar.bounds.size.height)/4.0);
    self.totalView.frame = frame;
    
    // 日期选择按钮
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset/3.0;
    frame.size.height = 40;
    frame.size.width = (self.view.bounds.size.width - inset*2)/2.0;
    self.dateButton.frame = frame;
    self.dateButton.layer.cornerRadius = self.dateButton.frame.size.height/2.0;
    self.dateButton.layer.masksToBounds = YES;

    // 刷新按钮
    frame.origin.x += frame.size.width + 5;
    CGSize textSize = [self.frushButotn.titleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:self.frushButotn.titleLabel.font forKey:NSFontAttributeName]];
    CGFloat oldHeight = frame.size.height;
    frame.origin.y += (oldHeight - textSize.height - 10.0)/2.0;
    frame.size.height = textSize.height + 10;
    frame.size.width /= 2.0;
    self.frushButotn.frame = frame;
    self.frushButotn.layer.cornerRadius = frame.size.height/2.0;
    self.frushButotn.layer.masksToBounds = YES;
    
    // 查询按钮
    frame.origin.y -= (oldHeight - textSize.height - 10.0)/2.0;
    frame.size.height = oldHeight;
    frame.origin.x = self.view.bounds.size.width - inset - frame.size.height;
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
    for (NSDictionary* dataDic in self.oldArraySaving) {
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


// 获取当前系统日期
- (NSString*) nowDate {
    NSString* nDate ;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    nDate = [dateFormatter stringFromDate:[NSDate date]];
    nDate = [nDate substringToIndex:8];
    return nDate;
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
        _dateButton.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
        NSString* nDate = [self nowDate];
        NSString* formateDate = [NSString stringWithFormat:@"%@-%@-%@",[nDate substringToIndex:4],[nDate substringWithRange:NSMakeRange(4, 2)],[nDate substringFromIndex:4+2]];
        [_dateButton setTitle:formateDate forState:UIControlStateNormal];
        [_dateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_dateButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_dateButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_dateButton addTarget:self action:@selector(touchToChangeDate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dateButton;
}
- (UIButton *)frushButotn {
    if (_frushButotn == nil) {
        _frushButotn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_frushButotn setTitle:@"刷新" forState:UIControlStateNormal];
        [_frushButotn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _frushButotn.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:64.0/255.0 blue:59.0/255.0 alpha:1.0];
        
        [_frushButotn addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_frushButotn addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchDown];
        [_frushButotn addTarget:self action:@selector(touchToFrushData:) forControlEvents:UIControlEventTouchDown];

    }
    return _frushButotn;
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


@end
