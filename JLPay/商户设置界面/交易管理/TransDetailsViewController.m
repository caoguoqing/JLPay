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
#import "JLActivitor.h"
#import "PublicInformation.h"
#import "DatePickerView.h"
#import "SelectIndicatorView.h"
#import "Toast+UIView.h"
#import "Define_Header.h"
#import "ModelDeviceBindedInformation.h"
#import "ViewModelTransDetails.h"
#import "PullRefrashView.h"

@interface TransDetailsViewController()
<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,
UIScrollViewDelegate,
DatePickerViewDelegate,SelectIndicatorViewDelegate, ViewModelTransDetailsDelegate>
{
    CGPoint lastScrollPoint;
    CGFloat heightPullRefrashView;
    CGFloat maxPullDownOffset;
}
@property (nonatomic, strong) TotalAmountDisplayView* totalView;    // 总金额显示view
@property (nonatomic, strong) PullRefrashView* pullRefrashView;     // 下拉刷新视图
@property (nonatomic, strong) UITableView* tableView;               // 列出明细的表视图
@property (nonatomic, strong) UIButton* searchButton;               // 查询按钮
@property (nonatomic, strong) UIButton* dateButton;                 // 日期按钮

@property (nonatomic, strong) NSMutableArray* years;
@property (nonatomic, strong) NSMutableArray* months;
@property (nonatomic, strong) NSMutableArray* days;

@property (nonatomic, retain) ViewModelTransDetails* dataSource; // 数据源

@property (nonatomic) CGRect activitorFrame;
@end

NSInteger logCount = 0;

@implementation TransDetailsViewController
@synthesize totalView = _totalView;
@synthesize tableView = _tableView;
@synthesize searchButton = _searchButton;
@synthesize years = _years;
@synthesize months = _months;
@synthesize days = _days;
@synthesize dateButton = _dateButton;
@synthesize activitorFrame;

#pragma mask ------ UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource totalCountOfTrans];
}
// 加载单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"reuseCell";
    DetailsCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    UIColor* textColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1.0];

    [cell setCardNum:[self.dataSource cardNumAtIndex:indexPath.row]];
    [cell setTime:[self.dataSource transTimeAtIndex:indexPath.row]];
    [cell setTranType:[self.dataSource transTypeAtIndex:indexPath.row] withColor:textColor];
    [cell setAmount:[NSString stringWithFormat:@"￥ %@",[self.dataSource moneyAtIndex:indexPath.row]] withColor:textColor];

    return cell;
}


#pragma mask ------ UITableViewDelegate
/* 点击单元格: 展示详细信息 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;

    RevokeViewController* viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"revokeVC"];
    viewController.dataDic = [self.dataSource nodeDetailAtIndex:indexPath.row];
    viewController.tradePlatform = self.tradePlatform;
    [self.navigationController pushViewController:viewController animated:YES];

}

#pragma mask ---- UIScrollViewDelegate
/* 表格滚动中(拖动、回弹都在这个回调中) */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 下滚动
    if (lastScrollPoint.y - scrollView.contentOffset.y > 0) {
        if (maxPullDownOffset > scrollView.contentOffset.y) {
            maxPullDownOffset = scrollView.contentOffset.y;
        }
        if (scrollView.contentOffset.y < -heightPullRefrashView) {
            [self.pullRefrashView turnPullUp];
        }
    }
    // 上滚动
    else if (lastScrollPoint.y - scrollView.contentOffset.y < 0) {
        // 拖动中
        if (scrollView.dragging) {
            if (scrollView.contentOffset.y > -heightPullRefrashView) {
                [self.pullRefrashView turnPullDown];
            }
        }
        // 松开拖动
        else {
            if (scrollView.contentOffset.y <= -heightPullRefrashView) {
                [self stayPullRefreshView];
            } else {
                [self.pullRefrashView turnPullDown];
            }
        }
    }
    
    lastScrollPoint = scrollView.contentOffset;
}
/* 结束减速 */
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= -heightPullRefrashView) {
        if (maxPullDownOffset <= -heightPullRefrashView) {
            [self.pullRefrashView turnWaiting];
            // 重新获取明细数据
            dispatch_async(dispatch_get_main_queue(), ^{
                [[JLActivitor sharedInstance] startAnimatingInFrame:self.activitorFrame];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self requestDataOnDate:[self dateOfDateButton]];
            });
        }
    }
    maxPullDownOffset = 0;
}
/* 下拉刷新视图占位 */
- (void) stayPullRefreshView {
    UIEdgeInsets edgeInset = UIEdgeInsetsZero;
    edgeInset.top = heightPullRefrashView;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.contentInset = edgeInset;
        self.tableView.contentOffset = CGPointMake(0.0, -heightPullRefrashView);
    }];
}
/* 下拉刷新视图复位 */
- (void) resetPullRefreshView {
    [self.pullRefrashView turnPullDown];
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.contentOffset = CGPointMake(0, 0);
    }];
}


