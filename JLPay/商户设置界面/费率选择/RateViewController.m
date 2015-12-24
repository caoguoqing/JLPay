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
#import "JLActivitor.h"

#import "ModelFeeBusinessInformation.h"
#import "HTTPRequestFeeBusiness.h"
#import "ModelAreaCodeSelector.h"

@interface RateViewController()
< DynamicPickerViewDelegate ,
HTTPRequestFeeBusinessDelegate,
UIAlertViewDelegate>
{
    CGFloat fontOfText;
    CGRect framePicker;
    
    NSInteger indexFeePicked;
    NSInteger indexProvincePicked;
    NSInteger indexCityPicked;
    NSInteger indexBusinessPicked;
}
@property (nonatomic, strong) UILabel*  labRate;                    // 标签: 费率
@property (nonatomic, strong) UILabel*  labArea;                    // 标签: 地区
@property (nonatomic, strong) UILabel*  labBusiness;                // 标签: 商户
@property (nonatomic, strong) UILabel*  labSaved;
@property (nonatomic, strong) UIButton* btnRate;                    // 按钮: 费率
@property (nonatomic, strong) UIButton* btnArea;                    // 按钮: 地区
@property (nonatomic, strong) UIButton* btnBusiness;                // 按钮: 商户
@property (nonatomic, strong) UIButton* sureButton;                 // 按钮: 确定
@property (nonatomic, strong) UIButton* clearButton;                // 按钮: 清空

@property (nonatomic, strong) DynamicPickerView* pickerView;        // 选择器: 费率、地区、商户 共用

@property (nonatomic, assign) CGRect activitorFrame ;               // 指示器的frame

@property (nonatomic, strong) NSArray* arrayFeeNames;               // 数据源: 费率名组
@property (nonatomic, strong) NSArray* arrayProvinces;              // 数据源: 省组
@property (nonatomic, strong) NSArray* arrayCities;                 // 数据源: 市组
@property (nonatomic, strong) NSArray* arrayBusinesses;             // 数据源: 商户组

@property (nonatomic, retain) HTTPRequestFeeBusiness* httpFeeBusiness;

@end


// KEY: 选择器类型
static NSString* const kPickerTypeRate = @"PickerTypeRate";
static NSString* const kPickerTypeArea = @"PickerTypeArea";
static NSString* const kPickerTypeBusiness = @"PickerTypeBusiness";

@implementation RateViewController
@synthesize labRate = _labRate;
@synthesize labArea = _labArea;
@synthesize labBusiness = _labBusiness;
@synthesize labSaved = _labSaved;
@synthesize btnRate = _btnRate;
@synthesize btnArea = _btnArea;
@synthesize btnBusiness = _btnBusiness;
@synthesize sureButton = _sureButton;
@synthesize clearButton = _clearButton;
@synthesize pickerView = _pickerView;
@synthesize arrayProvinces;
@synthesize arrayCities;
@synthesize arrayBusinesses;
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

    // 给picker设置数据源
    [self.pickerView clearDatas];
    [self.pickerView setPickerType:(NSString*)kPickerTypeRate];
    [self.pickerView setDatas:[ModelFeeBusinessInformation feeNamesList] atComponent:0];
    
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
    [self checkAndStartBusinessRequest];
}

/* 抬起: 在内部: 保存选择的商户号+终端号 */
- (IBAction) touchToSaveBusinessNumAndTerminalNum:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    
    if (indexBusinessPicked < 0) {
        [PublicInformation makeCentreToast:@"未选择机构商户!"];
        return;
    }
    // 保存选择的商户信息到配置
    [self savingSelectedFeeBusinessInfos];
    
    // 修改保存商户标签
    [self labSavedChangeByNewBusinessName:[self.btnBusiness titleForState:UIControlStateNormal]];
    
    // 提示更新
    [PublicInformation makeCentreToast:@"已保存机构商户信息,请继续刷卡"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

/* 抬起: 在内部: 清空已保存的商户号+终端号 */
- (IBAction) touchToClearSavedBusinessAndTerminal:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    
    if ([ModelFeeBusinessInformation isSaved]) {
        [ModelFeeBusinessInformation clearFeeBusinessInfoSaved];
        [PublicInformation makeCentreToast:@"已清空保存的商户信息"];
    }
    [self labSavedChangeByNewBusinessName:@"无"];
}


