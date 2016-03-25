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
#import "PublicInformation.h"
#import "DatePickerView.h"
#import "Define_Header.h"
#import "ModelDeviceBindedInformation.h"
#import "ViewModelMPOSDetails.h"
#import "ViewModelOtherPayDetails.h"
#import "PullRefrashView.h"
#import "TriangleLeftTurnView.h"
#import "MBProgressHUD+CustomSate.h"

@interface TransDetailsViewController()
<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,
UIScrollViewDelegate,
DatePickerViewDelegate,
ViewModelMPOSDetailsDelegate
>
{
    CGPoint lastScrollPoint;
    CGFloat heightPullRefrashView;
    CGFloat maxPullDownOffset;
    NSInteger tagButton;
}

#pragma mask : view
@property (nonatomic, strong) UITableView* tableView;               // 列出明细的表视图
@property (nonatomic, strong) UIButton* searchButton;               // 查询按钮
@property (nonatomic, strong) UIButton* dateButtonBegin;            // 起始日期按钮
@property (nonatomic, strong) UIButton* dateButtonEnd;              // 终止日期按钮
@property (nonatomic, strong) TotalAmountDisplayView* totalView;    // 总金额显示view
@property (nonatomic, strong) PullRefrashView* pullRefrashView;     // 下拉刷新视图
@property (nonatomic, strong) MBProgressHUD* hud;
#pragma mask : model
@property (nonatomic, retain) id dataSource;

@property (nonatomic) CGRect activitorFrame;
@end

NSInteger logCount = 0;

