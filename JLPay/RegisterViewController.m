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
#import "ASIFormDataRequest.h"
#import "JLActivitor.h"
#import "Define_Header.h"


@interface RegisterViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,
                                     UINavigationControllerDelegate,
                                     ASIHTTPRequestDelegate,
                                     RgBasicInfoTableViewCellDelegate, RgImageTableViewCellDelegate, RgAddrTableViewCellDelegate,
                                     CustomPickerViewDelegate>
@property (nonatomic, retain) ASIFormDataRequest* httpRequest;
@property (nonatomic, strong) NSMutableArray* cellTitles;
@property (nonatomic, strong) NSMutableArray* textCellDataAttri;
@property (nonatomic, strong) NSMutableArray* imageCellDataAttri;
@property (nonatomic, strong) NSMutableDictionary* dictDetailPlace;     // keys: province,city,area,detail

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIButton* btnRegister;
@property (nonatomic) int placeType;                                    // 0:province,1:city,2:area,3:detail
@property (nonatomic, strong) RgImageTableViewCell* cellBeingLoading;
@property (nonatomic, strong) RgAddrTableViewCell* cellAddr;
@property (nonatomic, strong) CustomPickerView* pickerView;
@property (nonatomic) int logCount;
@property (nonatomic) CGRect activitorFrame;
@end

@implementation RegisterViewController
@synthesize httpRequest = _httpRequest;
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
@synthesize activitorFrame;