#pragma mask --- DynamicPickerViewDelegate
/* 回调: 点击了cell */
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
        indexFeePicked = row;
        if (indexCityPicked >= 0) {
            [self checkAndStartBusinessRequest];
        }
        [self updateFeeButtonTitle];
    }
    // 地区
    else if ([pickerView.pickerType isEqualToString:(NSString*)kPickerTypeArea]) {
        if (component == 0) {
            indexProvincePicked = row;
        }
        else if (component == 1) {
            indexCityPicked = row;
            [self updateAreaButtonTitle];
            if (indexFeePicked >= 0) {
                [self checkAndStartBusinessRequest];
            }
        }
    }
    // 商户
    else if ([pickerView.pickerType isEqualToString:(NSString*)kPickerTypeBusiness]) {
        indexBusinessPicked = row;
        [self updateBusinessButtonTitle];
    }
}


#pragma mask --- HTTPRequestFeeBusiness && HTTPRequestFeeBusinessDelegate
/* business 查询: 指定费率、地区代码、商户号 */
- (void) requestBusinessArrayOnRate:(NSString*)rate
                           areaCode:(NSString*)areaCode
{
    [self.httpFeeBusiness requestFeeBusinessOnFeeType:rate
                                             areaCode:areaCode
                                             delegate:self];
    [self startActivitor];
}
- (void)didRequestSuccessWithInfo:(NSDictionary *)responseInfo {
    [self stopActivitor];
    NSArray* feeBusinessList = [responseInfo objectForKey:kFeeBusinessListName];
    if (!feeBusinessList || feeBusinessList.count == 0) {
        [self.btnBusiness setTitle:@"-商户-" forState:UIControlStateNormal];
        [PublicInformation makeCentreToast:@"查询商户列表为空,请重新选择费率或地区"];
        [self resetIndexBusinessPicked];
    } else {
        self.arrayBusinesses = [NSArray arrayWithArray:feeBusinessList];
        [self loadBusinessesInPicker];
    }
}
- (void)didRequestFailWithMessage:(NSString *)errorMessage {
    [self stopActivitor];
    [self.btnBusiness setTitle:@"-商户-" forState:UIControlStateNormal];
    [PublicInformation makeCentreToast:[NSString stringWithFormat:@"查询商户列表失败:%@",errorMessage]];
    [self resetIndexBusinessPicked];
}
/* 重置 indexBusinessPicked */
- (void) resetIndexBusinessPicked {
    indexBusinessPicked = -1;
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



#pragma mask --- 视图控制部分
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"费率选择";
    fontOfText = 15;
    indexFeePicked = -1;
    indexProvincePicked = -1;
    indexCityPicked = -1;
    indexBusinessPicked = -1;
    
    [self.view addSubview:self.labRate];
    [self.view addSubview:self.btnRate];
    [self.view addSubview:self.labArea];
    [self.view addSubview:self.btnArea];
    [self.view addSubview:self.labBusiness];
    [self.view addSubview:self.btnBusiness];
    [self.view addSubview:self.labSaved];
    [self.view addSubview:self.sureButton];
    [self.view addSubview:self.clearButton];
    [self.view addSubview:self.pickerView];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat insetHorizantal = 15;
    CGFloat insetVertical = 6;
    CGFloat viewWidth = self.view.bounds.size.width - insetHorizantal * 2;
    CGFloat labelHeight = 25;
    CGFloat buttonHeight =  40;
    CGFloat statusHeight = [PublicInformation returnStatusHeight];
    CGFloat navigationHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    self.activitorFrame = CGRectMake(0,
                                     statusHeight + navigationHeight,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height - statusHeight - navigationHeight - tabBarHeight);
    CGRect frame = CGRectMake(insetHorizantal,
                              insetVertical + statusHeight + navigationHeight,
                              viewWidth,
                              labelHeight);
    // 标签: 费率
    [self.labRate setFrame:frame];
    // 按钮: 费率
    frame.origin.y += frame.size.height;
    frame.size.height = buttonHeight;
    [self.btnRate setFrame:frame];
    
    // 标签: 地区
    frame.origin.y += frame.size.height + insetVertical;
    frame.size.height = labelHeight;
    [self.labArea setFrame:frame];
    // 按钮: 地区
    frame.origin.y += frame.size.height;
    frame.size.height = buttonHeight;
    [self.btnArea setFrame:frame];
    
    // 标签: 商户
    frame.origin.y += frame.size.height + insetVertical;
    frame.size.height = labelHeight;
    [self.labBusiness setFrame:frame];
    // 按钮: 商户
    frame.origin.y += frame.size.height;
    frame.size.height = buttonHeight;
    [self.btnBusiness setFrame:frame];
    
    // 标签: 已选择的商户
    frame.origin.y += frame.size.height ;//+ inset;
    frame.size.height = labelHeight;
    
    [self.labSaved setFrame:frame];
    
    // 按钮: 清空
    frame.origin.x = insetHorizantal;
    frame.origin.y += frame.size.height + insetVertical*2;
    frame.size.width = (self.view.bounds.size.width - insetHorizantal*3)/2.0;
    frame.size.height = buttonHeight;
    [self.clearButton setFrame:frame];
    // 按钮: 确定
    frame.origin.x += frame.size.width + insetHorizantal;
    [self.sureButton setFrame:frame];
    
    // 选择器
    frame.origin.x = insetHorizantal;
    frame.size.width = self.view.bounds.size.width - insetHorizantal * 2;
    frame.size.height = 40 + 180;
    framePicker = frame;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopActivitor];
    [self.httpFeeBusiness terminateRequest];
}



