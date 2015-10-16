//
//  RateViewController.m
//  JLPay
//
//  Created by jielian on 15/7/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "RateViewController.h"
#import "PublicInformation.h"
#import "Define_Header.h"
#import "DynamicPickerView.h"
//#import "../../登陆/MySQLiteManager.h"
#import "../../登陆界面/注册/MySQLiteManager.h"
//#import "../../asi-http/ASIFormDataRequest.h"
#import "../../public/asi-http/ASIFormDataRequest.h"
#import "JLActivitor.h"

@interface RateViewController()
< DynamicPickerViewDelegate , ASIHTTPRequestDelegate, UIAlertViewDelegate>
{
    CGFloat fontOfText;
    CGRect framePicker;
}
@property (nonatomic, strong) UILabel*  labRate;                    // 标签: 费率
@property (nonatomic, strong) UILabel*  labArea;                    // 标签: 地区
@property (nonatomic, strong) UILabel*  labBusiness;                // 标签: 商户
@property (nonatomic, strong) UILabel*  labSaved;
@property (nonatomic, strong) UILabel*  labSavedBusiness;
@property (nonatomic, strong) UIButton* btnRate;                    // 按钮: 费率
@property (nonatomic, strong) UIButton* btnArea;                    // 按钮: 地区
@property (nonatomic, strong) UIButton* btnBusiness;                // 按钮: 商户
@property (nonatomic, strong) UIButton* sureButton;                 // 按钮: 确定
@property (nonatomic, strong) UIButton* clearButton;                // 按钮: 清空

@property (nonatomic, strong) DynamicPickerView* pickerView;        // 选择器: 费率、地区、商户 共用

@property (nonatomic, assign) CGRect activitorFrame ;               // 指示器的frame

@property (nonatomic, strong) NSMutableArray* arrayRates;

@property (nonatomic, strong) NSArray* arrayProvinces;              // 数据源: 省
@property (nonatomic, strong) NSArray* arrayCities;                 // 数据源: 市
@property (nonatomic, strong) NSArray* arrayBusinesses;             // 数据源: 商户

@property (nonatomic, strong) NSString* rateCodePicked;             // 费率: 选择的
@property (nonatomic, strong) NSString* cityCodePicked;             // 城市: 选择的
@property (nonatomic, strong) NSString* businessNumPicked;          // 商户号: 选择的
@property (nonatomic, strong) NSString* terminalNumPicked;          // 终端号: 选择的

@property (nonatomic, retain) ASIFormDataRequest* httpRequest;      // HTTP操作入口

@end

// KEY: 费率数据字典
const NSString* kRateInfoDesc = @"keyDesc";
const NSString* kRateInfoRate = @"rate";

// KEY: 选择器类型
const NSString* kPickerTypeRate = @"PickerTypeRate";
const NSString* kPickerTypeArea = @"PickerTypeArea";
const NSString* kPickerTypeBusiness = @"PickerTypeBusiness";

// KEY: 数据库字段名
const NSString* kDBFieldValue = @"VALUE";
const NSString* kDBFieldKey = @"KEY";
const NSString* kDBFieldDescr = @"DESCR";

// KEY: 商户数据字典
const NSString* kBusinessInfoMchtNm = @"mchtNm";
const NSString* kBusinessInfoMchtNo = @"mchtNo";
const NSString* kBusinessInfoTermNo = @"termNo";

// KEY: 提示框: 标签
const NSInteger tagAlertRateNotNull = 11;
const NSInteger tagAlertAreaNotNull = 12;
const NSInteger tagAlertBusinessNotNull = 13;
const NSInteger tagAlertHttpError = 14;
const NSInteger tagAlertDidSaved = 15;