#pragma mask ---- ASIFormDataRequest function & delegate
// http 接收成功
- (void) requestFinished:(ASIHTTPRequest *)request {
    [[JLActivitor sharedInstance] stopAnimating];
    NSLog(@"http响应结果:[%@]",[request responseString]);
    NSData* data = [request responseData];
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString* code = [dict valueForKey:@"code"];
    NSString* msg = [dict valueForKey:@"message"];
    if ([code intValue] == 0) {
        [self alertShowForMessage:@"注册成功!"];
    }
    else {
        [self alertShowForMessage:[NSString stringWithFormat:@"注册失败[%@]:%@",code,msg]];
    }
    [self requestClear];
}
// http 接收失败
- (void) requestFailed:(ASIHTTPRequest *)request {
    [[JLActivitor sharedInstance] stopAnimating];
    [self requestClear];
    [self alertShowForMessage:@"网络异常,请检查网络"];
}
// 填充 post body
- (void) requestPacking {
    // basic info
    [self packingBasicInfo];
    // addr info
    [self packingAddrInfo];
    // image info
    [self packingImageInfo];
    [self.httpRequest buildPostBody];
}
// 发起 request 请求
- (void) requestStart {
    NSLog(@"http 请求:[%@]",[self.httpRequest requestHeaders]);
    [self.httpRequest startAsynchronous];
}
// 释放 request
- (void) requestClear {
    [self.httpRequest clearDelegatesAndCancel];
    self.httpRequest = nil;
}
// 校验输入的信息是否合法
- (BOOL) packingChecking {
    NSString* password = nil;
    NSString* checkPwd = nil;
    // 检查textField的项是否为空
    for (NSDictionary* dict in self.textCellDataAttri) {
        NSString* flag = [dict valueForKey:@"needInputFlag"];
        NSString* input = [dict valueForKey:@"textInputed"];
        if ([flag isEqualToString:@"YES"] && (!input || input.length == 0)) {
            [self alertShowForMessage:[NSString stringWithFormat:@"%@不能为空",[dict valueForKey:@"title"]]];
            return NO;
        }
        if ([[dict valueForKey:@"title"] isEqualToString:@"登陆密码"]) {
            password = input;
        }
        if ([[dict valueForKey:@"title"] isEqualToString:@"确认密码"]) {
            checkPwd = input;
        }
    }
    // 密码是否一致
    if (![password isEqualToString:checkPwd]) {
        [self alertShowForMessage:@"密码输入不一致"];
        return NO;
    }
    // 地址信息是否为空
    NSString* sProvince = [self.dictDetailPlace valueForKey:@"province"];
    NSString* sCity = [self.dictDetailPlace valueForKey:@"city"];
    NSString* detailPlace = [self.dictDetailPlace valueForKey:@"detail"];
    if (!sProvince || sProvince.length == 0) {
        [self alertShowForMessage:@"地址输入错误:省份不能为空"];
        return NO;
    }
    if (!sCity || sCity.length == 0) {
        [self alertShowForMessage:@"地址输入错误:市不能为空"];
        return NO;
    }
    if (!detailPlace || detailPlace.length == 0) {
        [self alertShowForMessage:@"地址输入错误:详细地址不能为空"];
        return NO;
    }
    // 图片是否为空
    for (NSDictionary* dict in self.imageCellDataAttri) {
        NSString* loaded = [dict valueForKey:@"loaded"];
        NSData* imageData = [dict objectForKey:@"uploadImage"];
        NSString* imageName = [dict valueForKey:@"title"];
        if (![loaded isEqualToString:@"YES"] || !imageData) {
            [self alertShowForMessage:[NSString stringWithFormat:@"%@图片未选择",imageName]];
            return NO;
        }
    }
    return YES;
}
// 提取基本信息 basic info:有可选跟必选的区别
- (void) packingBasicInfo {
    for (NSDictionary* dict in self.textCellDataAttri) {
        NSString* textValue = [dict valueForKey:@"textInputed"];
        if ([[dict valueForKey:@"title"] isEqualToString:@"确认密码"]) {
            // 确认密码不打包
        } else {
            if (textValue && textValue.length > 0) {                
                [self.httpRequest setPostValue:textValue forKey:[dict valueForKey:@"textKey"]];
            }
        }
    }
}
// 提取基本信息 image info:必选
- (void) packingImageInfo {
    for (NSDictionary* dict in self.imageCellDataAttri) {
        [self.httpRequest setData:[dict objectForKey:@"uploadImage"]
                     withFileName:[NSString stringWithFormat:@"%@.png",[dict valueForKey:@"imageKey"]]
                   andContentType:@"image/png"
                           forKey:[dict valueForKey:@"imageKey"]];
    }
}
// 提取基本信息 addr info:区县可选
- (void) packingAddrInfo {
    NSMutableString* detailPlaces = [[NSMutableString alloc] init];
    NSString* sProvince = [self.dictDetailPlace valueForKey:@"province"];
    NSString* sCity = [self.dictDetailPlace valueForKey:@"city"];
    NSString* sArea = [self.dictDetailPlace valueForKey:@"area"];
    NSString* detailPlace = [self.dictDetailPlace valueForKey:@"detail"];
    NSString* areaCode = [self.dictDetailPlace valueForKey:@"areaCode"];
    // 详细地址
    [detailPlaces appendString:sProvince];
    [detailPlaces appendString:sCity];
    if (sArea && sArea.length > 0) {
        [detailPlaces appendString:sArea];
    }
    [detailPlaces appendString:detailPlace];
    [self.httpRequest setPostValue:detailPlaces forKey:@"addr"];
    // 地区代码: 如果有区县就用区县，否则用市
    if (areaCode == nil || areaCode.length == 0) {
        areaCode = [self.dictDetailPlace valueForKey:@"cityCode"];
    }
    [self.httpRequest setPostValue:areaCode forKey:@"areaNo"];
}