#pragma mask : === 数据源相关操作
/* DB查询: 所有省份 */
- (void) provincesSelectedFromDB {
    self.arrayProvinces = [NSArray arrayWithArray: [ModelAreaCodeSelector allProvincesSelected]];
}

/* DB查询: 所有市;指定省; */
- (void) citiesSelectedFromDBInProvinceCode:(NSString*)provinceCode {
    self.arrayCities = [NSArray arrayWithArray:[ModelAreaCodeSelector allCitiesSelectedAtProvinceCode:provinceCode]];
}

/* 数组提取: 省 */
- (NSArray*) provincesInDataSource {
    NSMutableArray* provinces = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in self.arrayProvinces) {
        [provinces addObject:[PublicInformation clearSpaceCharAtLastOfString:dict[kFieldNameValue]]];
    }
    return provinces;
}

/* 数组提取: 市 */
- (NSArray*) citiesInDataSource {
    NSMutableArray* cities = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in self.arrayCities) {
        [cities addObject:[PublicInformation clearSpaceCharAtLastOfString:dict[kFieldNameValue]]];
    }
    return cities;
}


/* province code获取: 指定序号 */
- (NSString*) codeProvinceAtIndex:(NSInteger)index {
    NSString* codeProvince = nil;
    NSDictionary* provinceInfo = [self.arrayProvinces objectAtIndex:index];
    if (provinceInfo) {
        codeProvince = [provinceInfo valueForKey:kFieldNameKey];
    }
    return codeProvince;
}
/* province 获取: 指定序号 */
- (NSString*) provinceAtIndex:(NSInteger)index {
    NSString* province = nil;
    NSDictionary* provinceInfo = [self.arrayProvinces objectAtIndex:index];
    if (provinceInfo) {
        province = [PublicInformation clearSpaceCharAtLastOfString:provinceInfo[kFieldNameValue]];
    }
    return province;
}


/* city code获取: 指定序号 */
- (NSString*) codeCityAtIndex:(NSInteger)index {
    NSString* codeCity = nil;
    NSDictionary* cityInfo = [self.arrayCities objectAtIndex:index];
    if (cityInfo) {
        codeCity = [cityInfo valueForKey:kFieldNameKey];
    }
    return codeCity;
}
/* city 获取: 指定序号 */
- (NSString*) cityAtIndex:(NSInteger)index {
    NSString* city = nil;
    NSDictionary* cityInfo = [self.arrayCities objectAtIndex:index];
    if (cityInfo) {
        city = [PublicInformation clearSpaceCharAtLastOfString:[cityInfo valueForKey:kFieldNameValue]];
    }
    return city;
}
/* 重新查询指定序号的地区代码 */
- (NSString*) cityCodeReselect {
    NSString* provinceCode = [self codeProvinceAtIndex:indexProvincePicked];
    [self citiesSelectedFromDBInProvinceCode:provinceCode];
    return [self codeCityAtIndex:indexCityPicked];
}