@implementation RateViewController
@synthesize labRate = _labRate;
@synthesize labArea = _labArea;
@synthesize labBusiness = _labBusiness;
@synthesize labSaved = _labSaved;
@synthesize labSavedBusiness = _labSavedBusiness;
@synthesize btnRate = _btnRate;
@synthesize btnArea = _btnArea;
@synthesize btnBusiness = _btnBusiness;
@synthesize sureButton = _sureButton;
@synthesize clearButton = _clearButton;
@synthesize pickerView = _pickerView;
@synthesize arrayRates = _arrayRates;
@synthesize httpRequest = _httpRequest;
@synthesize arrayProvinces;
@synthesize arrayCities;
@synthesize arrayBusinesses;
@synthesize rateCodePicked;
@synthesize cityCodePicked;
@synthesize businessNumPicked;
@synthesize terminalNumPicked;
@synthesize activitorFrame;


#pragma mask --- 按钮事件
/* 按下 */
- (IBAction) touchDown:(UIButton*)sender {
    sender.transform = CGAffineTransformMakeScale(0.95, 0.95);
}

/* 抬起: 在外部 */
- (IBAction) touchUpOutSide:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
}

/* 抬起: 在内部: 选择费率 */
- (IBAction) touchToSelectRate:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;

    // 给picker加载费率数组
    NSMutableArray* datas = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in self.arrayRates) {
        NSString* keyDesc = [dict valueForKey:(NSString*)kRateInfoDesc];
        [datas addObject:keyDesc];
    }
    // 给picker设置数据源
    [self.pickerView clearDatas];
    [self.pickerView setPickerType:(NSString*)kPickerTypeRate];
    [self.pickerView setDatas:datas atComponent:0];
    
    // 展示picker
    framePicker.origin.y = sender.frame.origin.y + sender.frame.size.height + 10;
    [self.pickerView setFrame:framePicker];
    [self.pickerView show];
    
}

/* 抬起: 在内部: 选择地区 */
- (IBAction) touchToSelectArea:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    
    // 初始picker数据
    [self.pickerView clearDatas];
    [self.pickerView setPickerType:(NSString*)kPickerTypeArea];

    // 查询所有省
    [self provincesSelectedFromDB];
    // 查询第一个省下所有市
    NSString* provinceCode = [self codeProvinceAtIndex:0];
    [self citiesSelectedFromDBInProvinceCode:provinceCode];
    
    // 选择器加载数据
    [self.pickerView setDatas:[self provincesInDataSource] atComponent:0];
    [self.pickerView setDatas:[self citiesInDataSource] atComponent:1];

    // 展示picker
    framePicker.origin.y = sender.frame.origin.y + sender.frame.size.height + 10;
    [self.pickerView setFrame:framePicker];
    [self.pickerView show];
    
    [self.pickerView selectRow:0 atComponent:0];
}

/* 抬起: 在内部: 选择商户 */
- (IBAction) touchToSelectBusiness:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    if (!self.rateCodePicked) {
        [self alertShowWithMessage:@"未选择费率" atTag:tagAlertRateNotNull];
        return;
    }
    else if (!self.cityCodePicked) {
        [self alertShowWithMessage:@"未选择地区" atTag:tagAlertAreaNotNull];
        return;
    }
    // 重新获取商户列表到选择器
    [self requestBusinessArrayOnRate:self.rateCodePicked areaCode:self.cityCodePicked businessNum:[PublicInformation returnBusiness]];
}

/* 抬起: 在内部: 保存选择的商户号+终端号 */
- (IBAction) touchToSaveBusinessNumAndTerminalNum:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    if (!self.businessNumPicked || !self.terminalNumPicked) {
        [self alertShowWithMessage:@"未选择机构商户" atTag:tagAlertBusinessNotNull];
        return;
    }
    NSMutableDictionary* jigouInfo = [[NSMutableDictionary alloc] init];
    [jigouInfo setValue:self.businessNumPicked forKey:KeyInfoDictOfJiGouBusinessNum];
    [jigouInfo setValue:self.terminalNumPicked forKey:KeyInfoDictOfJiGouTerminalNum];
    [jigouInfo setValue:[self.btnBusiness titleForState:UIControlStateNormal] forKey:KeyInfoDictOfJiGouBusinessName];
    [[NSUserDefaults standardUserDefaults] setObject:jigouInfo forKey:KeyInfoDictOfJiGou];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self loadBusinessInLabel];
    [self alertShowWithMessage:@"已保存机构商户信息,请继续刷卡" atTag:tagAlertDidSaved];
}