#pragma mask ---- CustomPickerViewDelegate
- (void)pickerViewDidChooseDatas:(NSDictionary *)dataDictionary {
    NSString* value = [dataDictionary valueForKey:@"array0"];
    NSString* key = [value substringFromIndex:[value rangeOfString:@"("].location + 1];
    key = [key substringToIndex:[key rangeOfString:@")"].location];
    value = [value substringToIndex:[value rangeOfString:@"("].location];
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

#pragma mask ---- RgImageTableViewCellDelegate
- (void)imageCell:(RgImageTableViewCell *)imageCell loadingImageAtCellTitle:(NSString *)textTitle {
    self.cellBeingLoading = imageCell;
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    [actionSheet addButtonWithTitle:@"拍摄"];
    [actionSheet addButtonWithTitle:@"从相册选择"];
    [actionSheet showInView:self.view];
}

#pragma mask ---- RgBasicInfoTableViewCellDelegate
- (void)textBeInputedInCellTitle:(NSString *)textTitle inputedText:(NSString *)text{
    for (NSDictionary* dict in self.textCellDataAttri) {
        if ([[dict valueForKey:@"title"] isEqualToString:textTitle]) {
            [dict setValue:text forKey:@"textInputed"];
        }
    }
}
#pragma mask ---- RgAddrTableViewCellDelegate
- (void)addrCell:(RgAddrTableViewCell *)addrCell choosePlaceInType:(int)placeType {
    if (self.cellAddr != addrCell) {
        self.cellAddr = addrCell;
    }
    self.placeType = placeType;
    NSString* sqlString = nil;
    if (placeType == 0) {
        sqlString = @"select value,key from cst_sys_param where owner = 'PROVINCE' and descr = '156'";
    } else if (placeType == 1) {
        sqlString = [NSString stringWithFormat:@"select value,key from cst_sys_param where owner = 'CITY' and descr = '%@'",[self.dictDetailPlace valueForKey:@"provinceCode"]];
    } else if (placeType == 2) {
        sqlString = [NSString stringWithFormat:@"select value,key from cst_sys_param where owner = 'AREA' and descr = '%@'",[self.dictDetailPlace valueForKey:@"cityCode"]];
    }
    NSArray* selectedDatas = [[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:sqlString];
    NSMutableDictionary* dataDict = [[NSMutableDictionary alloc] init];
    NSMutableArray* datas = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in selectedDatas) {
        NSString* string = [NSString stringWithFormat:@"%@(%@)",[PublicInformation clearSpaceCharAtLastOfString:[dict valueForKey:@"VALUE"]],[dict valueForKey:@"KEY"]];
        [datas addObject:string];
    }
    [dataDict setObject:datas forKey:@"array0"];
    if (datas.count > 0) {
        [self.pickerView showWithData:dataDict];
    } else {
        NSString* placeString = nil;
        if (placeType == 0) {
            placeString = @"省份";
        } else if (placeType == 1) {
            placeString = @"城市";
        } else if (placeType == 2) {
            placeString = @"区县";
        }
        [self alertShowForMessage:[NSString stringWithFormat:@"%@数据为空",placeString]];
    }
}
- (void)addrCell:(RgAddrTableViewCell *)addrCell inputedDetailPlace:(NSString *)detailPlace {
    [self.dictDetailPlace setValue:detailPlace forKey:@"detail"];
}


#pragma mask ---- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    // 获取图片
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [PublicInformation imageScaledBySourceImage:image withWidthScale:0.1 andHeightScale:0.1];

    // 保存image到字典
    for (NSMutableDictionary* dict in self.imageCellDataAttri) {
        if ([[dict objectForKey:@"title"] isEqualToString:[self.cellBeingLoading labelTitle]]) {
            [dict setObject:@"YES" forKey:@"loaded"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSData* imageData = UIImagePNGRepresentation(image);
                [dict setObject:imageData forKey:@"uploadImage"];
            });
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
    NSString* celltitle = [self.cellTitles objectAtIndex:indexPath.row];
    CGFloat rowHeight = tableView.rowHeight;
    if ([celltitle isEqualToString:@"详细地址"]) {
        rowHeight = tableView.rowHeight * 3;
    } else if ([celltitle isEqualToString:@"身份证(正)"]) {
        rowHeight =  tableView.rowHeight * 3;
    } else if ([celltitle isEqualToString:@"身份证(反)"]) {
        rowHeight =  tableView.rowHeight * 3;
    } else if ([celltitle isEqualToString:@"手持身份证"]) {
        rowHeight =  tableView.rowHeight * 3;
    } else if ([celltitle isEqualToString:@"银行卡(正)"]) {
        rowHeight =  tableView.rowHeight * 3;
    }
    return rowHeight;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
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
    // 根据cell 的标题获取对应的数据字典
    for (NSDictionary* dict in self.textCellDataAttri) {
        NSString* dictTitle = [dict valueForKey:@"title"];
        if ([dictTitle isEqualToString:cellTitle]) {
            dataDict = dict;
            break;
        }
    }
    // 根据字典的值设置cell 的部分属性值
    if (dataDict) {
        [cell setTitleText:cellTitle];
        if ([[dataDict objectForKey:@"needInputFlag"] isEqualToString:@"YES"]) {
            cell.mustBeInputed = YES;
        } else {
            cell.mustBeInputed = NO;
        }
        [cell setTextPlaceholder:[dataDict objectForKey:@"textPlaceholder"]];
        NSString* text = [dataDict valueForKey:@"textInputed"];
        if (text && text.length > 0) {
            [cell setText:text]; // 如果有输入的值，就设置到 cell 的 textField 中
        }
        // 登陆密码要设置密码遮蔽模式
        if ([cellTitle isEqualToString:@"登陆密码"] || [cellTitle isEqualToString:@"确认密码"]) {
            [cell setSecureEntry:YES];
        }
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
        [cell setDelegate:self];
    }
    // 加载信息
    NSString* province = [self.dictDetailPlace valueForKey:@"province"];
    NSString* city = [self.dictDetailPlace valueForKey:@"city"];
    NSString* detail = [self.dictDetailPlace valueForKey:@"detail"];
    if (province && province.length > 0) {
        [cell setProvince:province];
    }
    if (city && city.length > 0) {
        [cell setCity:city];
    }
    if (detail && detail.length > 0) {
        [cell setDetailPlace:detail];
    }
    return cell;
}
// 创建并装载cell : imageCell
- (UITableViewCell*) cellImageLoadingByTitle:(NSString*)cellTitle {
    NSString* cellIdentifier = @"imageCell";
    RgImageTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[RgImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
    if([self packingChecking]) {
        [self requestPacking];
        [[JLActivitor sharedInstance] startAnimatingInFrame:self.activitorFrame];
        [self requestStart];
    }
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
    if (self.packageType == 1 || self.packageType == 2) {
        [self loadingLastRegisterInfo];
    }
    CGFloat stateHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat navigationHeight =  self.navigationController.navigationBar.bounds.size.height;
    self.activitorFrame = CGRectMake(0,
                                     navigationHeight + stateHeight,
                                     self.view.bounds.size.width,
                                     self.view.bounds.size.height - navigationHeight - stateHeight);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat stateHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat navigationHeight =  self.navigationController.navigationBar.bounds.size.height;
    CGFloat btnheight = 50;
    CGFloat inset = 10;
    CGRect frame = CGRectMake(0,
                              navigationHeight + stateHeight,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height - navigationHeight - stateHeight - inset*2 - btnheight);
    // 列表视图
    self.tableView.frame = frame;
    // 注册按钮
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset;
    frame.size.width = self.view.bounds.size.width - inset*2;
    frame.size.height = btnheight;
    self.btnRegister.frame = frame;
    // pickerView
    frame.origin.x = 0;
    frame.origin.y = navigationHeight + stateHeight;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = self.view.bounds.size.height - navigationHeight - stateHeight;
    self.pickerView.frame = frame;
    // 界面标题
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
        if (self.packageType == 0 ) {
            self.title = @"商户注册";
        } else if (self.packageType == 2 || self.packageType == 1) {
            self.title = @"商户信息修改";
        }
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endingCellEditing)];
    [self.view addGestureRecognizer:recognizer];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.httpRequest != nil) {
        [self requestClear];
    }
    [[JLActivitor sharedInstance] stopAnimating];
}
/* 
 * 如果是要修改注册信息或修改商户信息:要加载旧的注册信息
 *   - 目前只有基本信息会返回并加载
 */
