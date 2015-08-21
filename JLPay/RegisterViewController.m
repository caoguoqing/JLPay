//
//  RegisterViewController.m
//  TestForRegister
//
//  Created by jielian on 15/8/17.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "RegisterViewController.h"
#import "RgBasicInfoTableViewCell.h"
#import "RgAddrTableViewCell.h"
#import "RgImageTableViewCell.h"
#import "CustomPickerView/CustomPickerView.h"
#import "MySQLiteManager.h"
#import "PublicInformation.h"


@interface RegisterViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,
                                     UINavigationControllerDelegate,
                                     RgBasicInfoTableViewCellDelegate, RgImageTableViewCellDelegate, RgAddrTableViewCellDelegate,
                                     CustomPickerViewDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* cellTitles;
@property (nonatomic, strong) NSMutableArray* textCellDataAttri;
@property (nonatomic, strong) NSMutableArray* imageCellDataAttri;
@property (nonatomic, strong) UIButton* btnRegister;
@property (nonatomic, strong) NSMutableDictionary* dictDetailPlace;     // keys: province,city,area,detail
@property (nonatomic) int placeType;                                    // 0:province,1:city,2:area,3:detail
@property (nonatomic, strong) RgImageTableViewCell* cellBeingLoading;
@property (nonatomic, strong) RgAddrTableViewCell* cellAddr;
@property (nonatomic, strong) CustomPickerView* pickerView;
@property (nonatomic) int logCount;
@end

@implementation RegisterViewController
@synthesize tableView = _tableView;
@synthesize cellTitles = _cellTitles;
@synthesize textCellDataAttri = _textCellDataAttri;
@synthesize imageCellDataAttri = _imageCellDataAttri;
@synthesize btnRegister = _btnRegister;
@synthesize dictDetailPlace = _dictDetailPlace;
@synthesize pickerView = _pickerView;
@synthesize cellAddr;
@synthesize logCount;
@synthesize cellBeingLoading;

#pragma mask ---- CustomPickerViewDelegate
- (void)pickerViewDidChooseDatas:(NSDictionary *)dataDictionary {
    NSString* value = [dataDictionary valueForKey:@"array0"];
    NSString* key = [value substringFromIndex:[value rangeOfString:@"("].location + 1];
    key = [key substringToIndex:[key rangeOfString:@")"].location];
    value = [value substringToIndex:[value rangeOfString:@"("].location];
    NSLog(@"已选择的数据[%@][%@]",value,key);
    if (self.placeType == 0) {
        if (![[self.cellAddr province] isEqualToString:value]) {
            [self.cellAddr setCity:@"市"];
            [self.cellAddr setArea:@"区/县"];
            [self.dictDetailPlace setValue:nil forKey:@"city"];
            [self.dictDetailPlace setValue:nil forKey:@"cityCode"];
            [self.dictDetailPlace setValue:nil forKey:@"area"];
            [self.dictDetailPlace setValue:nil forKey:@"areaCode"];
        }
        [self.cellAddr setProvince:value];
        [self.dictDetailPlace setObject:value forKey:@"province"];
        [self.dictDetailPlace setObject:key forKey:@"provinceCode"];
    } else if (self.placeType == 1) {
        if (![[self.cellAddr city] isEqualToString:value]) {
            [self.cellAddr setArea:@"区/县"];
            [self.dictDetailPlace setValue:nil forKey:@"area"];
            [self.dictDetailPlace setValue:nil forKey:@"areaCode"];
        }
        [self.cellAddr setCity:value];
        [self.dictDetailPlace setObject:value forKey:@"city"];
        [self.dictDetailPlace setObject:key forKey:@"cityCode"];

    } else if (self.placeType == 2) {
        [self.cellAddr setArea:value];
        [self.dictDetailPlace setObject:value forKey:@"area"];
        [self.dictDetailPlace setObject:key forKey:@"areaCode"];

    }
}