/* 抬起: 在内部: 清空已保存的商户号+终端号 */
- (IBAction) touchToClearSavedBusinessAndTerminal:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    NSDictionary* jigouInfoSaved = [[NSUserDefaults standardUserDefaults] objectForKey:KeyInfoDictOfJiGou];
    if (jigouInfoSaved) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KeyInfoDictOfJiGou];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self alertShowWithMessage:@"已清空保存的商户信息" atTag:tagAlertBusinessNotNull];
    }
    [self.labSavedBusiness setText:nil];
}


#pragma mask --- DynamicPickerViewDelegate
/* 回调: 点解了cell */
- (void)pickerView:(DynamicPickerView *)pickerView didSelectedRow:(NSInteger)row atComponent:(NSInteger)component {
    if ([pickerView.pickerType isEqualToString:(NSString*)kPickerTypeArea] && component == 0) {
        // 检索出省份key
        NSString* codeProvince = [self codeProvinceAtIndex:row];
        // 重新查询省份下的市
        [self citiesSelectedFromDBInProvinceCode:codeProvince];
        // 刷新picker的市
        [self.pickerView setDatas:[self citiesInDataSource] atComponent:1];
    }
}

/* 回调: 点击了确定;地区会连续回调两次 */
- (void)pickerView:(DynamicPickerView *)pickerView didPickedRow:(NSInteger)row atComponent:(NSInteger)component {
    // 费率
    if ([pickerView.pickerType isEqualToString:(NSString*)kPickerTypeRate]) {
        self.rateCodePicked = [self rateAtIndex:row];
        if (self.rateCodePicked != nil && self.cityCodePicked != nil) {
            [self requestBusinessArrayOnRate:self.rateCodePicked areaCode:self.cityCodePicked businessNum:[PublicInformation returnBusiness]];
        }
        // 重设按钮标题
        NSString* rateName = [self rateNameAtIndex:row];
        [self.btnRate setTitle:rateName forState:UIControlStateNormal];
    }
    // 地区
    else if ([pickerView.pickerType isEqualToString:(NSString*)kPickerTypeArea]) {
        if (component == 0) {
            // 重设按钮标题
            NSString* province = [self provinceAtIndex:row];
            [self.btnArea setTitle:province forState:UIControlStateNormal];
        }
        else if (component == 1) {
            // 重设按钮标题
            NSString* city = [self cityAtIndex:row];
            NSString* title = [self.btnArea titleForState:UIControlStateNormal];
            [self.btnArea setTitle:[title stringByAppendingString:city] forState:UIControlStateNormal];
            // 执行HTTP
            self.cityCodePicked = [self codeCityAtIndex:row];
            if (self.rateCodePicked != nil && self.cityCodePicked != nil) {
                [self requestBusinessArrayOnRate:self.rateCodePicked areaCode:self.cityCodePicked businessNum:[PublicInformation returnBusiness]];
            }
        }
    }
    // 商户
    else if ([pickerView.pickerType isEqualToString:(NSString*)kPickerTypeBusiness]) {
        // 重设按钮标题
        NSString* businessName = [self businessAtIndex:row];
        self.businessNumPicked = [self businessNumAtIndex:row];
        self.terminalNumPicked = [self terminalNumAtIndex:row];
        [self.btnBusiness setTitle:businessName forState:UIControlStateNormal];
    }
}


