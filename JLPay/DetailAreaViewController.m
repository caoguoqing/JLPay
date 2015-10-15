//
//  DetailAreaViewController.m
//  JLPay
//
//  Created by jielian on 15/10/13.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "DetailAreaViewController.h"
#import "PublicInformation.h"
#import "CustomPickerView/DynamicPickerView.h"
#import "MySQLiteManager.h"
#import "Define_Header.h"

@interface DetailAreaViewController()<DynamicPickerViewDelegate>
{
    NSString* kPickerTypeProvince ;
    NSString* kPickerTypeArea ;
    NSString* kPickerTypeCity ;

    NSString* initialProvinceTitle;
    NSString* initialCityTitle;
    NSString* initialAreaTitle;
    CGFloat pickerViewHeight ;
}
@property (nonatomic, strong) UIButton* btnProvince; // 按钮: 省
@property (nonatomic, strong) UIButton* btnCity; // 按钮: 市
@property (nonatomic, strong) UIButton* btnArea; // 按钮: 区县
@property (nonatomic, strong) UITextField* fieldDetailAddr; // 输入框: 详细地址
@property (nonatomic, strong) UIButton* btnSure; // 按钮: 确定

@property (nonatomic, strong) DynamicPickerView* pickerView;

@property (nonatomic, strong) NSArray* arrayProvinces;
@property (nonatomic, strong) NSArray* arrayCities;
@property (nonatomic, strong) NSArray* arrayAreas;

@end




@implementation DetailAreaViewController


#pragma mask ------ PickerView事件
- (void) showPickerInFrame:(CGRect)frame
                 withDatas:(NSArray*)datas
                   andType:(NSString*)pickerType
{
    [self.pickerView clearDatas];
    [self.pickerView setPickerType:pickerType];
    [self.pickerView setFrame:frame];
    [self.pickerView setDatas:datas atComponent:0];
    [self.pickerView show];
}


#pragma mask ------ DynamicPickerViewDelegate
- (void)pickerView:(DynamicPickerView *)pickerView didSelectedRow:(NSInteger)row atComponent:(NSInteger)component {}

- (void)pickerView:(DynamicPickerView *)pickerView didPickedRow:(NSInteger)row atComponent:(NSInteger)component {
    if ([pickerView.pickerType isEqualToString:kPickerTypeProvince]) {
        // 检查是否切换了省份
        NSString* lastProvince = [self.btnProvince titleForState:UIControlStateNormal];
        NSString* pickedProvince = [self provinceAtIndex:row];
        if (![lastProvince isEqualToString:pickedProvince]) {
            // 切换省份要清空市和区县
            [self.btnCity setTitle:initialCityTitle forState:UIControlStateNormal];
            [self.btnArea setTitle:initialAreaTitle forState:UIControlStateNormal];
            self.arrayCities = nil;
            self.arrayAreas = nil;
        }
        [self.btnProvince setTitle:[self provinceAtIndex:row] forState:UIControlStateNormal];
    }
    else if ([pickerView.pickerType isEqualToString:kPickerTypeCity]) {
        // 检查是否切换了省份
        NSString* lastCity = [self.btnProvince titleForState:UIControlStateNormal];
        NSString* pickedCity = [self cityAtIndex:row];
        if (![lastCity isEqualToString:pickedCity]) {
            // 切换省份要清空市和区县
            [self.btnArea setTitle:initialAreaTitle forState:UIControlStateNormal];
            self.arrayAreas = nil;
        }
        [self.btnCity setTitle:[self cityAtIndex:row] forState:UIControlStateNormal];
    }
    else if ([pickerView.pickerType isEqualToString:kPickerTypeArea]) {
        [self.btnArea setTitle:[self areaAtIndex:row] forState:UIControlStateNormal];
    }
}

#pragma mask ------ 按钮事件组
- (IBAction) touchDown:(UIButton*)sender {
    sender.transform = CGAffineTransformMakeScale(0.95, 0.95);
}
- (IBAction) touchOut:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
}