#pragma mask ---- RgAddrTableViewCellDelegate
- (void)addrCell:(RgAddrTableViewCell *)addrCell choosePlaceInType:(int)placeType {
    if (self.cellAddr != addrCell) {
        self.cellAddr = addrCell;
    }
    self.placeType = placeType;
    NSLog(@"点击了地区按钮:[%d]",placeType);
    NSString* sqlString = nil;
    if (placeType == 0) {
        sqlString = @"select value,key from cst_sys_param where owner = 'PROVINCE' and descr = '156'";
    } else if (placeType == 1) {
        sqlString = [NSString stringWithFormat:@"select value,key from cst_sys_param where owner = 'CITY' and descr = '%@'",[self.dictDetailPlace valueForKey:@"provinceCode"]];
    } else if (placeType == 2) {
        sqlString = [NSString stringWithFormat:@"select value,key from cst_sys_param where owner = 'AREA' and descr = '%@'",[self.dictDetailPlace valueForKey:@"cityCode"]];
    }
    NSLog(@"sql查询语句[%@]",sqlString);
    NSArray* selectedDatas = [[MySQLiteManager SQLiteManagerWithDBFile:@"test.db"] selectedDatasWithSQLString:sqlString];
    NSMutableDictionary* dataDict = [[NSMutableDictionary alloc] init];
    NSMutableArray* datas = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in selectedDatas) {
        NSString* string = [NSString stringWithFormat:@"%@(%@)",[PublicInformation clearSpaceCharAtLastOfString:[dict valueForKey:@"VALUE"]],[dict valueForKey:@"KEY"]];
        [datas addObject:string];
    }
    [dataDict setObject:datas forKey:@"array0"];
    [self.pickerView showWithData:dataDict];
}
- (void)addrCell:(RgAddrTableViewCell *)addrCell inputedDetailPlace:(NSString *)detailPlace {
    [self.dictDetailPlace setValue:detailPlace forKey:@"detail"];
}


#pragma mask ---- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    // 获取图片
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // 保存image到字典
    for (NSMutableDictionary* dict in self.imageCellDataAttri) {
        if ([[dict objectForKey:@"title"] isEqualToString:[self.cellBeingLoading labelTitle]]) {
            [dict setObject:@"YES" forKey:@"loaded"];
            [dict setObject:image forKey:@"uploadImage"];
            break;
        }
    }
    // 设置对应的imageView
    [self.cellBeingLoading setBackgroundImage:image];
}

#pragma mask ---- UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    if ([btnTitle isEqualToString:@"取消"]) {
        return;
    } else if ([btnTitle isEqualToString:@"拍摄"]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else if ([btnTitle isEqualToString:@"从相册选择"]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
    [self presentViewController:imagePicker animated:YES completion:^{}];
}

#pragma mask ---- RgImageTableViewCellDelegate
- (void)imageCell:(RgImageTableViewCell *)imageCell loadingImageAtCellTitle:(NSString *)textTitle {
    self.cellBeingLoading = imageCell;
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    [actionSheet addButtonWithTitle:@"拍摄"];
    [actionSheet addButtonWithTitle:@"从相册选择"];
    [actionSheet showFromToolbar:nil];
    
}

#pragma mask ---- RgBasicInfoTableViewCellDelegate 
- (void)textBeInputedInCellTitle:(NSString *)textTitle inputedText:(NSString *)text{
    for (NSDictionary* dict in self.textCellDataAttri) {
        if ([[dict valueForKey:@"title"] isEqualToString:textTitle]) {
            [dict setValue:text forKey:@"textInputed"];
        }
    }
    NSLog(@"textCellDataAttri=[%@]",self.textCellDataAttri);
}




#pragma mask ---- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellTitles.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellTitle = [self.cellTitles objectAtIndex:indexPath.row];
    UITableViewCell* cell = nil;
    if ([cellTitle isEqualToString:@"详细地址"]) {
        cell = [self cellAddrLoadingByTitle:cellTitle];
    } else if ([cellTitle isEqualToString:@"身份证(正)"]) {
        cell = [self cellImageLoadingByTitle:cellTitle];
    } else if ([cellTitle isEqualToString:@"身份证(反)"]) {
        cell = [self cellImageLoadingByTitle:cellTitle];
    } else if ([cellTitle isEqualToString:@"手持身份证"]) {
        cell = [self cellImageLoadingByTitle:cellTitle];
    } else if ([cellTitle isEqualToString:@"银行卡(正)"]) {
        cell = [self cellImageLoadingByTitle:cellTitle];
    } else {
        cell = [self cellBasicInfoLoadingByTitle:cellTitle];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.cellTitles objectAtIndex:indexPath.row] isEqualToString:@"详细地址"]) {
        return tableView.rowHeight * 3;
    } else if ([[self.cellTitles objectAtIndex:indexPath.row] isEqualToString:@"身份证(正)"]) {
        return tableView.rowHeight * 3;
    } else if ([[self.cellTitles objectAtIndex:indexPath.row] isEqualToString:@"身份证(反)"]) {
        return tableView.rowHeight * 3;
    } else if ([[self.cellTitles objectAtIndex:indexPath.row] isEqualToString:@"手持身份证"]) {
        return tableView.rowHeight * 3;
    } else if ([[self.cellTitles objectAtIndex:indexPath.row] isEqualToString:@"银行卡(正)"]) {
        return tableView.rowHeight * 3;
    } else {
        return tableView.rowHeight;
    }
}

