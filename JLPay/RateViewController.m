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
#import "MySQLiteManager.h"

@interface RateViewController()
< DynamicPickerViewDelegate >
{
    CGFloat fontOfText;
    CGRect framePicker;
}
@property (nonatomic, strong) UILabel*  labRate;                    // 标签: 费率
@property (nonatomic, strong) UILabel*  labArea;                    // 标签: 地区
@property (nonatomic, strong) UIButton* btnRate;                    // 按钮: 费率
@property (nonatomic, strong) UIButton* btnArea;                    // 按钮: 地区
@property (nonatomic, strong) UIButton* sureButton;                 // 按钮: 确定

@property (nonatomic, strong) DynamicPickerView* pickerView;        // 选择器: 费率、地区、机构 共用

@property (nonatomic, strong) NSMutableArray* arrayRates;
@property (nonatomic, strong) NSMutableArray* arrayAreas;

@property (nonatomic, strong) NSArray* arrayProvinces;              // 数据源: 省
@property (nonatomic, strong) NSArray* arrayCities;                 // 数据源: 市

@property (nonatomic, strong) NSString* ratePicked;                 // 费率: 选择的
@property (nonatomic, strong) NSString* provincePicked;             // 省份: 选择的
@property (nonatomic, strong) NSString* cityPicked;                 // 城市: 选择的

@end

// KEY: 费率数据字典
const NSString* kRateInfoDesc = @"keyDesc";
const NSString* kRateInfoRate = @"rate";
const NSString* kRateInfoToplimit = @"topLimit";
// KEY: 选择器类型
const NSString* kPickerTypeRate = @"PickerTypeRate";
const NSString* kPickerTypeArea = @"PickerTypeArea";
// KEY: 数据库字段名
const NSString* kDBFieldValue = @"VALUE";
const NSString* kDBFieldKey = @"KEY";
const NSString* kDBFieldDescr = @"DESCR";


@implementation RateViewController
@synthesize labRate = _labRate;
@synthesize labArea = _labArea;
@synthesize btnRate = _btnRate;
@synthesize btnArea = _btnArea;
@synthesize sureButton = _sureButton;
@synthesize pickerView = _pickerView;
@synthesize arrayRates = _arrayRates;
@synthesize arrayAreas = _arrayAreas;
@synthesize arrayProvinces;
@synthesize arrayCities;
@synthesize ratePicked;
@synthesize provincePicked;
@synthesize cityPicked;


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
    [self.pickerView setDatas:[self provincesInDataSource] atComponent:0];
    
    // 展示picker
    framePicker.origin.y = sender.frame.origin.y + sender.frame.size.height + 10;
    [self.pickerView setFrame:framePicker];
    [self.pickerView show];
}