- (IBAction) touchToSelectProvince:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    [self provincesSelectedFromDB];
    [self showPickerInFrame:[self frameForPickerByButton:sender] withDatas:[self provincesInDataSource] andType:kPickerTypeProvince];
}
- (IBAction) touchToSelectCity:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    // 检查是否选择了省
    NSString* province = [self.btnProvince titleForState:UIControlStateNormal];
    if ([province isEqualToString:initialProvinceTitle]) {
        [self alertWithMessage:@"请先选择省份"];
        return;
    }
    // 查询市
    NSString* provinceCode = [self codeProvince:province];
    [self citiesSelectedFromDBInProvinceCode:provinceCode];
    // 重载选择器
    [self showPickerInFrame:[self frameForPickerByButton:sender] withDatas:[self citiesInDataSource] andType:kPickerTypeCity];

}
- (IBAction) touchToSelectArea:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    // 检查是否选择了市
    NSString* city = [self.btnCity titleForState:UIControlStateNormal];
    if ([city isEqualToString:initialCityTitle]) {
        [self alertWithMessage:@"请先选择城市"];
        return;
    }
    // 查询区县
    NSString* cityCode = [self codeCity:city];
    [self areasSelectedFromDBInProvinceCode:cityCode];
    // 重载选择器
    [self showPickerInFrame:[self frameForPickerByButton:sender] withDatas:[self areasInDataSource] andType:kPickerTypeArea];
}

- (IBAction) touchToSaveDetails:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    // 检查输入
    // 打包要带回的数据
    // 回退场景
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"pop后的最上层VC:[%@]", self.navigationController.topViewController);
}
// 计算选择器的frame: 指定按钮
- (CGRect) frameForPickerByButton:(UIButton*)button {
    return CGRectMake(button.frame.origin.x, button.frame.origin.y + button.frame.size.height + 10, button.frame.size.width, pickerViewHeight);
}


#pragma mask : === 数据源相关操作
/* DB查询: 所有省份 */
- (void) provincesSelectedFromDB {
    NSString* sqlString = @"select value,key,descr from cst_sys_param where owner = 'PROVINCE' and descr = '156' ";
    self.arrayProvinces = [[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:sqlString];
    
    // 去除省末尾的多余空格
    for (NSDictionary* dict in self.arrayProvinces) {
        NSString* province = [dict valueForKey:@"VALUE"];
        province = [PublicInformation clearSpaceCharAtLastOfString:province];
        [dict setValue:province forKey:@"VALUE"];
    }
}

/* DB查询: 所有市;指定省; */
- (void) citiesSelectedFromDBInProvinceCode:(NSString*)provinceCode {
    NSString* sqlString = [NSString stringWithFormat:@"select value,key,descr from cst_sys_param where owner = 'CITY' and descr = '%@'", provinceCode];
    self.arrayCities = [[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:sqlString];
    
    // 去除省末尾的多余空格
    for (NSDictionary* dict in self.arrayCities) {
        NSString* city = [dict valueForKey:@"VALUE"];
        city = [PublicInformation clearSpaceCharAtLastOfString:city];
        [dict setValue:city forKey:@"VALUE"];
    }
}
/* DB查询: 所有区县;指定市; */
- (void) areasSelectedFromDBInProvinceCode:(NSString*)cityCode {
    NSString* sqlString = [NSString stringWithFormat:@"select value,key,descr from cst_sys_param where owner = 'AREA' and descr = '%@'", cityCode];
    self.arrayAreas = [[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:sqlString];
    
    // 去除省末尾的多余空格
    for (NSDictionary* dict in self.arrayAreas) {
        NSString* city = [dict valueForKey:@"VALUE"];
        city = [PublicInformation clearSpaceCharAtLastOfString:city];
        [dict setValue:city forKey:@"VALUE"];
    }
}


/* 数组提取: 省 */
- (NSArray*) provincesInDataSource {
    NSMutableArray* provinces = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in self.arrayProvinces) {
        [provinces addObject:[dict valueForKey:@"VALUE"]];
    }
    return provinces;
}
/* 数组提取: 市 */
- (NSArray*) citiesInDataSource {
    NSMutableArray* cities = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in self.arrayCities) {
        [cities addObject:[dict valueForKey:@"VALUE"]];
    }
    return cities;
}
/* 数组提取: 区县 */
- (NSArray*) areasInDataSource {
    NSMutableArray* areas = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in self.arrayAreas) {
        [areas addObject:[dict valueForKey:@"VALUE"]];
    }
    return areas;
}