// 创建并装载cell : basicInfoCell
- (UITableViewCell*) cellBasicInfoLoadingByTitle:(NSString*)cellTitle {
    NSString* cellIdentifier = @"basicInfoCell";
    RgBasicInfoTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[RgBasicInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:cellIdentifier
                                            andNeededInputFlag:YES];
        [cell setCellDelegate:self];
    }
    NSDictionary* dataDict = nil;
    for (NSDictionary* dict in self.textCellDataAttri) {
        NSString* dictTitle = [dict valueForKey:@"title"];
        if ([dictTitle isEqualToString:cellTitle]) {
            dataDict = dict;
            break;
        }
    }
    if (dataDict) {
        [cell setTitleText:cellTitle];
        if ([[dataDict objectForKey:@"needInputFlag"] isEqualToString:@"YES"]) {
            cell.mustBeInputed = YES;
        } else {
            cell.mustBeInputed = NO;
        }
        [cell setTextPlaceholder:[dataDict objectForKey:@"textPlaceholder"]];
    } else {
        NSLog(@"datadict 为空");
    }
    return cell;
}
// 创建并装载cell : addrCell
- (UITableViewCell*) cellAddrLoadingByTitle:(NSString*)cellTitle {
    NSString* cellIdentifier = @"addrCell";
    RgAddrTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[RgAddrTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        CGRect frame = cell.frame;
        frame.size.height = self.tableView.rowHeight * 3.0;
        cell.frame = frame;
        [cell setDelegate:self];
    }
    
    return cell;
}
// 创建并装载cell : imageCell
- (UITableViewCell*) cellImageLoadingByTitle:(NSString*)cellTitle {
    NSString* cellIdentifier = @"imageCell";
    RgImageTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[RgImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        CGRect frame = cell.frame;
        frame.size.height = self.tableView.rowHeight * 3.0;
        cell.frame = frame;
        [cell setDelegate:self];
    }
    [cell setLabelTitle:cellTitle];
    return cell;
}




#pragma mask ---- 按钮事件
- (IBAction) touchDown:(UIButton*)sender {
    sender.transform = CGAffineTransformMakeScale(0.95, 0.95);
}
- (IBAction) touchUpOutside:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;

}
- (IBAction) touchToRegister:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    NSLog(@"按钮事件结束");
}