@implementation TransDetailsViewController
@synthesize totalView = _totalView;
@synthesize tableView = _tableView;
@synthesize searchButton = _searchButton;
@synthesize dateButtonBegin = _dateButtonBegin;
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

    if ([self.tradePlatform isEqualToString:NameTradePlatformMPOSSwipe]) {
        [cell setCardNum:[PublicInformation cuttingOffCardNo:[self.dataSource cardNumAtIndex:indexPath.row]]];
        [cell setTime:[NSString stringWithFormat:@"%@   %@",
                       [self.dataSource formatDateAtIndex:indexPath.row],
                       [self.dataSource transTimeAtIndex:indexPath.row]]];
        // 颜色和交易类型要重置
        [cell setTranType:[self.dataSource transTypeAtIndex:indexPath.row] withColor:textColor];
        // 颜色和金额要重置
        [cell setAmount:[NSString stringWithFormat:@"￥ %@",[PublicInformation dotMoneyFromNoDotMoney:[self.dataSource moneyAtIndex:indexPath.row]]] withColor:textColor];
    }
    else if ([self.tradePlatform isEqualToString:NameTradePlatformOtherPay]) {
        [cell setTime:[NSString stringWithFormat:@"%@   %@",
                       [self.dataSource formatDateAtIndex:indexPath.row],
                       [self.dataSource transTimeAtIndex:indexPath.row]]];
        // 颜色和交易类型要重置
        [cell setTranType:[self.dataSource transTypeAtIndex:indexPath.row] withColor:textColor];
        // 颜色和金额要重置
        [cell setAmount:[NSString stringWithFormat:@"￥ %@",[PublicInformation dotMoneyFromNoDotMoney:[self.dataSource moneyAtIndex:indexPath.row]]] withColor:textColor];
    }

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
            [self requestDataOnStartDate:[self dateOfDateButton:self.dateButtonBegin] endDate:[self dateOfDateButton:self.dateButtonEnd]];
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
    /* 检查输入日期是否满足条件 */
    if ([self isValidOnPickedDate:choosedDate]) {
        // 设置按钮日期: 起始+终止
        [self dateButtonsSetDate:choosedDate];
        
        // 清空列表
        [self.dataSource clearDetails];
        
        // 重新获取列表信息
        [self requestDataOnStartDate:[self dateOfDateButton:self.dateButtonBegin] endDate:[self dateOfDateButton:self.dateButtonEnd]];
    }
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
    tagButton = button.tag;
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"明细查询"]) {
        if (buttonIndex == 1) { // 查询
            UITextField* textField = [alertView textFieldAtIndex:0];
            if (textField.text == nil || [textField.text length] == 0) {
                [self.hud showWarnWithText:@"查询条件为空,请输入卡号或金额" andDetailText:nil onCompletion:nil];
                return;
            }
            // 进行模糊条件查询
            BOOL filtered = [self.dataSource filterDetailsByInput:textField.text];
            if (filtered) {
                [PublicInformation makeToast:@"查询成功"];
                [self.dataSource prepareSelector];
                [self.tableView reloadData];
                [self calculateTotalAmount];
            } else {
                [self.hud showWarnWithText:@"未查询到匹配的明细" andDetailText:nil onCompletion:nil];
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



#pragma mask ---- 数据源请求 & 回调: ViewModelMPOSDetailsDelegate
/* HTTP请求数据 */
- (void) requestDataOnStartDate:(NSString*)startDate endDate:(NSString*)endDate {
    [self.hud showNormalWithText:@"数据加载中..." andDetailText:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.dataSource requestDetailsWithDelegate:self beginTime:startDate endTime:endDate];
    });
    // 清除数据源的过滤条件
    [self.dataSource removeFilter];
}

- (void)didRequestingSuccessful {
    if ([self.pullRefrashView isRefreshing]) {
        [self resetPullRefreshView];
    }
    [self.dataSource prepareSelector];
    if ([self.dataSource totalCountOfTrans] == 0) {
        [self.hud showWarnWithText:@"查询日期无交易明细" andDetailText:nil onCompletion:nil];
    } else {
        [self.hud hide:YES];
    }
    [self.tableView reloadData];
    [self calculateTotalAmount];
}
- (void)didRequestingFailWithCode:(HTTPErrorCode)errorCode andMessage:(NSString *)message {
    if ([self.pullRefrashView isRefreshing]) {
        [self resetPullRefreshView];
    }
    [self.dataSource prepareSelector];
    [self.tableView reloadData];
    [self calculateTotalAmount];
    [self.hud showFailWithText:@"加载失败" andDetailText:message onCompletion:nil];
}

// 扫描明细数组,计算总金额，总笔数
- (void) calculateTotalAmount {
    [self.totalView setTotalAmount:[PublicInformation dotMoneyFromNoDotMoney:[self.dataSource totalAmountOfTrans]]];
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
    [self loadsSubviews];
    tagButton = self.dateButtonBegin.tag;
    
    if ([self.tradePlatform isEqualToString:NameTradePlatformMPOSSwipe]) {
        self.dataSource = [[ViewModelMPOSDetails alloc] init];
    } else if ([self.tradePlatform isEqualToString:NameTradePlatformOtherPay]) {
        self.dataSource = [[ViewModelOtherPayDetails alloc] init];
    }
    
    // 先校验是否绑定了
    if ([ModelDeviceBindedInformation hasBindedDevice]) {
        // 请求数据
        [self requestDataOnStartDate:[PublicInformation nowDate] endDate:[PublicInformation nowDate]];
    } else {
        [self alertShow:@"未绑定设备,请先绑定设备"];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.dataSource terminateRequesting];
    // 清除数据源的过滤条件
    [self.dataSource removeFilter];
}

- (void) loadsSubviews {
    [self setTitleDate:[PublicInformation nowDate] forButton:self.dateButtonBegin];
    [self setTitleDate:[PublicInformation nowDate] forButton:self.dateButtonEnd];
    
    // 总金额显示框
    CGFloat inset = 15;
    CGFloat widthDateButton = [@"2020-20-20" sizeWithAttributes:[NSDictionary dictionaryWithObject:self.dateButtonBegin.titleLabel.font forKey:NSFontAttributeName]].width; //140;
    CGFloat heightDateButton = 26;
    CGFloat widthImageView = 18;
    CGFloat heightSearchButton = 40;
    CGFloat heightSettingsArea = 50;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat naviAndState = self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    self.activitorFrame = CGRectMake(0,
                                     naviAndState,
                                     self.view.bounds.size.width,
                                     self.view.bounds.size.height - naviAndState - self.tabBarController.tabBar.bounds.size.height);

    CGRect frame = CGRectMake(0,
                              self.navigationController.navigationBar.bounds.size.height + statusBarHeight,
                              self.view.bounds.size.width,
                              (self.view.frame.size.height - self.navigationController.navigationBar.bounds.size.height)/4.0);
    // 总金额、总笔数视图
    self.totalView.frame = frame;
    [self.view addSubview:self.totalView];

    CGFloat originY = frame.size.height + frame.origin.y;
    // 起始日期按钮
    frame.origin.x = inset; //0;
    frame.origin.y = originY + (heightSettingsArea - heightDateButton)/2.0;
    frame.size.height = heightDateButton;
    frame.size.width = widthDateButton;
    [self.dateButtonBegin setFrame:frame];
    [self.view addSubview:self.dateButtonBegin];
    
    // 方向指示视图
    UILabel* nextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, widthImageView, widthImageView)];
    nextLabel.text = @"至";
    nextLabel.textAlignment = NSTextAlignmentCenter;
    nextLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(widthImageView, widthImageView) andScale:1]];
    nextLabel.center = CGPointMake(self.dateButtonBegin.center.x + self.dateButtonBegin.bounds.size.width/2.0 + inset/3.0*2.0 + widthImageView/2.0,
                                   self.dateButtonBegin.center.y);
    [self.view addSubview:nextLabel];
    
    // 终止日期
    frame.origin.x += frame.size.width + widthImageView + inset/3.0*2.0 * 2.0;
    [self.dateButtonEnd setFrame:frame];
    [self.view addSubview:self.dateButtonEnd];

    // 查询按钮
    frame.origin.x = self.view.bounds.size.width - inset - frame.size.height;
    frame.origin.y = originY + (heightSettingsArea - heightSearchButton)/2.0;
    frame.size.height = heightSearchButton;
    frame.size.width = frame.size.height;
    [self.searchButton setFrame:frame];
    if ([self.tradePlatform isEqualToString:NameTradePlatformMPOSSwipe]) {
        [self.view addSubview:self.searchButton];
    }

    // 分割线
    frame.origin.x = 0;
    frame.origin.y = originY + heightSettingsArea - 1;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = 0.5;
    UIView* line = [[UIView alloc] initWithFrame:frame];
    line.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [self.view addSubview:line];
    
    // 表视图+下拉刷新按钮
    frame.origin.y += 1;
    frame.size.height = self.view.bounds.size.height - frame.origin.y - self.tabBarController.tabBar.bounds.size.height;
    self.tableView.frame = frame;
    frame.origin.y = -heightPullRefrashView;
    frame.origin.x = 0;
    frame.size.height = heightPullRefrashView;
    [self.pullRefrashView setFrame:frame];
    [self.tableView addSubview:self.pullRefrashView];
    [self.view addSubview:self.tableView];

    [self.view addSubview:self.hud];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