/* province code获取: 指定序号 */
- (NSString*) codeProvinceAtIndex:(NSInteger)index {
    NSString* codeProvince = nil;
    NSDictionary* provinceInfo = [self.arrayProvinces objectAtIndex:index];
    if (provinceInfo) {
        codeProvince = [provinceInfo valueForKey:@"KEY"];
    }
    return codeProvince;
}
/* province code获取: 指定省名 */
- (NSString*) codeProvince:(NSString*)province {
    NSString* code = nil;
    for (NSDictionary* dict in self.arrayProvinces) {
        if ([[dict valueForKey:@"VALUE"] isEqualToString:province]) {
            code = [dict valueForKey:@"KEY"];
            break;
        }
    }
    return code;
}

/* province 获取: 指定序号 */
- (NSString*) provinceAtIndex:(NSInteger)index {
    NSString* province = nil;
    NSDictionary* provinceInfo = [self.arrayProvinces objectAtIndex:index];
    if (provinceInfo) {
        province = [provinceInfo valueForKey:@"VALUE"];
    }
    return province;
}
/* city code获取: 指定序号 */
- (NSString*) codeCityAtIndex:(NSInteger)index {
    NSString* codeCity = nil;
    NSDictionary* cityInfo = [self.arrayCities objectAtIndex:index];
    if (cityInfo) {
        codeCity = [cityInfo valueForKey:@"KEY"];
    }
    return codeCity;
}
/* city code获取: 指定市名 */
- (NSString*) codeCity:(NSString*)city {
    NSString* code = nil;
    for (NSDictionary* dict in self.arrayCities) {
        if ([[dict valueForKey:@"VALUE"] isEqualToString:city]) {
            code = [dict valueForKey:@"KEY"];
            break;
        }
    }
    return code;
}

/* city 获取: 指定序号 */
- (NSString*) cityAtIndex:(NSInteger)index {
    NSString* city = nil;
    NSDictionary* cityInfo = [self.arrayCities objectAtIndex:index];
    if (cityInfo) {
        city = [cityInfo valueForKey:@"VALUE"];
    }
    return city;
}
/* area code获取: 指定序号 */
- (NSString*) codeAreaAtIndex:(NSInteger)index {
    NSString* codeArea = nil;
    NSDictionary* areaInfo = [self.arrayAreas objectAtIndex:index];
    if (areaInfo) {
        codeArea = [areaInfo valueForKey:@"KEY"];
    }
    return codeArea;
}
/* area 获取: 指定序号 */
- (NSString*) areaAtIndex:(NSInteger)index {
    NSString* area = nil;
    NSDictionary* areaInfo = [self.arrayAreas objectAtIndex:index];
    if (areaInfo) {
        area = [areaInfo valueForKey:@"VALUE"];
    }
    return area;
}





#pragma mask ------ 界面生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    kPickerTypeProvince = @"kPickerTypeProvince";
    kPickerTypeArea = @"PickerTypeArea";
    kPickerTypeCity = @"kPickerTypeCity";

    initialProvinceTitle = @"-省(必选)-";
    initialCityTitle = @"-市(必选)-";
    initialAreaTitle = @"-区/县(可选)-";
    pickerViewHeight = 40 + 180;
    
    [self.view addSubview:self.btnProvince];
    [self.view addSubview:self.btnCity];
    [self.view addSubview:self.btnArea];
    [self.view addSubview:self.fieldDetailAddr];
    [self.view addSubview:self.btnSure];
    [self.view addSubview:self.pickerView];
    
    CGFloat statesNaviHeight = [PublicInformation returnStatusHeight] + self.navigationController.navigationBar.frame.size.height;
    CGRect inFrame = CGRectMake(0,
                                statesNaviHeight,
                                self.view.frame.size.width,
                                self.view.frame.size.height - statesNaviHeight);
    [self layoutSubviewsInFrame:inFrame];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