#pragma mask ---- 界面生命周期事件
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.btnRegister];
    [self.view addSubview:self.pickerView];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.logCount = 0;
    self.cellBeingLoading = nil;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat navigationHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.bounds.size.height;
    CGFloat btnheight = 50;
    CGFloat inset = 10;
    CGRect frame = CGRectMake(0,
                              navigationHeight,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height - navigationHeight - inset*2 - btnheight);
    self.tableView.frame = frame;
    // 注册按钮
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset;
    frame.size.width = self.view.bounds.size.width - inset*2;
    frame.size.height = btnheight;
    self.btnRegister.frame = frame;
    
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
        self.title = @"商户注册";
    }
    // pickerView
    frame.origin.x = 0;
    frame.origin.y = navigationHeight;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = self.view.bounds.size.height - navigationHeight;
    self.pickerView.frame = frame;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endingCellEditing)];
    [self.view addGestureRecognizer:recognizer];
}



#pragma mask ---- private interface
// 隐藏键盘
- (void) endingCellEditing {
    NSInteger rowsCount = [self.tableView numberOfRowsInSection:0];
    for (int i = 0; i < rowsCount; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell class] == [RgBasicInfoTableViewCell class]) {
            RgBasicInfoTableViewCell* basicCell = (RgBasicInfoTableViewCell*)cell;
            if ([basicCell isTextEditing]) {
                [basicCell endingTextEditing];
                break;
            }
        }
        else if ([cell class] == [RgAddrTableViewCell class]) {
            RgAddrTableViewCell* basicCell = (RgAddrTableViewCell*)cell;
            if ([basicCell isTextEditing]) {
                [basicCell endingTextEditing];
                break;
            }
        }
    }
}

/* 有文本框的cell属性数据字典      -- dataSource
 * 1.title
 * 2.needInputFlag
 * 3.textPlaceholder
 * 4.textKey
 * 5.textInputed
 */
- (NSMutableDictionary*) newDictionaryWithTitle:(NSString*)title
                                  needInputFlag:(NSString*)needInputFlag
                                textPlaceholder:(NSString*)textPlaceholder
                                        textKey:(NSString*)textKey
{
    NSMutableDictionary* dataDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [dataDict setObject:title forKey:@"title"];
    [dataDict setObject:needInputFlag forKey:@"needInputFlag"];
    [dataDict setObject:textPlaceholder forKey:@"textPlaceholder"];
    [dataDict setObject:textKey forKey:@"textKey"];
    return dataDict;
}
/* 有图片的cell属性数据字典       -- dataSource
 * 1.title
 * 2.imageKey
 * 3.loaded
 * 4.uploadImage
 */
- (NSMutableDictionary*) newImageDictionaryWithTitle:(NSString*)title
                                             textKey:(NSString*)textKey
{
    NSMutableDictionary* dataDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [dataDict setObject:title forKey:@"title"];
    [dataDict setObject:textKey forKey:@"imageKey"];
    [dataDict setObject:@"NO" forKey:@"loaded"];
    return dataDict;
}