#pragma mask --- ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    [self stopActivitor];
    [request clearDelegatesAndCancel];
    self.httpRequest = nil;
    NSData* responseData = [request responseData];
    NSError* error;
    self.arrayBusinesses = [[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error] objectForKey:@"merchInfoList"];
    if (self.arrayBusinesses && self.arrayBusinesses.count > 0) {
        // 重载picker
        [self loadBusinessesInPicker];
    } else {
        self.arrayBusinesses = nil;
        self.businessNumPicked = nil;
        self.terminalNumPicked = nil;
        
        [self.btnBusiness setTitle:@"-商户-" forState:UIControlStateNormal];
        [self alertShowWithMessage:@"查询商户列表为空,请重新选择费率或地区" atTag:tagAlertHttpError];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request {
    [self stopActivitor];
    [request clearDelegatesAndCancel];
    self.httpRequest = nil;
    [self alertShowWithMessage:@"查询商户列表失败" atTag:tagAlertHttpError];
}

/* 重载picker: 商户 */
- (void) loadBusinessesInPicker {
    [self.pickerView clearDatas];
    [self.pickerView setPickerType:(NSString*)kPickerTypeBusiness];
    [self.pickerView setDatas:[self businessesInDataSource] atComponent:0];
    
    CGRect frame = self.pickerView.frame;
    CGRect businessFrame = self.btnBusiness.frame;
    frame.origin.y = businessFrame.origin.y + businessFrame.size.height + 10;
    [self.pickerView setFrame:frame];
    
    [self.pickerView show];
}


#pragma mask --- UIAlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if (alertView.tag == tagAlertDidSaved && [btnTitle isEqualToString:@"确定"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mask : === 数据源相关操作
/* DB查询: 所有省份 */
- (void) provincesSelectedFromDB {
    NSString* sqlString = @"select value,key,descr from cst_sys_param where owner = 'PROVINCE' and descr = '156' ";
    self.arrayProvinces = [[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:sqlString];
    
    // 去除省末尾的多余空格
    for (NSDictionary* dict in self.arrayProvinces) {
        NSString* province = [dict valueForKey:(NSString*)kDBFieldValue];
        province = [PublicInformation clearSpaceCharAtLastOfString:province];
        [dict setValue:province forKey:(NSString*)kDBFieldValue];
    }
}

/* DB查询: 所有市;指定省; */
- (void) citiesSelectedFromDBInProvinceCode:(NSString*)provinceCode {
    NSString* sqlString = [NSString stringWithFormat:@"select value,key,descr from cst_sys_param where owner = 'CITY' and descr = '%@'", provinceCode];
    self.arrayCities = [[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:sqlString];
    
    // 去除省末尾的多余空格
    for (NSDictionary* dict in self.arrayCities) {
        NSString* city = [dict valueForKey:(NSString*)kDBFieldValue];
        city = [PublicInformation clearSpaceCharAtLastOfString:city];
        [dict setValue:city forKey:(NSString*)kDBFieldValue];
    }
}


/* business 查询: 指定费率、地区代码、商户号 */
- (void) requestBusinessArrayOnRate:(NSString*)rate
                           areaCode:(NSString*)areaCode
                        businessNum:(NSString*)businessNum
{
    [self.httpRequest addPostValue:rate forKey:@"feeType"];
    [self.httpRequest addPostValue:areaCode forKey:@"areaCode"];
    [self.httpRequest addPostValue:businessNum forKey:@"mchtNo"];
    [self.httpRequest startAsynchronous];
    [self startActivitor];
}

/* 启动指示器 */
- (void) startActivitor {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JLActivitor sharedInstance] startAnimatingInFrame:self.activitorFrame];
    });
}
/* 关闭指示器 */
- (void) stopActivitor {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JLActivitor sharedInstance] stopAnimating];
    });
}



/* 数组提取: 省 */
- (NSArray*) provincesInDataSource {
    NSMutableArray* provinces = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in self.arrayProvinces) {
        [provinces addObject:[dict valueForKey:(NSString*)kDBFieldValue]];
    }
    return provinces;
}

/* 数组提取: 市 */
- (NSArray*) citiesInDataSource {
    NSMutableArray* cities = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in self.arrayCities) {
        [cities addObject:[dict valueForKey:(NSString*)kDBFieldValue]];
    }
    return cities;
}
/* 数组提取: 商户 */
- (NSArray*) businessesInDataSource {
    NSMutableArray* businesses = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in self.arrayBusinesses) {
        [businesses addObject:[dict valueForKey:(NSString*)kBusinessInfoMchtNm]];
    }
    return businesses;
}


