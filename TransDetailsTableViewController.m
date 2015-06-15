//
//  TransDetailsTableViewController.m
//  JLPay
//
//  Created by jielian on 15/6/8.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "TransDetailsTableViewController.h"
#import "TotalAmountCell.h"
#import "DetailsCell.h"
#import "PublicInformation.h"
#import "RevokeViewController.h"


@interface TransDetailsTableViewController()<NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSArray* dataArray;           // 交易明细数组
@property (nonatomic, strong) NSMutableData* reciveData;
@property (nonatomic, strong) UIActivityIndicatorView* activity;
@property (nonatomic, strong) NSURLConnection* URLConnection;
@end


@implementation TransDetailsTableViewController
@synthesize dataArray = _dataArray;
@synthesize reciveData = _reciveData;
@synthesize activity = _activity;
@synthesize URLConnection = _URLConnection;

#pragma mask ::: 在表视图界面在加载完自己的view后就到后台读取数据
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"交易管理";
    // 加载一个 activity 控件
//    [self.activity startAnimating];
    [self.view addSubview:self.activity];
    
    // 自定义返回界面的按钮样式
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(backToPreVC:)];
    UIImage* image = [UIImage imageNamed:@"backItem"];
    [backItem setBackButtonBackgroundImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]
                                  forState:UIControlStateNormal
                                barMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem = backItem;

    // 从后台异步获取交易明细数据
    NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getMchntInfo", @"192.188.8.112", @"8083" ];
    [self toRequestDataFromURL: urlString];
}

#pragma mask ::: 在视图界面还未装载之前,就在后台获取需要展示的数据;
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.activity.frame = CGRectMake((self.view.bounds.size.width - 50.0)/2.0, (self.view.bounds.size.height - 50.0)/2.0, 50.0, 50.0);
    [self.activity startAnimating];
}

#pragma mask ::: 在表视图界面加载的同时从后台获取data
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mask ::: 界面即将切换后的方法的重载
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mask ::: UITableViewDataSource -- section 个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mask ::: UITableViewDataSource -- row 个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count + 2;
}

#pragma mask ::: UITableViewDelegate -- cell的重用
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    if (indexPath.row == 0)         // 总金额 cell
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"totalAmountCell"];
    } else if (indexPath.row == 1)  // 明细头描述 cell
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"detailsHeaderCell"];
        cell.textLabel.text = @"交易明细";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
        cell.accessoryView.bounds = CGRectMake(0, 0, cell.bounds.size.height / 4.0 * 3.0, cell.bounds.size.height / 4.0 * 3.0);
    } else                          // 明细展示 cell
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"transDetailCell"];
    }
    
    
    // 给cell加载数据
    [self loadingDataForDetailCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mask ::: 重定义各个类型 cell 的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 ) {
        return 150.0;
    }
    else {
        return 50.0;
    }
}

#pragma mask ::: cell 的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    if (indexPath.row == 0) {
        // 应该取消可点击状态
    } else if (indexPath.row == 1) {
        // 用卡号+金额查询流水明细
    }
    else {
        // 如果是明细的 cell ,需要跳转到明细详细展示界面，并在详细界面中提供“撤销”按钮及对应的功能
        RevokeViewController* viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"revokeViewController"];
        viewController.dataDic = [self.dataArray objectAtIndex:indexPath.row - 2];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
}


#pragma mask ::: 给指定序号的cell装载数据
- (void) loadingDataForDetailCell: (UITableViewCell *)cell atIndexPath: (NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // 计算总金额,并加载
        TotalAmountCell* tCell = (TotalAmountCell*)cell;
        [self colculateTotalAmountFromDataArray:tCell];
    } else if (indexPath.row == 1) {
        // 不加载任何信息
    } else {
        // 加载明细单元格
        DetailsCell* dCell = (DetailsCell*)cell;
        NSDictionary* dataDic = [self.dataArray objectAtIndex:indexPath.row - 2];
        [dCell setAmount:[dataDic objectForKey:@"amtTrans"]];
        [dCell setCardNum:[dataDic objectForKey:@"pan"]];
        [dCell setTime:[dataDic objectForKey:@"instTime"]];
        NSLog(@"\n=========\ndata=[%@]===========", [dataDic allKeys]);
    }
}