/*************************************
 * 功  能 : 简化代码;
 *************************************/
- (void) alertShow:(NSString*)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

/* 检查选择的日期是否满足条件 */
- (BOOL) isValidOnPickedDate:(NSString*)date {
    BOOL valid = YES;
    int dateInterval = [PublicInformation daysCountDistanceDate:date otherDate:[PublicInformation nowDate]];

    if (date.intValue > [PublicInformation nowDate].intValue) {
        if (tagButton == self.dateButtonBegin.tag) {
            [self.hud showWarnWithText:@"起始日期不能大于当前系统日期!" andDetailText:nil onCompletion:nil];
        }
        else if (tagButton == self.dateButtonEnd.tag) {
            [self.hud showWarnWithText:@"终止日期不能大于当前系统日期!" andDetailText:nil onCompletion:nil];
        }
        valid = NO;
    }
    else if (dateInterval > 90) {
        if (tagButton == self.dateButtonBegin.tag) {
            [self.hud showWarnWithText:@"起始日期不能早于当前日期3个月!" andDetailText:nil onCompletion:nil];
        }
        else if (tagButton == self.dateButtonEnd.tag) {
            [self.hud showWarnWithText:@"终止日期不能早于当前日期3个月!" andDetailText:nil onCompletion:nil];
        }
        valid = NO;
    }
    return valid;
}


