//
//  UserRegisterViewController.m
//  JLPay
//
//  Created by jielian on 15/8/6.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "UserRegisterViewController.h"
#import "PublicInformation.h"
#import "TextFieldCell.h"
#import "DoubleFieldCell.h"
#import "TextLabelCell.h"
#import "ImageViewCell.h"
#import "DetailAreaViewController.h"


@interface UserRegisterViewController()
<UITableViewDataSource, UITableViewDelegate, TextFieldCellDelegate, UIActionSheetDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSInteger rowCellImageNeedPicking;
}
@property (nonatomic, strong) UIButton* registerButton;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray* arrayBasicInfo;
@property (nonatomic, strong) NSArray* arrayAccountInfo;
@property (nonatomic, strong) NSArray* arrayImageInfo;

@end

/*** cell数据源KEY定义区 ***/

// -- 基本信息
NSString* KeyBasicInfoTitleString = @"KeyBasicInfoTitleString__"; // 标题
NSString* KeyBasicInfoPlaceHolderString = @"KeyBasicInfoPlaceHolderString__"; // 输入框的提示信息
NSString* KeyBasicInfoMustInputBool = @"KeyBasicInfoMustInputBool__"; // 必输标志
NSString* KeyBasicInfoTextString = @"KeyBasicInfoTextString__"; // 文本(详细地址)
NSString* KeyBasicInfoSecurityBool = @"KeyBasicInfoSecurityBool__"; // 必输标志


NSString* KeyBasicInfoProvinceString = @"KeyBasicInfoProvinceString__"; // 省名
NSString* KeyBasicInfoCityString = @"KeyBasicInfoCityString__"; // 市名
NSString* KeyBasicInfoAreaString = @"KeyBasicInfoAreaString__"; // 区县名
NSString* KeyBasicInfoAreaCodeString = @"KeyBasicInfoAreaCodeString__"; // 地区代码(市或区县)

// -- 账户信息
NSString* KeyAccountInfoTitleString = @"KeyAccountInfoTitleString__"; // 标题
NSString* KeyAccountInfoPlaceHolderString = @"KeyAccountInfoPlaceHolderString__"; // 输入框的提示信息
NSString* KeyAccountInfoMustInputBool = @"KeyAccountInfoMustInputBool__"; // 必输标志
NSString* KeyAccountInfoTextString = @"KeyAccountInfoTextString__"; // 文本

//NSString* KeyBankNoInfoTitleString = @"KeyBankNoInfoTitleString__"; // 标题
NSString* KeyAccountInfoBankNoSettedBool = @"KeyAccountInfoBankNoSettedBool__"; // 已输标记
NSString* KeyAccountInfoBankNoString = @"KeyAccountInfoBankNoString__"; // 联行号
NSString* KeyAccountInfoBankNameText = @"KeyAccountInfoBankNameText__"; // 开户行全名


// -- 图片信息
NSString* KeyImageInfoTitleString = @"KeyImageInfoTitleString__"; // 标题
NSString* KeyImageInfoImage = @"KeyImageInfoImage__"; // 图片
NSString* KeyImageInfoImageNameString = @"KeyImageInfoImageNameString__"; // 图片名字
NSString* KeyImageInfoSettedBool = @"KeyImageInfoSettedBool__"; // 已设置图片标志


/*** cell标识名定义 ***/
NSString* IdentifierCellBasicField = @"IdentifierCellBasicField__"; // 基本信息
NSString* IdentifierCellAccountField = @"IdentifierCellAccountField__"; // 账户信息
NSString* IdentifierCellAreaLabel = @"IdentifierCellAreaLabel__"; // 地区
NSString* IdentifierCellImageView = @"IdentifierCellImageView__"; // 图片
NSString* IdentifierCellDoubeField = @"IdentifierCellDoubeField__"; // 开户行信息

@implementation UserRegisterViewController
@synthesize registerButton = _registerButton;
@synthesize tableView = _tableView;