/* province code获取: 指定序号 */
- (NSString*) codeProvinceAtIndex:(NSInteger)index {
    NSString* codeProvince = nil;
    NSDictionary* provinceInfo = [self.arrayProvinces objectAtIndex:index];
    if (provinceInfo) {
        codeProvince = [provinceInfo valueForKey:(NSString*)kDBFieldKey];
    }
    return codeProvince;
}
/* province 获取: 指定序号 */
- (NSString*) provinceAtIndex:(NSInteger)index {
    NSString* province = nil;
    NSDictionary* provinceInfo = [self.arrayProvinces objectAtIndex:index];
    if (provinceInfo) {
        province = [provinceInfo valueForKey:(NSString*)kDBFieldValue];
    }
    return province;
}


/* city code获取: 指定序号 */
- (NSString*) codeCityAtIndex:(NSInteger)index {
    NSString* codeCity = nil;
    NSDictionary* cityInfo = [self.arrayCities objectAtIndex:index];
    if (cityInfo) {
        codeCity = [cityInfo valueForKey:(NSString*)kDBFieldKey];
    }
    return codeCity;
}
/* city 获取: 指定序号 */
- (NSString*) cityAtIndex:(NSInteger)index {
    NSString* city = nil;
    NSDictionary* cityInfo = [self.arrayCities objectAtIndex:index];
    if (cityInfo) {
        city = [cityInfo valueForKey:(NSString*)kDBFieldValue];
    }
    return city;
}

/* rate value提取: 指定序号 */
- (NSString*) rateAtIndex:(NSInteger)index {
    NSString* rate = nil;
    NSDictionary* rateInfo = [self.arrayRates objectAtIndex:index];
    if (rateInfo) {
        rate = [rateInfo valueForKey:(NSString*)kRateInfoRate];
    }
    return rate;
}
/* rate 提取: 指定序号 */
- (NSString*) rateNameAtIndex:(NSInteger)index {
    NSString* rate = nil;
    NSDictionary* rateInfo = [self.arrayRates objectAtIndex:index];
    if (rateInfo) {
        rate = [rateInfo valueForKey:(NSString*)kRateInfoDesc];
    }
    return rate;
}

/* business 提取: 指定序号 */
- (NSString*) businessAtIndex:(NSInteger)index {
    NSString* business = nil;
    NSDictionary* businessInfo = [self.arrayBusinesses objectAtIndex:index];
    if (businessInfo) {
        business = [businessInfo valueForKey:(NSString*)kBusinessInfoMchtNm];
    }
    return business;
}
/* business code 提取: 指定序号 */
- (NSString*) businessNumAtIndex:(NSInteger)index {
    NSString* businessNum = nil;
    NSDictionary* businessInfo = [self.arrayBusinesses objectAtIndex:index];
    if (businessInfo) {
        businessNum = [businessInfo valueForKey:(NSString*)kBusinessInfoMchtNo];
    }
    return businessNum;
}
/* terminal code 提取: 指定序号 */
- (NSString*) terminalNumAtIndex:(NSInteger)index {
    NSString* terminalNum = nil;
    NSDictionary* businessInfo = [self.arrayBusinesses objectAtIndex:index];
    if (businessInfo) {
        terminalNum = [businessInfo valueForKey:(NSString*)kBusinessInfoTermNo];
    }
    return terminalNum;

}