// 给日期按钮设置日期
- (void) dateButtonsSetDate:(NSString*)dateString {
    if (tagButton == self.dateButtonBegin.tag) {
        [self setTitleDate:dateString forButton:self.dateButtonBegin];
        if (dateString.intValue > [self dateOfDateButton:self.dateButtonEnd].intValue) {
            [self setTitleDate:dateString forButton:self.dateButtonEnd];
        }
    }
    else {
        [self setTitleDate:dateString forButton:self.dateButtonEnd];
        if (dateString.intValue < [self dateOfDateButton:self.dateButtonBegin].intValue) {
            [self setTitleDate:dateString forButton:self.dateButtonBegin];
        }
    }
}
// 给指定日期按钮设置日期
- (void) setTitleDate:(NSString*)titleDate forButton:(UIButton*)button {
    NSString* year = [titleDate substringToIndex:4];
    NSString* month = [titleDate substringWithRange:NSMakeRange(4, 2)];
    NSString* day = [titleDate substringFromIndex:4+2];
    NSString* fortmatString = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    [button setTitle:fortmatString forState:UIControlStateNormal];
    
    // titleLabel 文字添加下划线
    NSMutableAttributedString* sublineString = [[NSMutableAttributedString alloc] initWithString:fortmatString];
    [sublineString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, fortmatString.length)];
    [button.titleLabel setAttributedText:sublineString];
}

// 获取日期按钮的日期
- (NSString*) dateOfDateButton:(UIButton*)button {
    NSMutableString* dateString = [[NSMutableString alloc] init];
    NSString* string = [button titleForState:UIControlStateNormal];
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
- (UIButton *)dateButtonBegin {
    if (_dateButtonBegin == nil) {
        _dateButtonBegin = [[UIButton alloc] initWithFrame:CGRectZero];
        _dateButtonBegin.layer.cornerRadius = 5.0;
//        _dateButtonBegin.backgroundColor = [PublicInformation returnCommonAppColor:@"blueBlack"];
//        [_dateButtonBegin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_dateButtonBegin setTitleColor:[UIColor colorWithWhite:0.3 alpha:1] forState:UIControlStateNormal];
        _dateButtonBegin.titleLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(0, 20) andScale:1]];
        
        
        [_dateButtonBegin addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_dateButtonBegin addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_dateButtonBegin addTarget:self action:@selector(touchToFrushData:) forControlEvents:UIControlEventTouchUpInside];
        _dateButtonBegin.tag = 99;
    }
    return _dateButtonBegin;
}
- (UIButton *)dateButtonEnd {
    if (_dateButtonEnd == nil) {
        _dateButtonEnd = [[UIButton alloc] initWithFrame:CGRectZero];
        _dateButtonEnd.layer.cornerRadius = 5.0;
//        _dateButtonEnd.backgroundColor = [PublicInformation returnCommonAppColor:@"blueBlack"];
//        [_dateButtonEnd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_dateButtonEnd setTitleColor:[UIColor colorWithWhite:0.3 alpha:1] forState:UIControlStateNormal];
        _dateButtonEnd.titleLabel.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:CGSizeMake(0, 20) andScale:1]];
        
        [_dateButtonEnd addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_dateButtonEnd addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_dateButtonEnd addTarget:self action:@selector(touchToFrushData:) forControlEvents:UIControlEventTouchUpInside];
        _dateButtonEnd.tag = 199;
    }
    return _dateButtonEnd;
}
- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _hud;
}

@end