- (void) loadingLastRegisterInfo {
    // basic info
    for (NSDictionary* dict in self.textCellDataAttri) {
        NSString* key = [NSString stringWithFormat:@"RESIGN_%@",[dict valueForKey:@"textKey"]];
        NSString* textFieldText = [[NSUserDefaults standardUserDefaults] valueForKey:key];
        if (textFieldText && textFieldText.length > 0) {
            [dict setValue:textFieldText forKey:@"textInputed"];
        }
    }
    // addr info - detail
    NSString* addr = [[NSUserDefaults standardUserDefaults] valueForKey:@"RESIGN_addr"];
    NSString* areaNo = [[NSUserDefaults standardUserDefaults] valueForKey:@"RESIGN_areaNo"];
    if (addr && addr.length > 0) {
        [self.dictDetailPlace setValue:addr forKey:@"detail"];
    }
    // addr info - province/city/area
    if (areaNo && areaNo.length > 0) {
        [self analyseAreaCode:areaNo];
    }
}
- (void) analyseAreaCode:(NSString*)code {
    // 判断是县的code还是city 的code
    /*
     * 从最低级开始
     *     一级一级的查询出 value,key,descr
     *     并一级一级的设置对应的字典值:
     */
    NSArray* dataArray = nil;
    NSString* sqlString = @"select value,descr from cst_sys_param ";
    int leval = ([code intValue]%10 > 0)?(1):(2); // 1:县, 2:市, 3:省
    // 县
    if (leval == 1) {
        [self.dictDetailPlace setValue:code forKey:@"areaCode"];
        NSString* sql = [sqlString stringByAppendingString:[NSString stringWithFormat:@"where owner = 'AREA' and key = '%@'",code]];
        // 查询数据
        dataArray = [[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:sql];
        if (dataArray && dataArray.count > 0) {
            NSDictionary* dict = [dataArray objectAtIndex:0];
            [self.dictDetailPlace setValue:[dict valueForKey:@"VALUE"] forKey:@"area"];
            code = [dict valueForKey:@"DESCR"];
        }
        leval++;
    }
    // 市
    [self.dictDetailPlace setValue:code forKey:@"cityCode"];
    NSString* sql = [sqlString stringByAppendingString:[NSString stringWithFormat:@"where owner = 'CITY' and key = '%@'",code]];
    dataArray = [[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:sql];
    if (dataArray && dataArray.count > 0) {
        NSDictionary* dict = [dataArray objectAtIndex:0];
        [self.dictDetailPlace setValue:[dict valueForKey:@"VALUE"] forKey:@"city"];
        code = [dict valueForKey:@"DESCR"];
    }
    leval++;
    // 省
    [self.dictDetailPlace setValue:code forKey:@"provinceCode"];
    sql = [sqlString stringByAppendingString:[NSString stringWithFormat:@"where owner = 'PROVINCE' and key = '%@'",code]];
    dataArray = [[MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME_AREACODE] selectedDatasWithSQLString:sql];
    if (dataArray && dataArray.count > 0) {
        NSDictionary* dict = [dataArray objectAtIndex:0];
        [self.dictDetailPlace setValue:[dict valueForKey:@"VALUE"] forKey:@"province"];
    }
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


// 简化代码
- (void) alertShowForMessage:(NSString*)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mask ---- getter & setter
- (ASIFormDataRequest *)httpRequest {
    if (_httpRequest == nil) {
        NSString* URLString = [NSString stringWithFormat:@"http://%@:%@/jlagent/",[PublicInformation getDataSourceIP],[PublicInformation getDataSourcePort]];
        if (self.packageType == 0) { // 注册 MchntRegister
            URLString = [URLString stringByAppendingString:@"MchntRegister"];
        } else if (self.packageType == 1 || self.packageType == 2) { // 注册修改 MchntModify
            URLString = [URLString stringByAppendingString:@"MchntModify"];
        }
        _httpRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:URLString]];
        [_httpRequest setPostFormat:ASIMultipartFormDataPostFormat];
        [_httpRequest setRequestMethod:@"POST"];
        [_httpRequest setStringEncoding:NSUTF8StringEncoding];
        [_httpRequest setDelegate:self];
    }
    return _httpRequest;
}
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView setTableFooterView:view];
        [_tableView setRowHeight:45.0];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
    }
    return _tableView;
}
- (UIButton *)btnRegister {
    if (_btnRegister == nil) {
        _btnRegister = [[UIButton alloc] initWithFrame:CGRectZero];
        if (self.packageType == 0 ) { // 注册 MchntRegister
            [_btnRegister setTitle:@"注册" forState:UIControlStateNormal];
        } else if (self.packageType == 2 || self.packageType == 1) { // 注册修改 MchntModify
            [_btnRegister setTitle:@"修改" forState:UIControlStateNormal];
        }
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
        [_cellTitles addObject:@"用户名"];
        [_cellTitles addObject:@"登陆密码"];
        [_cellTitles addObject:@"确认密码"];
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
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"用户名" needInputFlag:@"YES" textPlaceholder:@"不超过40位字母或数字字符" textKey:@"userName"]];
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"登陆密码" needInputFlag:@"YES" textPlaceholder:@"请输入8位字母或数字" textKey:@"passWord"]];
        [_textCellDataAttri addObject:[self newDictionaryWithTitle:@"确认密码" needInputFlag:@"YES" textPlaceholder:@"请重新输入登陆密码" textKey:@"checkingPWD"]];
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