/* rate value提取: 指定序号 */
- (NSString*) rateAtIndex:(NSInteger)index {
    NSString* rate = nil;
    NSString* feeName = [[ModelFeeBusinessInformation feeNamesList] objectAtIndex:index];
    rate =[ModelFeeBusinessInformation feeTypeOfFeeName:feeName];
    return rate;
}
/* rate 提取: 指定序号 */
- (NSString*) rateNameAtIndex:(NSInteger)index {
    return [[ModelFeeBusinessInformation feeNamesList] objectAtIndex:index];
}

/* 数组提取: 商户 */
- (NSArray*) businessesInDataSource {
    NSMutableArray* businesses = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in self.arrayBusinesses) {
        [businesses addObject:[dict valueForKey:(NSString*)kFeeBusinessBusinessName]];
    }
    return businesses;
}

/* business 提取: 指定序号 */
- (NSString*) businessAtIndex:(NSInteger)index {
    NSString* business = nil;
    NSDictionary* businessInfo = [self.arrayBusinesses objectAtIndex:index];
    if (businessInfo) {
        business = [businessInfo valueForKey:kFeeBusinessBusinessName];
    }
    return business;
}
/* business code 提取: 指定序号 */
- (NSString*) businessNumAtIndex:(NSInteger)index {
    NSString* businessNum = nil;
    NSDictionary* businessInfo = [self.arrayBusinesses objectAtIndex:index];
    if (businessInfo) {
        businessNum = [businessInfo valueForKey:kFeeBusinessBusinessNum];
    }
    return businessNum;
}
/* terminal code 提取: 指定序号 */
- (NSString*) terminalNumAtIndex:(NSInteger)index {
    NSString* terminalNum = nil;
    NSDictionary* businessInfo = [self.arrayBusinesses objectAtIndex:index];
    if (businessInfo) {
        terminalNum = [businessInfo valueForKey:kFeeBusinessTerminalNum];
    }
    return terminalNum;

}

#pragma mask ---- PRIVATE INTERFACE

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


/* 保存的商户号: 从配置中读取 */
- (NSString*) businessNameSaved {
    return [ModelFeeBusinessInformation businessNameSaved];
}
/* 更改商户名标签 */
- (void) labSavedChangeByNewBusinessName:(NSString*)newBusinessName {
    NSString* oldText = self.labSaved.text;
    NSRange range = [oldText rangeOfString:@":"];
    NSMutableString* newText = [NSMutableString stringWithString:[oldText substringToIndex:range.location + range.length]];
    [newText appendString:newBusinessName];
    [self.labSaved setText:newText];
}

/* 保存信息 */
- (void) savingSelectedFeeBusinessInfos {
    NSMutableDictionary* feeBusinessInfo = [[NSMutableDictionary alloc] init];
    feeBusinessInfo[kFeeBusinessInfoFeeSaved] = [ModelFeeBusinessInformation feeNamesList][indexFeePicked];
    feeBusinessInfo[kFeeBusinessInfoAreaCode] = [self cityCodeReselect];
    feeBusinessInfo[kFeeBusinessInfoBusinessName] = [self businessAtIndex:indexBusinessPicked];
    feeBusinessInfo[kFeeBusinessInfoBusinessCode] = [self businessNumAtIndex:indexBusinessPicked];
    feeBusinessInfo[kFeeBusinessInfoTerminalNum] = [self terminalNumAtIndex:indexBusinessPicked];
    [ModelFeeBusinessInformation savingFeeBusinessInfo:feeBusinessInfo];
}