#pragma mask --- DynamicPickerViewDelegate
/* 回调: 点解了cell */
- (void)pickerView:(DynamicPickerView *)pickerView didSelectedData:(NSString *)data atComponent:(NSInteger)component {
    if ([pickerView.pickerType isEqualToString:(NSString*)kPickerTypeArea] && component == 0) {
        // 检索出省份key
        NSString* codeProvince = [self codeOfProvince:data];
        // 重新查询省份下的市
        [self citiesSelectedFromDBInProvinceCode:codeProvince];
        // 刷新picker的市
        [self.pickerView setDatas:[self citiesInDataSource] atComponent:1];
    }
}
/* 回调: 点击了确定 */
- (void)pickerView:(DynamicPickerView *)pickerView didPickedData:(NSString *)data atComponent:(NSInteger)component {
    if ([pickerView.pickerType isEqualToString:(NSString*)kPickerTypeRate]) {
        [self.btnRate setTitle:data forState:UIControlStateNormal];
        self.ratePicked = data;
    }
    else if ([pickerView.pickerType isEqualToString:(NSString*)kPickerTypeArea]) {
        if (component == 0) {
            self.provincePicked = data;
        }
        else if (component == 1) {
            self.cityPicked = data;
        }
        NSMutableString* title = [[NSMutableString alloc] init];
        if (self.provincePicked && self.provincePicked.length > 0) {
            [title appendString:self.provincePicked];
        }
        if (self.cityPicked && self.cityPicked.length > 0) {
            [title appendString:self.cityPicked];
        }
        if (title.length > 0) {
            [self.btnArea setTitle:title forState:UIControlStateNormal];
        }
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
/* province code获取: 指定省名 */
- (NSString*) codeOfProvince:(NSString*)province {
    NSString* codeProvince = nil;
    for (NSDictionary* dict in self.arrayProvinces) {
        if ([[dict valueForKey:(NSString*)kDBFieldValue] isEqualToString:province]) {
            codeProvince = [dict valueForKey:(NSString*)kDBFieldKey];
            break;
        }
    }
    return codeProvince;
}

/* city code获取: 指定市名 */
- (NSString*) codeOfCity:(NSString*)city {
    NSString* codeCity = nil;
    for (NSDictionary* dict in self.arrayCities) {
        if ([[dict valueForKey:(NSString*)kDBFieldValue] isEqualToString:city]) {
            codeCity = [dict valueForKey:(NSString*)kDBFieldKey];
            break;
        }
    }
    return codeCity;
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
    [self.view addSubview:self.sureButton];
    [self.view addSubview:self.pickerView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat inset = 15;
    CGFloat labelWidth = [self.labRate.text sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontOfText] forKey:NSFontAttributeName]].width;
    
    CGFloat btnWith = self.view.bounds.size.width - inset * 3 - labelWidth;
    CGFloat labelHeight = 40;
    CGFloat buttonHeight =  50;
    CGFloat statusHeight = [PublicInformation returnStatusHeight];
    CGFloat navigationHeight = self.navigationController.navigationBar.bounds.size.height;
    
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
    // 按钮: 确定
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset*2;
    frame.size.width = self.view.bounds.size.width - inset*2;
    frame.size.height = buttonHeight;
    [self.sureButton setFrame:frame];
    // 选择器
    frame.origin.x = inset;
    frame.size.width = self.view.bounds.size.width - inset * 2;
    frame.size.height = 40 + 180;
    framePicker = frame;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
- (UIButton *)btnRate {
    if (_btnRate == nil) {
        _btnRate = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnRate setTitle:@"默认" forState:UIControlStateNormal];
        [_btnRate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btnRate.titleLabel setFont:[UIFont systemFontOfSize:fontOfText]];
        _btnRate.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _btnRate.layer.borderWidth = 1;
        
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
        _btnArea.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _btnArea.layer.borderWidth = 1;
        
        [_btnArea addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnArea addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_btnArea addTarget:self action:@selector(touchToSelectArea:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnArea;
}
- (UIButton *)sureButton {
    if (_sureButton == nil) {
        _sureButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_sureButton setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sureButton.layer.cornerRadius = 10.0;
        [_sureButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_sureButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [_sureButton addTarget:self action:@selector(touchUpOutSide:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
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
        NSDictionary* dict0 = [NSDictionary dictionaryWithObjects:@[@"默认",@"0.38",@"0"]
                                                         forKeys:@[kRateInfoDesc,kRateInfoRate,kRateInfoToplimit]];
        NSDictionary* dict1 = [NSDictionary dictionaryWithObjects:@[@"0.78不封顶",@"0.78",@"0"]
                                                          forKeys:@[kRateInfoDesc,kRateInfoRate,kRateInfoToplimit]];
        NSDictionary* dict2 = [NSDictionary dictionaryWithObjects:@[@"0.78封顶",@"0.78",@"1"]
                                                          forKeys:@[kRateInfoDesc,kRateInfoRate,kRateInfoToplimit]];
        NSDictionary* dict3 = [NSDictionary dictionaryWithObjects:@[@"1.25不封顶",@"1.25",@"0"]
                                                          forKeys:@[kRateInfoDesc,kRateInfoRate,kRateInfoToplimit]];
        [_arrayRates addObject:dict0];
        [_arrayRates addObject:dict1];
        [_arrayRates addObject:dict2];
        [_arrayRates addObject:dict3];
    }
    return _arrayRates;
}
- (NSMutableArray *)arrayAreas {
    if (_arrayAreas == nil) {
        _arrayAreas = [[NSMutableArray alloc] init];
    }
    return _arrayAreas;
}

@end