#pragma mask --- 视图控制部分
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"费率选择";
    fontOfText = 15;
    [self.view addSubview:self.labRate];
    [self.view addSubview:self.btnRate];
    [self.view addSubview:self.labArea];
    [self.view addSubview:self.btnArea];
    [self.view addSubview:self.labBusiness];
    [self.view addSubview:self.btnBusiness];
    [self.view addSubview:self.labSaved];
    [self.view addSubview:self.labSavedBusiness];
    [self.view addSubview:self.sureButton];
    [self.view addSubview:self.clearButton];
    [self.view addSubview:self.pickerView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat inset = 15;
    CGFloat labelWidth = [self.labRate.text sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontOfText] forKey:NSFontAttributeName]].width;
    
    CGFloat btnWith = self.view.bounds.size.width - inset * 3 - labelWidth;
    CGFloat labelHeight = 40;
    CGFloat buttonHeight =  45;
    CGFloat statusHeight = [PublicInformation returnStatusHeight];
    CGFloat navigationHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    self.activitorFrame = CGRectMake(0, statusHeight + navigationHeight, self.view.frame.size.width, self.view.frame.size.height - statusHeight - navigationHeight - tabBarHeight);
    CGRect frame = CGRectMake(inset,
                              inset + statusHeight + navigationHeight,
                              labelWidth,
                              labelHeight);
    // 标签: 费率
    [self.labRate setFrame:frame];
    // 按钮: 费率
    frame.origin.x += frame.size.width + inset;
    frame.size.width = btnWith;
    [self.btnRate setFrame:frame];
    // 标签: 地区
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset;
    frame.size.width = labelWidth;
    [self.labArea setFrame:frame];
    // 按钮: 地区
    frame.origin.x += frame.size.width + inset;
    frame.size.width = btnWith;
    [self.btnArea setFrame:frame];
    // 标签: 商户
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset;
    frame.size.width = labelWidth;
    [self.labBusiness setFrame:frame];
    // 按钮: 商户
    frame.origin.x += frame.size.width + inset;
    frame.size.width = btnWith;
    [self.btnBusiness setFrame:frame];
    // 标签: 已选择的
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset;
    frame.size.width = labelWidth;
    [self.labSaved setFrame:frame];
    // 标签: 商户
    frame.origin.x += frame.size.width + inset;
    frame.size.width = btnWith;
    [self.labSavedBusiness setFrame:frame];
    [self loadBusinessInLabel];
    // 按钮: 清空
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset*2;
    frame.size.width = (self.view.bounds.size.width - inset*3)/2.0;
    frame.size.height = buttonHeight;
    [self.clearButton setFrame:frame];
    // 按钮: 确定
    frame.origin.x += frame.size.width + inset;
    [self.sureButton setFrame:frame];
    
    // 选择器
    frame.origin.x = inset;
    frame.size.width = self.view.bounds.size.width - inset * 2;
    frame.size.height = 40 + 180;
    framePicker = frame;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopActivitor];
    [self.httpRequest clearDelegatesAndCancel];
    self.httpRequest = nil;
}

/* 已选择商户: 从本地配置加载商户 */
- (void) loadBusinessInLabel {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary* jigouInfo = [userDefault objectForKey:KeyInfoDictOfJiGou];
    if (jigouInfo != nil) {
        [self.labSavedBusiness setText:[jigouInfo valueForKey:KeyInfoDictOfJiGouBusinessName]];
    }
}



- (void) alertShowWithMessage:(NSString*)msg atTag:(NSInteger)tag {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert setTag:tag];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}


#pragma mask --- getter & setter 