#pragma mask ---- getter & setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView setTableFooterView:view];
        [_tableView setRowHeight:45.0];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
    }
    return _tableView;
}
- (UIButton *)btnRegister {
    if (_btnRegister == nil) {
        _btnRegister = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnRegister setTitle:@"注册" forState:UIControlStateNormal];
        [_btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnRegister setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_btnRegister setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        [_btnRegister.layer setCornerRadius:8.0];
        _btnRegister.layer.shadowColor = [UIColor blackColor].CGColor;
        _btnRegister.layer.shadowOffset = CGSizeMake(3, 3);
        _btnRegister.layer.shadowOpacity = 1;
        [_btnRegister addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnRegister addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_btnRegister addTarget:self action:@selector(touchToRegister:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnRegister;
}

- (NSMutableArray *)cellTitles {
    if (_cellTitles == nil) {
        _cellTitles = [[NSMutableArray alloc] init];
        [_cellTitles addObject:@"商户名称"];
        [_cellTitles addObject:@"登陆账号"];
        [_cellTitles addObject:@"登陆密码"];
        [_cellTitles addObject:@"身份证号"];
        [_cellTitles addObject:@"手机号码"];
        [_cellTitles addObject:@"开户行名称"];
        [_cellTitles addObject:@"结算账户名"];
        [_cellTitles addObject:@"结算账号"];
        [_cellTitles addObject:@"邮箱"];
        [_cellTitles addObject:@"代理商用户"];
        
        [_cellTitles addObject:@"详细地址"];
        
        [_cellTitles addObject:@"身份证(正)"];
        [_cellTitles addObject:@"身份证(反)"];
        [_cellTitles addObject:@"手持身份证"];
        [_cellTitles addObject:@"银行卡(正)"];
    }
    return _cellTitles;
}
- (NSMutableArray *)textCellDataAttri {
    if (_textCellDataAttri == nil) {
        _textCellDataAttri = [[NSMutableArray alloc] init];
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"商户名称" needInputFlag:@"YES" textPlaceholder:@"不超过40位字符" textKey:@"mchntNm"]];
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"登陆账号" needInputFlag:@"YES" textPlaceholder:@"不超过40位字母或数字字符" textKey:@"userName"]];
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"登陆密码" needInputFlag:@"YES" textPlaceholder:@"请输入8位字母或数字" textKey:@"passWord"]];
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"身份证号" needInputFlag:@"YES" textPlaceholder:@"请输入二代身份证号码" textKey:@"identifyNo"]];
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"手机号码" needInputFlag:@"YES" textPlaceholder:@"请输入手机号" textKey:@"telNo"]];
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"开户行名称" needInputFlag:@"YES" textPlaceholder:@"不超过40位字符" textKey:@"speSettleDs"]];
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"结算账户名" needInputFlag:@"YES" textPlaceholder:@"不超过40位字符" textKey:@"settleAcctNm"]];
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"结算账号" needInputFlag:@"YES" textPlaceholder:@"请输入结算账号" textKey:@"settleAcct"]];
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"邮箱" needInputFlag:@"YES" textPlaceholder:@"请输入有效的邮箱" textKey:@"mail"]];
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"代理商用户" needInputFlag:@"NO" textPlaceholder:@"(选填)不超过20位'用户名'" textKey:@"ageUserName"]];
    }
    return _textCellDataAttri;
}
- (NSMutableArray *)imageCellDataAttri {
    if (_imageCellDataAttri == nil) {
        _imageCellDataAttri = [[NSMutableArray alloc] init];
        [_imageCellDataAttri addObject:[self newImageDictionaryWithTitle:@"身份证(正)" textKey:@"03"]];
        [_imageCellDataAttri addObject:[self newImageDictionaryWithTitle:@"身份证(反)" textKey:@"06"]];
        [_imageCellDataAttri addObject:[self newImageDictionaryWithTitle:@"手持身份证" textKey:@"08"]];
        [_imageCellDataAttri addObject:[self newImageDictionaryWithTitle:@"银行卡(正)" textKey:@"09"]];
    }
    return _imageCellDataAttri;
}
- (NSMutableDictionary *)dictDetailPlace {
    if (_dictDetailPlace == nil) {
        _dictDetailPlace = [NSMutableDictionary dictionaryWithCapacity:3+3+1];
        [_dictDetailPlace setValue:nil forKey:@"province"];
        [_dictDetailPlace setValue:nil forKey:@"city"];
        [_dictDetailPlace setValue:nil forKey:@"area"];
        [_dictDetailPlace setValue:nil forKey:@"provinceCode"];
        [_dictDetailPlace setValue:nil forKey:@"cityCode"];
        [_dictDetailPlace setValue:nil forKey:@"areaCode"];
        [_dictDetailPlace setValue:nil forKey:@"detail"];
    }
    return _dictDetailPlace;
}
-(CustomPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[CustomPickerView alloc] initWithFrame:CGRectZero delegate:self];
    }
    return _pickerView;
}

@end
