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
#import "TextLabelCell.h"
#import "DetailAreaViewController.h"


@interface UserRegisterViewController() <UITableViewDataSource, UITableViewDelegate, TextFieldCellDelegate>
@property (nonatomic, strong) UIButton* registerButton;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray* arrayBasicInfo;
@property (nonatomic, strong) NSArray* arrayAccountInfo;

@end

/*** cell数据源KEY定义区 ***/

// -- 基本信息
NSString* KeyBasicInfoTitleString = @"KeyBasicInfoTitleString__"; // 标题
NSString* KeyBasicInfoPlaceHolderString = @"KeyBasicInfoPlaceHolderString__"; // 输入框的提示信息
NSString* KeyBasicInfoMustInputBool = @"KeyBasicInfoMustInputBool__"; // 必输标志
NSString* KeyBasicInfoTextString = @"KeyBasicInfoTextString__"; // 文本(详细地址)

NSString* KeyBasicInfoProvinceString = @"KeyBasicInfoProvinceString__"; // 省名
NSString* KeyBasicInfoCityString = @"KeyBasicInfoCityString__"; // 市名
NSString* KeyBasicInfoAreaString = @"KeyBasicInfoAreaString__"; // 区县名
NSString* KeyBasicInfoAreaCodeString = @"KeyBasicInfoAreaCodeString__"; // 地区代码(市或区县)

// -- 账户信息
NSString* KeyAccountInfoTitleString = @"KeyAccountInfoTitleString__"; // 标题
NSString* KeyAccountInfoPlaceHolderString = @"KeyAccountInfoPlaceHolderString__"; // 输入框的提示信息
NSString* KeyAccountInfoMustInputBool = @"KeyAccountInfoMustInputBool__"; // 必输标志
NSString* KeyAccountInfoTextString = @"KeyAccountInfoTextString__"; // 文本




/*** cell标识名定义 ***/
NSString* IdentifierCellBasicField = @"IdentifierCellBasicField__"; // 基本信息
NSString* IdentifierCellAccountField = @"IdentifierCellAccountField__"; // 账户信息
NSString* IdentifierCellAreaLabel = @"IdentifierCellAreaLabel__"; // 地区
NSString* IdentifierCellImageView = @"IdentifierCellImageView__"; // 图片


@implementation UserRegisterViewController
@synthesize registerButton = _registerButton;
@synthesize tableView = _tableView;

#pragma mask ------ UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0)?(self.arrayBasicInfo.count):(self.arrayAccountInfo.count);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseIdentifier = [self identifierCellAtIndexPath:indexPath];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [self cellForIdentifier:reuseIdentifier];
    }
    [self settingAttributesOfCell:cell onIdentifier:reuseIdentifier onIndexPath:indexPath];
    
    return cell;
}

/* Header 的高度定义 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

/* section 的标题定义 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect inframe = CGRectMake(0, 0, tableView.frame.size.width, [tableView rectForHeaderInSection:section].size.height);
    UILabel* label = [[UILabel alloc] initWithFrame:inframe];
    label.text = (section == 0)?(@"  基本信息"):(@"  账户信息");
    return label;
}


#pragma mask ------ UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* reuseIdentifier = [self identifierCellAtIndexPath:indexPath];
    if ([reuseIdentifier isEqualToString:IdentifierCellAreaLabel]) {
        UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DetailAreaViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"detailAreaVC"];
        [self.navigationController pushViewController:viewController animated:YES];
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
        reuseIdentifierCell = IdentifierCellAccountField;
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
        NSArray* basicKeys = @[KeyBasicInfoTitleString,KeyBasicInfoPlaceHolderString,KeyBasicInfoMustInputBool,KeyBasicInfoTextString];
        NSArray* areaKeys = @[KeyBasicInfoTitleString,KeyBasicInfoPlaceHolderString,KeyBasicInfoMustInputBool,KeyBasicInfoTextString,KeyBasicInfoProvinceString,KeyBasicInfoCityString,KeyBasicInfoAreaString,KeyBasicInfoAreaCodeString];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"商户名称",@"不超过40位字符",@(YES),@"", nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"登陆用户名",@"不超过40位字母或数字字符",@(YES),@"", nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"登陆密码",@"请输入8位字母或数字字符",@(YES),@"", nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"确认密码",@"请重新输入登陆密码",@(YES),@"", nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"身份证号码",@"请输入15位或18位身份证号码",@(YES),@"", nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"手机号码",@"请输入手机号码",@(YES),@"", nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"邮箱",@"请输入有效的邮箱",@(NO),@"", nil] forKeys:basicKeys]];
        [basicInfos addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"详细地址",@"请选择并输入商铺详细地址",@(YES),@"",@"",@"",@"",@"", nil] forKeys:areaKeys]];
        _arrayBasicInfo = [NSArray arrayWithArray:basicInfos];
    }
    return _arrayBasicInfo;
}
- (NSArray *)arrayAccountInfo {
    if (_arrayAccountInfo == nil) {
        NSMutableArray* accountInfos = [[NSMutableArray alloc] init];
        NSArray* keys = @[KeyAccountInfoTitleString,KeyAccountInfoPlaceHolderString,KeyAccountInfoMustInputBool,KeyAccountInfoTextString];
        [accountInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"开户行名称",@"不超过40位字符",@(YES),@"", nil] forKeys:keys]];
        [accountInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"结算账户名",@"不超过40位字符",@(YES),@"", nil] forKeys:keys]];
        [accountInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"结算账号",@"不超过30位账号",@(YES),@"", nil] forKeys:keys]];
        [accountInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"代理商用户名",@"不超过20位字符",@(NO),@"", nil] forKeys:keys]];
        _arrayAccountInfo = [NSArray arrayWithArray:accountInfos];
    }
    return _arrayAccountInfo;
}

@end
