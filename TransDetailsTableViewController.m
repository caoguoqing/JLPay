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


@interface TransDetailsTableViewController()<NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSArray* dataArray;           // 交易明细数组

@end


@implementation TransDetailsTableViewController
@synthesize dataArray = _dataArray;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"交易管理";

}

#pragma mask ::: 在视图界面还未装载之前,就在后台获取需要展示的数据;
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString* urlString = @"";
    // 从后台异步获取数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 需要修改为从JSON中解析出来......
        
    });
    
    // 加载一个 activity 控件
}

#pragma mask ::: 在表视图界面加载的同时从后台获取data
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
        cell.textLabel.text = @"交易详情";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
        cell.accessoryView.bounds = CGRectMake(0, 0, cell.bounds.size.height / 4.0 * 3.0, cell.bounds.size.height / 4.0 * 3.0);
    } else                          // 明细展示 cell
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"transDetailCell"];
    }
    
    // 给cell加载数据
    [self loadingDataForDetailCell:(DetailsCell*)cell atIndexPath:indexPath];

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
    // 如果是明细的 cell ,需要跳转到明细详细展示界面，并在详细界面中提供“撤销”按钮及对应的功能
}


#pragma mask ::: 给指定序号的cell装载数据
- (void) loadingDataForDetailCell: (DetailsCell *)cell atIndexPath: (NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // 计算总金额,并加载
    } else if (indexPath.row == 1) {
        // 不加载任何信息
    } else {
        // 加载明细单元格
        NSDictionary* dataDic = [self.dataArray objectAtIndex:indexPath.row - 2];
        [cell setAmount:[dataDic objectForKey:@"amount"]];
        [cell setCardNum:[dataDic objectForKey:@"cardNo"]];
        [cell setTime:[dataDic objectForKey:@"time"]];
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
        -mchntNM        商户名称
        -termNo         终端编号
        -queryBeginTime 交易起始时间
        -queryEndTime   交易终止时间
    */
    [mutableRequest addValue:[PublicInformation returnBusiness] forHTTPHeaderField:@"mchntNo"];
    [mutableRequest addValue:[PublicInformation returnTerminal] forHTTPHeaderField:@"termNo"];
    
    NSDateFormatter* dateFomatter = [[NSDateFormatter alloc] init];
    [dateFomatter setDateFormat:@"yyyyMMddHHmmss"];
    [mutableRequest addValue:[dateFomatter stringFromDate:[NSDate date]] forHTTPHeaderField:@"queryBeginTime"];
    [mutableRequest addValue:[dateFomatter stringFromDate:[NSDate date]] forHTTPHeaderField:@"queryEndTime"];
    
    // 发起请求
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:mutableRequest delegate:self];
    [connection start];
}

#pragma mask ::: 获取到后台JSON数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"获取到后台数据[],开始解析...");
}


#pragma mask ::: 自定义返回上层界面按钮的功能
- (IBAction) backToPreVC :(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mask ::: getter 
- (NSArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [[NSArray alloc] init];
    }
    return _dataArray;
}

@end