/* 加载子视图 */
- (void) layoutSubviewsInFrame:(CGRect)frame {
    CGFloat insetVertical = 20;
    CGFloat insetHorizantal = 15;
    CGFloat viewHeight = 40;
    CGFloat mustInputLabelWidth = 10;
    CGFloat btnWidth = frame.size.width - insetHorizantal*2 - mustInputLabelWidth;
    
    
    
    CGRect inFrame = CGRectMake(insetHorizantal,
                                frame.origin.y + insetVertical,
                                mustInputLabelWidth,
                                viewHeight);
    // 省
    [self.view addSubview:[self newMustInputLabelInNeed:YES inFrame:inFrame]];
    inFrame.origin.x += inFrame.size.width;
    inFrame.size.width = btnWidth;
    [self.btnProvince setFrame:inFrame];
    
    // 市
    inFrame.origin.x = insetHorizantal;
    inFrame.origin.y += inFrame.size.height + insetVertical;
    inFrame.size.width = mustInputLabelWidth;
    [self.view addSubview:[self newMustInputLabelInNeed:YES inFrame:inFrame]];
    inFrame.origin.x += inFrame.size.width;
    inFrame.size.width = btnWidth;
    [self.btnCity setFrame:inFrame];
    
    // 区县
    inFrame.origin.x = insetHorizantal;
    inFrame.origin.y += inFrame.size.height + insetVertical;
    inFrame.size.width = mustInputLabelWidth;
    [self.view addSubview:[self newMustInputLabelInNeed:NO inFrame:inFrame]];
    inFrame.origin.x += inFrame.size.width;
    inFrame.size.width = btnWidth;
    [self.btnArea setFrame:inFrame];

    // 输入框
    inFrame.origin.x = insetHorizantal;
    inFrame.origin.y += inFrame.size.height + insetVertical;
    inFrame.size.width = mustInputLabelWidth;
    [self.view addSubview:[self newMustInputLabelInNeed:YES inFrame:inFrame]];
    inFrame.origin.x += inFrame.size.width;
    inFrame.size.width = btnWidth;
    [self.fieldDetailAddr setFrame:inFrame];
    
    // 确定按钮
    inFrame.origin.x = insetHorizantal;
    inFrame.origin.y += inFrame.size.height + insetVertical;
    inFrame.size.width = frame.size.width - insetHorizantal*2;
    [self.btnSure setFrame:inFrame];
    
}
- (UILabel*) newMustInputLabelInNeed:(BOOL)mustInput inFrame:(CGRect)frame {
    UILabel* mustInputLabel = [[UILabel alloc] initWithFrame:frame];
    if (mustInput) {
        mustInputLabel.text = @"*";
        mustInputLabel.textColor = [PublicInformation returnCommonAppColor:@"red"];
        mustInputLabel.textAlignment = NSTextAlignmentLeft;
    }
    return mustInputLabel;
}


/* 简化代码 */
- (void) alertWithMessage:(NSString*)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}


#pragma mask ------ getter
- (UIButton *)btnProvince {
    if (_btnProvince == nil) {
        _btnProvince = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnProvince setTitle:initialProvinceTitle forState:UIControlStateNormal];
        [_btnProvince setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnProvince.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _btnProvince.layer.borderWidth = 1;
        
        [_btnProvince addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnProvince addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpOutside];
        [_btnProvince addTarget:self action:@selector(touchToSelectProvince:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnProvince;
}
- (UIButton *)btnCity {
    if (_btnCity == nil) {
        _btnCity = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnCity setTitle:initialCityTitle forState:UIControlStateNormal];
        [_btnCity setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnCity.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _btnCity.layer.borderWidth = 1;
        
        [_btnCity addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnCity addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpOutside];
        [_btnCity addTarget:self action:@selector(touchToSelectCity:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCity;
}
- (UIButton *)btnArea {
    if (_btnArea == nil) {
        _btnArea = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnArea setTitle:initialAreaTitle forState:UIControlStateNormal];
        [_btnArea setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnArea.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _btnArea.layer.borderWidth = 1;
        
        [_btnArea addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnArea addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpOutside];
        [_btnArea addTarget:self action:@selector(touchToSelectArea:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnArea;
}
- (UITextField *)fieldDetailAddr {
    if (_fieldDetailAddr == nil) {
        _fieldDetailAddr = [[UITextField alloc] initWithFrame:CGRectZero];
        _fieldDetailAddr.placeholder = @"(必输)请输入详细街区地址";
        _fieldDetailAddr.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _fieldDetailAddr.layer.borderWidth = 1;
        [_fieldDetailAddr setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)]];
        [_fieldDetailAddr setLeftViewMode:UITextFieldViewModeAlways];
    }
    return _fieldDetailAddr;
}
- (UIButton *)btnSure {
    if (_btnSure == nil) {
        _btnSure = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnSure setTitle:@"确定" forState:UIControlStateNormal];
        [_btnSure setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnSure.layer.cornerRadius = 8.0;
        [_btnSure setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        
        [_btnSure addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnSure addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpOutside];
        [_btnSure addTarget:self action:@selector(touchToSaveDetails:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSure;
}
- (DynamicPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[DynamicPickerView alloc] initWithFrame:CGRectZero];
        [_pickerView setDelegate:self];
    }
    return _pickerView;
}

@end