#pragma mask --------------------------- 异步获取/解析后台交易明细数据
- (void) toRequestDataFromURL: (NSString*)urlString {
    NSURL* url = [NSURL URLWithString:urlString];
    if (url == nil) return;
    
    // 创建一个超时时间20s 且缓存策略为 NSURLRequestUseProtocolCachePolicy 的网络连接请求
    NSMutableURLRequest* mutableRequest = [[NSMutableURLRequest alloc]initWithURL:url
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:20];
    
    [mutableRequest setHTTPMethod:@"POST"];
    
    /* 开始给 http 添加参数 
        -mchntNo        商户编号
        -termNo         终端编号
        -queryBeginTime 交易起始时间
        -queryEndTime   交易终止时间
    */
    [mutableRequest addValue:[PublicInformation returnBusiness] forHTTPHeaderField:@"mchntNo"];
    [mutableRequest addValue:[PublicInformation returnTerminal] forHTTPHeaderField:@"termNo"];
    
    NSDateFormatter* dateFomatter = [[NSDateFormatter alloc] init];
    [dateFomatter setDateFormat:@"yyyyMMddHHmmss"];
    [mutableRequest addValue:[[dateFomatter stringFromDate:[NSDate date]] substringToIndex:8]
          forHTTPHeaderField:@"queryBeginTime"];
    [mutableRequest addValue:[[dateFomatter stringFromDate:[NSDate date]] substringToIndex:8]
          forHTTPHeaderField:@"queryEndTime"];
    
    // 发起请求 -- 请求期间，不允许切换场景
//    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:mutableRequest delegate:self];
    self.URLConnection = [NSURLConnection connectionWithRequest:mutableRequest delegate:self];
    [self.URLConnection start];
}


#pragma mask ::: 获取到后台JSON数据 -- NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.reciveData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.activity stopAnimating];
    // 开始解析 JSON 数据
    [self analysisJSONDataToDisplay];
    
}

#pragma mask ::: 接收后台数据失败 -- NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    
    
    
    UIAlertView* alerView = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"网络超时，请重新查询" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];

    [alerView show];
//    if (self.activity)
//        [self.activity stopAnimating];
}




#pragma mask ::: 自定义返回上层界面按钮的功能
- (IBAction) backToPreVC :(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.URLConnection cancel];
    if ([self.activity isAnimating])
        [self.activity stopAnimating];

}



#pragma mask ::: 解析从后台获取的JSON格式明细，并展示到表视图
- (void) analysisJSONDataToDisplay {
    NSError* error;
    NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:self.reciveData options:NSJSONReadingMutableLeaves error:&error];
        
    self.dataArray = [dataDic objectForKey:@"MchntInfoList"];
    
    // 重载数据
    [self.tableView reloadData];
}

#pragma mask ::: 计算解析到得数据数组中得总金额以及总笔数等数据
- (void) colculateTotalAmountFromDataArray: (TotalAmountCell*)cell {
    // 总金额
    // 总笔数
    // 总成功笔数
    // 总撤销笔数
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
    tSucCount = tAcount - tRevokeCount*2;
    tAmount /= 100.0;
    [cell setTotalAmount:[NSString stringWithFormat:@"%.02f", tAmount]];
    [cell setTotalRows:[NSString stringWithFormat:@"%d", tAcount]];
    [cell setSucRows:[NSString stringWithFormat:@"%d", tSucCount]];
    [cell setRevokeRows:[NSString stringWithFormat:@"%d", tRevokeCount]];
}



#pragma mask ::: getter 
- (NSArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [[NSArray alloc] init];
    }
    return _dataArray;
}
- (NSMutableData *)reciveData {
    if (_reciveData == nil) {
        _reciveData = [[NSMutableData alloc] init];
    }
    return _reciveData;
}
- (UIActivityIndicatorView *)activity {
    if (_activity == nil) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activity;
}
-(NSURLConnection *)URLConnection {
    if (_URLConnection) {
        _URLConnection = [[NSURLConnection alloc] init];
    }
    return _URLConnection;
}

@end