#pragma mask ------ UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    if (section == 0) number = self.arrayBasicInfo.count;
    else if (section == 1) number = self.arrayAccountInfo.count;
    else if (section == 2) number = self.arrayImageInfo.count;
    return number;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseIdentifier = [self identifierCellAtIndexPath:indexPath];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [self cellForIdentifier:reuseIdentifier];
        [cell setFrame:[tableView rectForRowAtIndexPath:indexPath]];
    }
    [self settingAttributesOfCell:cell onIdentifier:reuseIdentifier onIndexPath:indexPath];
    
    return cell;
}

/* Header 的高度定义 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}
/* cell 的高度 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return HEIGHT_IMAGEVIEW_CELL;
    }
    else if (indexPath.section == 0) {
        return HEIGHT_FIELD_CELL;
    }
    else {
        if (indexPath.row == 0) {
            return HEIGHT_DOUBLEFIELD_CELL;
        } else {
            return HEIGHT_FIELD_CELL;
        }
    }
}


/* section 的标题定义 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect inframe = CGRectMake(0, 0, tableView.frame.size.width, [tableView rectForHeaderInSection:section].size.height);
    UILabel* label = [[UILabel alloc] initWithFrame:inframe];
    if (section == 0) {
        label.text = @"  1.基本信息";
    }
    else if (section == 1) {
        label.text = @"  2.账户信息";
    }
    else if (section == 2) {
        label.text = @"  3.证件图片";
    }
    return label;
}


#pragma mask ------ UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* reuseIdentifier = [self identifierCellAtIndexPath:indexPath];
    // 点击cell: 详细地址
    if ([reuseIdentifier isEqualToString:IdentifierCellAreaLabel]) {
        UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DetailAreaViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"detailAreaVC"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    // 点击cell: 图片加载
    else if ([reuseIdentifier isEqualToString:IdentifierCellImageView]) {
        rowCellImageNeedPicking = indexPath.row;
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:[self titleAtIndexPath:indexPath]
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil, nil];
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            [actionSheet addButtonWithTitle:@"拍摄"];
        }
        [actionSheet addButtonWithTitle:@"从相册选择"];
        [actionSheet showInView:self.view];
    }
}




#pragma mask ------ TextFieldCellDelegate
- (void)tableViewCell:(id)cell didInputedText:(NSString *)text {
    TextFieldCell* tableCell = (TextFieldCell*)cell;
    if ([tableCell.reuseIdentifier isEqualToString:IdentifierCellBasicField]) {
        NSMutableDictionary* infoNode = [self infoNodeOfBasicAtTitle:tableCell.title];
        if (infoNode) {
            [infoNode setValue:text forKey:KeyBasicInfoTextString];
        }
    }
    else if ([tableCell.reuseIdentifier isEqualToString:IdentifierCellAccountField]) {
        NSMutableDictionary* infoNode = [self infoNodeOfAccountAtTitle:tableCell.title];
        if (infoNode) {
            [infoNode setValue:text forKey:KeyAccountInfoTextString];
        }
    }
}
- (NSMutableDictionary*) infoNodeOfBasicAtTitle:(NSString*)title {
    NSMutableDictionary* infoNode = nil;
    for (NSMutableDictionary* dict in self.arrayBasicInfo) {
        if ([title isEqualToString:[dict valueForKey:KeyBasicInfoTitleString]]) {
            infoNode = dict;
            break;
        }
    }
    return infoNode;
}
- (NSMutableDictionary*) infoNodeOfAccountAtTitle:(NSString*)title {
    NSMutableDictionary* infoNode = nil;
    for (NSMutableDictionary* dict in self.arrayAccountInfo) {
        if ([title isEqualToString:[dict valueForKey:KeyAccountInfoTitleString]]) {
            infoNode = dict;
            break;
        }
    }
    return infoNode;
}


#pragma mask ------ UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    NSString* btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([btnTitle isEqualToString:@"取消"]) {
        return;
    }
    else if ([btnTitle isEqualToString:@"拍摄"]) {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else if ([btnTitle isEqualToString:@"从相册选择"]) {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
    [imagePickerController setDelegate:self];
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}
#pragma mask ------ UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage* imagePicked = [info objectForKey:UIImagePickerControllerOriginalImage];
    imagePicked = [PublicInformation imageScaledBySourceImage:imagePicked withWidthScale:0.1 andHeightScale:0.1];
    // 将图片保存到数据源
    [self setImageInfoWithImage:imagePicked atIndex:rowCellImageNeedPicking];
    // 重载表格视图
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:rowCellImageNeedPicking inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mask ------ 按钮点击事件
- (IBAction) touchDown:(UIButton*)sender {
    sender.transform = CGAffineTransformMakeScale(0.95, 0.95);
}
- (IBAction) touchOut:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
}
- (IBAction) touchToRegister:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    [self printLogBasicInfo];
    [self printLogAccountInfo];
    [self printLogImageInfo];
}





#pragma mask ------ tabel cell 的初始化及属性设置
/* 初始化cell */
- (UITableViewCell*) cellForIdentifier:(NSString*)cellIdentifier {
    UITableViewCell* cell = nil;
    if ([cellIdentifier isEqualToString:IdentifierCellBasicField] ||
        [cellIdentifier isEqualToString:IdentifierCellAccountField])
    {
        TextFieldCell* fieldCell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [fieldCell setDelegate:self];
        cell = fieldCell;
    }
    else if ([cellIdentifier isEqualToString:IdentifierCellAreaLabel]) {
        cell = [[TextLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else if ([cellIdentifier isEqualToString:IdentifierCellImageView]) {
        cell = [[ImageViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else if ([cellIdentifier isEqualToString:IdentifierCellDoubeField]) {
        cell = [[DoubleFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}

/* cell标示: 每个section不一样 */
- (NSString*) identifierCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* reuseIdentifierCell = nil;
    if (indexPath.section == 0) {
        if (indexPath.row == self.arrayBasicInfo.count - 1) {
            reuseIdentifierCell = IdentifierCellAreaLabel;
        } else {
            reuseIdentifierCell = IdentifierCellBasicField;
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            reuseIdentifierCell = IdentifierCellDoubeField;
        } else {
            reuseIdentifierCell = IdentifierCellAccountField;
        }
    }
    else if (indexPath.section == 2) {
        reuseIdentifierCell = IdentifierCellImageView;
    }
    return reuseIdentifierCell;
}

/* cell属性设置:标题、文本提示、密码标志、等 */
- (void) settingAttributesOfCell:(UITableViewCell*)cell
                    onIdentifier:(NSString*)identifier
                     onIndexPath:(NSIndexPath*)indexPath
{
    if ([identifier isEqualToString:IdentifierCellBasicField])
    {
        TextFieldCell* fieldCell = (TextFieldCell*)cell;
        [fieldCell setTitle:[self titleAtIndexPath:indexPath]];
        [fieldCell setPlaceHolder:[self placeHolderAtIndexPath:indexPath]];
        [fieldCell setMustInput:[self mustInputAtIndexPath:indexPath]];
        [fieldCell setSecureTextEntry:[self securityAtIndexPath:indexPath]];
    }
    else if ([identifier isEqualToString:IdentifierCellAccountField])
    {
        TextFieldCell* fieldCell = (TextFieldCell*)cell;
        [fieldCell setTitle:[self titleAtIndexPath:indexPath]];
        [fieldCell setPlaceHolder:[self placeHolderAtIndexPath:indexPath]];
        [fieldCell setMustInput:[self mustInputAtIndexPath:indexPath]];
    }
    else if ([identifier isEqualToString:IdentifierCellAreaLabel])
    {
        TextLabelCell* labelCell = (TextLabelCell*)cell;
        [labelCell setTitle:[self titleAtIndexPath:indexPath]];
        [labelCell setPlaceHolder:[self placeHolderAtIndexPath:indexPath]];
        [labelCell setMustInput:[self mustInputAtIndexPath:indexPath]];
    }
    else if ([identifier isEqualToString:IdentifierCellImageView])
    {
        ImageViewCell* imageCell = (ImageViewCell*)cell;
        [imageCell setTitle:[self titleAtIndexPath:indexPath]];
        [imageCell setImageDisplay:[self imageAtIndexPath:indexPath]];
    }
    else if ([identifier isEqualToString:IdentifierCellDoubeField])
    {
        DoubleFieldCell* dFieldCell = (DoubleFieldCell*)cell;
        [dFieldCell setTitle:[self titleAtIndexPath:indexPath]];
        [dFieldCell setBankNum:[self bankNoAtIndexPath:indexPath]];
    }
}



#pragma mask ------ 数据源
/* 标题 */
- (NSString*) titleAtIndexPath:(NSIndexPath*)indexPath {
    NSString* sTitle = nil;
    if (indexPath.section == 0) {
        sTitle = [[self.arrayBasicInfo objectAtIndex:indexPath.row] valueForKey:KeyBasicInfoTitleString];
    }
    else if (indexPath.section == 1) {
        sTitle = [[self.arrayAccountInfo objectAtIndex:indexPath.row] valueForKey:KeyAccountInfoTitleString];
    }
    else if (indexPath.section == 2) {
        sTitle = [[self.arrayImageInfo objectAtIndex:indexPath.row] valueForKey:KeyImageInfoTitleString];
    }
    return sTitle;
}
/* 提示文本 */
- (NSString*) placeHolderAtIndexPath:(NSIndexPath*)indexPath {
    NSString* sPlaceHolder = nil;
    if (indexPath.section == 0) {
        sPlaceHolder = [[self.arrayBasicInfo objectAtIndex:indexPath.row] valueForKey:KeyBasicInfoPlaceHolderString];
    }
    else if (indexPath.section == 1) {
        sPlaceHolder = [[self.arrayAccountInfo objectAtIndex:indexPath.row] valueForKey:KeyAccountInfoPlaceHolderString];
    }
    return sPlaceHolder;
}
/* 必输标记 */
- (BOOL) mustInputAtIndexPath:(NSIndexPath*)indexPath {
    BOOL mustInput = YES;
    if (indexPath.section == 0) {
        mustInput = [[[self.arrayBasicInfo objectAtIndex:indexPath.row] valueForKey:KeyBasicInfoMustInputBool] boolValue];
    }
    else if (indexPath.section == 1) {
        mustInput = [[[self.arrayAccountInfo objectAtIndex:indexPath.row] valueForKey:KeyAccountInfoMustInputBool] boolValue];
    }
    return mustInput;
}
/* 文本密文显示标志 */
- (BOOL) securityAtIndexPath:(NSIndexPath*)indexPath {
    BOOL security = YES;
    security = [[[self.arrayBasicInfo objectAtIndex:indexPath.row] valueForKey:KeyBasicInfoSecurityBool] boolValue];
    return security;
}
/* 图片信息 */
- (UIImage*) imageAtIndexPath:(NSIndexPath*)indexPath {
    UIImage* image = nil;
    if (indexPath.section == 2) {
        image = [[self.arrayImageInfo objectAtIndex:indexPath.row] valueForKey:KeyImageInfoImage];
    }
    return image;
}
/* 联行号 */
- (NSString*) bankNoAtIndexPath:(NSIndexPath*)indexPath {
    NSString* bankNo = nil;
    if (indexPath.section == 1 && indexPath.row == 0) {
        bankNo = [[self.arrayAccountInfo objectAtIndex:indexPath.row] valueForKey:KeyAccountInfoBankNoString];
    }
    return bankNo;
}
/* 设置图片: 指定row */
- (void) setImageInfoWithImage:(UIImage*)image atIndex:(NSInteger)index {
    NSMutableDictionary* imageNode = [self.arrayImageInfo objectAtIndex:index];
    [imageNode setObject:image forKey:KeyImageInfoImage];
    [imageNode setObject:@(YES) forKey:KeyImageInfoSettedBool];
}

/* 详细地址设置:省名+市名(+区县名)+详细地址+areaCode */
- (void) setDetailAddr:(NSString*)detailAddr
            inProvince:(NSString*)province
               andCity:(NSString*)city
               andArea:(NSString*)area
           andAreaCode:(NSString*)areaCode
{
    // 设置数据源
    NSDictionary* addrInfo = [self infoDetailAddr];
    [addrInfo setValue:detailAddr forKey:KeyBasicInfoTextString];
    [addrInfo setValue:province forKey:KeyBasicInfoProvinceString];
    [addrInfo setValue:city forKey:KeyBasicInfoCityString];
    [addrInfo setValue:area forKey:KeyBasicInfoAreaString];
    [addrInfo setValue:areaCode forKey:KeyBasicInfoAreaCodeString];
    // 重置label地址
    NSMutableString* detailAddrs = [[NSMutableString alloc] init];
    if (province && province.length > 0) {
        [detailAddrs appendString:province];
    }
    if (city && city.length > 0) {
        [detailAddrs appendString:city];
    }
    if (area && area.length > 0) {
        [detailAddrs appendString:area];
    }
    if (detailAddr && detailAddr.length > 0) {
        [detailAddrs appendString:detailAddr];
    }
    [addrInfo setValue:detailAddrs forKey:KeyBasicInfoPlaceHolderString];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.arrayBasicInfo.count - 1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (NSDictionary*) infoDetailAddr {
    NSDictionary* info = nil;
    for (NSDictionary* dict in self.arrayBasicInfo) {
        if ([[dict valueForKey:KeyBasicInfoTitleString] isEqualToString:@"详细地址"]) {
            info = dict;
            break;
        }
    }
    return info;
}


/////// -- 打印数据
- (void) printLogBasicInfo {
    NSMutableString* logString = [NSMutableString stringWithString:@"----基本信息----\n"];
    for (NSDictionary* dict in self.arrayBasicInfo) {
        [logString appendString:@"{\n"];
        for (NSString* key in dict.allKeys) {
            [logString appendFormat:@"\t[%@:%@]\n",key,[dict valueForKey:key]];
        }
        [logString appendString:@"}\n"];
    }
    [logString appendString:@"----基本信息----"];
    NSLog(@"%@",logString);
}
- (void) printLogAccountInfo {
    NSMutableString* logString = [NSMutableString stringWithString:@"----账户信息----\n"];
    for (NSDictionary* dict in self.arrayAccountInfo) {
        [logString appendString:@"{\n"];
        for (NSString* key in dict.allKeys) {
            [logString appendFormat:@"\t[%@:%@]\n",key,[dict valueForKey:key]];
        }
        [logString appendString:@"}\n"];
    }
    [logString appendString:@"----账户信息----"];
    NSLog(@"%@",logString);
}
- (void) printLogImageInfo {
    NSMutableString* logString = [NSMutableString stringWithString:@"----图片信息----\n"];
    for (NSDictionary* dict in self.arrayImageInfo) {
        [logString appendString:@"{\n"];
        for (NSString* key in dict.allKeys) {
            [logString appendFormat:@"\t[%@:%@]\n",key,[dict valueForKey:key]];
        }
        [logString appendString:@"}\n"];
    }
    [logString appendString:@"----图片信息----"];
    NSLog(@"%@",logString);
}



#pragma mask ------ 界面声明周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"商户注册"];
    [self.view addSubview:self.registerButton];
    [self.view addSubview:self.tableView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem* backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(backToLastViewController)];
    [self.navigationItem setBackBarButtonItem:backBarButton];

    
    CGFloat statesNaviHeight = [PublicInformation returnStatusHeight] + self.navigationController.navigationBar.frame.size.height;
    CGFloat inset = 12;
    CGFloat btnHeight = 45;
    
    CGRect frame = CGRectMake(0,//inset,
                              statesNaviHeight,
                              self.view.frame.size.width,// - inset*2,
                              self.view.frame.size.height - statesNaviHeight - btnHeight - inset*2);
    
    [self.tableView setFrame:frame];
    
    frame.origin.x = inset;
    frame.origin.y += frame.size.height + inset;
    frame.size.width = self.view.frame.size.width - inset*2;
    frame.size.height = btnHeight;
    [self.registerButton setFrame:frame];
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

/* 回退到上一个场景 */
- (void) backToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

/* 初始图片 */
- (UIImage*) initialImage {
    return [UIImage imageNamed:@"camera"];
}
#pragma mask ---- getter
- (UIButton *)registerButton {
    if (_registerButton == nil) {
        _registerButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_registerButton setBackgroundColor:[PublicInformation returnCommonAppColor:@"red"]];
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        _registerButton.layer.cornerRadius = 5.0;
        
        [_registerButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_registerButton addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpOutside];
        [_registerButton addTarget:self action:@selector(touchToRegister:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSectionFooterHeight:10];
    }
    return _tableView;
}
- (NSArray *)arrayBasicInfo {
    if (_arrayBasicInfo == nil) {
        NSMutableArray* basicInfos = [[NSMutableArray alloc] init];
        NSArray* basicKeys = @[KeyBasicInfoTitleString,KeyBasicInfoPlaceHolderString,KeyBasicInfoMustInputBool,KeyBasicInfoTextString,KeyBasicInfoSecurityBool];
        NSArray* areaKeys = @[KeyBasicInfoTitleString,KeyBasicInfoPlaceHolderString,KeyBasicInfoMustInputBool,KeyBasicInfoTextString,KeyBasicInfoProvinceString,KeyBasicInfoCityString,KeyBasicInfoAreaString,KeyBasicInfoAreaCodeString];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"商户名称",@"不超过40位字符",@(YES),@"",@(NO), nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"登陆用户名",@"不超过40位字母或数字字符",@(YES),@"",@(NO), nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"登陆密码",@"请输入8位字母或数字字符",@(YES),@"",@(YES), nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"确认密码",@"请重新输入登陆密码",@(YES),@"",@(YES), nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"身份证号码",@"请输入15位或18位身份证号码",@(YES),@"",@(NO), nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"手机号码",@"请输入手机号码",@(YES),@"",@(NO), nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"邮箱",@"请输入有效的邮箱",@(NO),@"",@(NO), nil] forKeys:basicKeys]];
        [basicInfos addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"详细地址",@"请选择并输入商铺详细地址",@(YES),@"",@"",@"",@"",@"", nil] forKeys:areaKeys]];
        _arrayBasicInfo = [NSArray arrayWithArray:basicInfos];
    }
    return _arrayBasicInfo;
}
- (NSArray *)arrayAccountInfo {
    if (_arrayAccountInfo == nil) {
        NSMutableArray* accountInfos = [[NSMutableArray alloc] init];
        NSArray* keys = @[KeyAccountInfoTitleString,KeyAccountInfoPlaceHolderString,KeyAccountInfoMustInputBool,KeyAccountInfoTextString];
        NSArray* bankNoKeys = @[KeyAccountInfoTitleString,KeyAccountInfoBankNoSettedBool,KeyAccountInfoBankNoString,KeyAccountInfoBankNameText];
        [accountInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"开户行联行号",@(NO),@"查询",@"", nil] forKeys:bankNoKeys]];
        [accountInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"结算账户名",@"不超过40位字符",@(YES),@"", nil] forKeys:keys]];
        [accountInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"结算账号",@"不超过30位账号",@(YES),@"", nil] forKeys:keys]];
        [accountInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"代理商用户名",@"不超过20位字符",@(NO),@"", nil] forKeys:keys]];
        _arrayAccountInfo = [NSArray arrayWithArray:accountInfos];
    }
    return _arrayAccountInfo;
}
- (NSArray *)arrayImageInfo {
    if (_arrayImageInfo == nil) {
        NSMutableArray* imageInfos = [[NSMutableArray alloc] init];
        NSArray* keys = @[KeyImageInfoTitleString,KeyImageInfoImageNameString,KeyImageInfoSettedBool,KeyImageInfoImage];
        [imageInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"上传身份证照(正面)",@"03",@(NO),[self initialImage], nil] forKeys:keys]];
        [imageInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"上传身份证照(反面)",@"06",@(NO),[self initialImage], nil] forKeys:keys]];
        [imageInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"上传手持身份证照(正面)",@"09",@(NO),[self initialImage], nil] forKeys:keys]];
        [imageInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"上传结算银行卡照(正面)",@"08",@(NO),[self initialImage], nil] forKeys:keys]];
        _arrayImageInfo = [NSArray arrayWithArray:imageInfos];
    }
    return _arrayImageInfo;
}

@end