- (UILabel *)labRate {
    if (_labRate == nil) {
        _labRate = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labRate setText:@"请选择费率:"];
        [_labRate setTextAlignment:NSTextAlignmentRight];
        [_labRate setFont:[UIFont systemFontOfSize:fontOfText]];
    }
    return _labRate;
}
- (UILabel *)labArea {
    if (_labArea == nil) {
        _labArea = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labArea setText:@"请选择地区:"];
        [_labArea setTextAlignment:NSTextAlignmentRight];
        [_labArea setFont:[UIFont systemFontOfSize:fontOfText]];
    }
    return _labArea;
}
- (UILabel *)labBusiness {
    if (_labBusiness == nil) {
        _labBusiness = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labBusiness setText:@"请选择商户:"];
        [_labBusiness setTextAlignment:NSTextAlignmentRight];
        [_labBusiness setFont:[UIFont systemFontOfSize:fontOfText]];
    }
    return _labBusiness;
}
- (UILabel *)labSaved {
    if (_labSaved == nil) {
        _labSaved = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labSaved setText:@"已保存商户:"];
        [_labSaved setTextColor:[UIColor blueColor]];
        [_labSaved setTextAlignment:NSTextAlignmentRight];
        [_labSaved setFont:[UIFont systemFontOfSize:fontOfText]];
    }
    return _labSaved;
}
- (UILabel *)labSavedBusiness {
    if (_labSavedBusiness == nil) {
        _labSavedBusiness = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labSavedBusiness setTextColor:[UIColor blueColor]];
        [_labSavedBusiness setFont:[UIFont systemFontOfSize:fontOfText]];
    }
    return _labSavedBusiness;
}
- (UIButton *)btnRate {
    if (_btnRate == nil) {
        _btnRate = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnRate setTitle:@"-费率-" forState:UIControlStateNormal];
        [_btnRate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnRate.titleLabel setFont:[UIFont systemFontOfSize:fontOfText]];
        _btnRate.layer.borderColor = [UIColor grayColor].CGColor;
        _btnRate.layer.borderWidth = 0.5;
        
        [_btnRate addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnRate addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_btnRate addTarget:self action:@selector(touchToSelectRate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnRate;
}
- (UIButton *)btnArea {
    if (_btnArea == nil) {
        _btnArea = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnArea setTitle:@"-省-市-" forState:UIControlStateNormal];
        [_btnArea setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnArea.titleLabel setFont:[UIFont systemFontOfSize:fontOfText]];
        _btnArea.layer.borderColor = [UIColor grayColor].CGColor;
        _btnArea.layer.borderWidth = 0.5;
        
        [_btnArea addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnArea addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_btnArea addTarget:self action:@selector(touchToSelectArea:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnArea;
}
- (UIButton *)btnBusiness {
    if (_btnBusiness == nil) {
        _btnBusiness = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnBusiness setTitle:@"-商户名-" forState:UIControlStateNormal];
        [_btnBusiness setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnBusiness.titleLabel setFont:[UIFont systemFontOfSize:fontOfText]];
        _btnBusiness.layer.borderColor = [UIColor grayColor].CGColor;
        _btnBusiness.layer.borderWidth = 0.5;
        
        [_btnBusiness addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnBusiness addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_btnBusiness addTarget:self action:@selector(touchToSelectBusiness:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnBusiness;
}
- (UIButton *)sureButton {
    if (_sureButton == nil) {
        _sureButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_sureButton setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        [_sureButton setTitle:@"保存" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sureButton.layer.cornerRadius = 8.0;
        [_sureButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_sureButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_sureButton addTarget:self action:@selector(touchToSaveBusinessNumAndTerminalNum:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}
- (UIButton *)clearButton {
    if (_clearButton == nil) {
        _clearButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_clearButton setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:1]];
        [_clearButton setTitle:@"清空" forState:UIControlStateNormal];
        [_clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _clearButton.layer.cornerRadius = 8.0;
        [_clearButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_clearButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_clearButton addTarget:self action:@selector(touchToClearSavedBusinessAndTerminal:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

- (DynamicPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[DynamicPickerView alloc] initWithFrame:CGRectZero];
        [_pickerView setDelegate:self];
    }
    return _pickerView;
}

- (NSMutableArray *)arrayRates {
    if (_arrayRates == nil) {
        _arrayRates = [[NSMutableArray alloc] init];
        NSDictionary* dict0 = [NSDictionary dictionaryWithObjects:@[@"0.38不封顶",@"0"]
                                                         forKeys:@[kRateInfoDesc,kRateInfoRate]];
        NSDictionary* dict1 = [NSDictionary dictionaryWithObjects:@[@"0.78不封顶",@"1"]
                                                          forKeys:@[kRateInfoDesc,kRateInfoRate]];
        NSDictionary* dict2 = [NSDictionary dictionaryWithObjects:@[@"0.78封顶",@"2"]
                                                          forKeys:@[kRateInfoDesc,kRateInfoRate]];
        NSDictionary* dict3 = [NSDictionary dictionaryWithObjects:@[@"1.25不封顶",@"3"]
                                                          forKeys:@[kRateInfoDesc,kRateInfoRate]];
        [_arrayRates addObject:dict0];
        [_arrayRates addObject:dict1];
        [_arrayRates addObject:dict2];
        [_arrayRates addObject:dict3];
    }
    return _arrayRates;
}
- (ASIFormDataRequest *)httpRequest {
    if (_httpRequest == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getInstMchtInfo", [PublicInformation getDataSourceIP],[PublicInformation getDataSourcePort]];
        _httpRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
        [_httpRequest setDelegate:self];
    }
    return _httpRequest;
}

@end