#pragma mask ------ DatePickerViewDelegate
/* 日期选择器的回调 */
- (void)datePickerView:(DatePickerView *)datePickerView didChoosedDate:(id)choosedDate {
    // 设置按钮日期
    [self dateButtonSetTitle:choosedDate];

    // 清空列表
    [self.dataSource clearDetails];
    
    // 重新获取列表信息
    [self requestDataOnDate:choosedDate];
    
    // 启动指示器
    [[JLActivitor sharedInstance] startAnimatingInFrame:self.activitorFrame];
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
            // 进行模糊条件查询
            BOOL filtered = [self.dataSource filterDetailsByInput:textField.text];
            if (filtered) {
                [self.view makeToast:@"查询成功"];
                [self.tableView reloadData];
                [self calculateTotalAmount];
            } else {
                [self alertShow:@"未查询到匹配的明细"];
                [self.dataSource clearDetails];
                [self.tableView reloadData];
                [self calculateTotalAmount];
            }
        }
    }
    else if ([alertView.message hasPrefix:@"未绑定设备"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}



#pragma mask ---- 数据源请求 & 回调: ViewModelTransDetailsDelegate
/* HTTP请求数据 */
- (void) requestDataOnDate:(NSString*)dateString {
    NSString* terminal = [ModelDeviceBindedInformation terminalNoBinded];
    NSString* bussiness = [ModelDeviceBindedInformation businessNoBinded];
    [self.dataSource requestDetailsWithPlatform:self.tradePlatform
                                    andDelegate:self
                                      beginTime:dateString
                                        endTime:dateString
                                       terminal:terminal
                                      bussiness:bussiness];
}

/* 请求的数据返回了 */
- (void)viewModel:(ViewModelTransDetails *)viewModel didRequestResult:(BOOL)result withMessage:(NSString *)message {
    [[JLActivitor sharedInstance] stopAnimating];
    if ([self.pullRefrashView isRefreshing]) {
        [self resetPullRefreshView];
    }
    if (result) {
        [self.tableView reloadData];
        [self calculateTotalAmount];
    } else {
        [self.dataSource clearDetails];
        [self.tableView reloadData];
        [self calculateTotalAmount];
        [self alertShow:message];
    }
}

// 扫描明细数组,计算总金额，总笔数
- (void) calculateTotalAmount {
    [self.totalView setTotalAmount:[NSString stringWithFormat:@"%.02f",[self.dataSource totalAmountOfTrans]]];
    [self.totalView setTotalRows:[NSString stringWithFormat:@"%d", [self.dataSource totalCountOfTrans]]];
    [self.totalView setSucRows:[NSString stringWithFormat:@"%d",[self.dataSource countOfNormalTrans]]];
    [self.totalView setRevokeRows:[NSString stringWithFormat:@"%d", [self.dataSource countofCancelTrans]]];

}



#pragma mask ------ View Controller Load/Appear/DisAppear
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"交易明细";
    heightPullRefrashView = 50;
    lastScrollPoint = CGPointZero;
    maxPullDownOffset = 0;
    [self.view addSubview:self.totalView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.dateButton];
    [self dateButtonSetTitle:[PublicInformation nowDate]];

    if ([self.tradePlatform isEqualToString:NameTradePlatformMPOSSwipe]) {
        [self.view addSubview:self.searchButton];
    }
    CGFloat naviAndState = self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    self.activitorFrame = CGRectMake(0,
                                     naviAndState,
                                     self.view.bounds.size.width,
                                     self.view.bounds.size.height - naviAndState - self.tabBarController.tabBar.bounds.size.height);

    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(backToLastViewController)];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    // 先校验是否绑定了
    if ([ModelDeviceBindedInformation hasBindedDevice]) {
        // 请求数据
        [self requestDataOnDate:[PublicInformation nowDate]];
        // 启动指示器
        [[JLActivitor sharedInstance] startAnimatingInFrame:self.activitorFrame];
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
    frame.origin.y = -heightPullRefrashView;
    frame.origin.x = 0;
    frame.size.height = heightPullRefrashView;
    [self.pullRefrashView setFrame:frame];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[JLActivitor sharedInstance] stopAnimating];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}



/*************************************
 * 功  能 : 简化代码;
 *************************************/
- (void) alertShow:(NSString*)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
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

// 获取日期按钮的日期
- (NSString*) dateOfDateButton {
    NSMutableString* dateString = [[NSMutableString alloc] init];
    NSString* string = [self.dateButton titleForState:UIControlStateNormal];
    [dateString appendFormat:@"%@",[string stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    return dateString;
}

#pragma mask ::: getter & setter 
- (TotalAmountDisplayView *)totalView {
    if (_totalView == nil) {
        _totalView = [[TotalAmountDisplayView alloc] initWithFrame:CGRectZero];
    }
    return _totalView;
}
- (PullRefrashView *)pullRefrashView {
    if (_pullRefrashView == nil) {
        _pullRefrashView = [[PullRefrashView alloc] initWithFrame:CGRectZero];
    }
    return _pullRefrashView;
}
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        [_tableView setTableFooterView:view];
        [_tableView addSubview:self.pullRefrashView];
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

- (NSMutableArray *)years {
    if (_years == nil) {
        _years = [[NSMutableArray alloc] init];
        NSString* nDate = [PublicInformation nowDate];
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

- (ViewModelTransDetails *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[ViewModelTransDetails alloc] init];
    }
    return _dataSource;
}

@end