/* 更新费率按钮标题 */
- (void) updateFeeButtonTitle {
    if (indexFeePicked >= 0) {
        [self.btnRate setTitle:[self rateNameAtIndex:indexFeePicked] forState:UIControlStateNormal];
    } else {
        [self.btnRate setTitle:@"-费率-" forState:UIControlStateNormal];
    }
}
/* 更新商户按钮标题 */
- (void) updateBusinessButtonTitle {
    if (indexBusinessPicked >= 0) {
        [self.btnBusiness setTitle:[self businessAtIndex:indexBusinessPicked] forState:UIControlStateNormal];
    } else {
        [self.btnBusiness setTitle:@"-商户名-" forState:UIControlStateNormal];
    }
}
/* 更新地区按钮标题 */
- (void) updateAreaButtonTitle {
    if (indexProvincePicked >=0 && indexCityPicked >= 0) {
        [self.btnArea setTitle:[NSString stringWithFormat:@"%@%@",
                                [self provinceAtIndex:indexProvincePicked],
                                [self cityAtIndex:indexCityPicked]]
                      forState:UIControlStateNormal];
    } else {
        [self.btnArea setTitle:@"-省-市-" forState:UIControlStateNormal];
    }
}

/* 检查并发起商户信息查询 */
- (void) checkAndStartBusinessRequest {
    if (indexFeePicked < 0) {
        [PublicInformation makeCentreToast:@"费率未选择,请先选择!"];
        return;
    }
    if (indexProvincePicked < 0 || indexCityPicked < 0) {
        [PublicInformation makeCentreToast:@"地区未选择,请先选择!"];
        return;
    }
    
    NSString* feeName = [[ModelFeeBusinessInformation feeNamesList] objectAtIndex:indexFeePicked];
    NSString* feeType = [ModelFeeBusinessInformation feeTypeOfFeeName:feeName];
    [self requestBusinessArrayOnRate:feeType areaCode:[self codeCityAtIndex:indexCityPicked]];
}



#pragma mask --- getter & setter 

- (UILabel *)labRate {
    if (_labRate == nil) {
        _labRate = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labRate setText:@"1.请选择费率:"];
        [_labRate setTextAlignment:NSTextAlignmentLeft];
        [_labRate setFont:[UIFont systemFontOfSize:fontOfText]];
    }
    return _labRate;
}
- (UILabel *)labArea {
    if (_labArea == nil) {
        _labArea = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labArea setText:@"2.请选择地区:"];
        [_labArea setTextAlignment:NSTextAlignmentLeft];
        [_labArea setFont:[UIFont systemFontOfSize:fontOfText]];
    }
    return _labArea;
}
- (UILabel *)labBusiness {
    if (_labBusiness == nil) {
        _labBusiness = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labBusiness setText:@"3.请选择商户:"];
        [_labBusiness setTextAlignment:NSTextAlignmentLeft];
        [_labBusiness setFont:[UIFont systemFontOfSize:fontOfText]];
    }
    return _labBusiness;
}
- (UILabel *)labSaved {
    if (_labSaved == nil) {
        _labSaved = [[UILabel alloc] initWithFrame:CGRectZero];
        [_labSaved setTextColor:[UIColor blueColor]];
        [_labSaved setTextAlignment:NSTextAlignmentLeft];
        [_labSaved setFont:[UIFont systemFontOfSize:fontOfText]];
        NSMutableString* labText = [NSMutableString stringWithString:@"已保存商户:"];
        NSString* businessName = [self businessNameSaved];
        if (businessName) {
            [labText appendString:businessName];
        } else {
            [labText appendString:@"无"];
        }
        [_labSaved setText:labText];
    }
    return _labSaved;
}
- (UIButton *)btnRate {
    if (_btnRate == nil) {
        _btnRate = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnRate setTitle:@"-费率-" forState:UIControlStateNormal];
        [_btnRate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnRate.titleLabel setFont:[UIFont systemFontOfSize:fontOfText]];
        _btnRate.layer.borderColor = [UIColor grayColor].CGColor;
        _btnRate.layer.borderWidth = 0.5;
        _btnRate.layer.cornerRadius = 4.0;
        
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
        _btnArea.layer.cornerRadius = 4.0;
        
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
        _btnBusiness.layer.cornerRadius = 4.0;
        
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
        [_sureButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
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
        [_clearButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
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

- (HTTPRequestFeeBusiness *)httpFeeBusiness {
    if (_httpFeeBusiness == nil) {
        _httpFeeBusiness = [[HTTPRequestFeeBusiness alloc] init];
    }
    return _httpFeeBusiness;
}

@end
