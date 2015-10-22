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
#import "ImageViewCell.h"
#import "DetailAreaViewController.h"
#import "BankNumberViewController.h"
#import "ASIFormDataRequest.h"
#import "JLActivitor.h"
#import "Define_Header.h"


@interface UserRegisterViewController()
<UITableViewDataSource, UITableViewDelegate, TextFieldCellDelegate, UIActionSheetDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate>
{
    NSInteger rowCellImageNeedPicking;
    CGRect activitorFrame;
}
@property (nonatomic, strong) UIButton* registerButton;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray* arrayBasicInfo;
@property (nonatomic, strong) NSArray* arrayAccountInfo;
@property (nonatomic, strong) NSArray* arrayImageInfo;

@property (nonatomic, retain) ASIFormDataRequest* httpRequestRegister;


@end

/*** cell数据源KEY定义区 ***/

// -- field & label & image
NSString* KeyInfoBoolMustInput = @"KeyInfoBoolMustInput__";
NSString* KeyInfoStringTitle = @"KeyInfoStringTitle__";
NSString* KeyInfoBoolInputed = @"KeyInfoBoolInputed__";
// -- field & label
NSString* KeyInfoStringInputText = @"KeyInfoStringInputText__";
// -- field
NSString* KeyInfoStringPlayceHolder = @"KeyInfoStringPlayceHolder__";
NSString* KeyInfoBoolSecureEnable = @"KeyInfoBoolSecureEnable__";
NSString* KeyInfoStringKeyName = @"KeyInfoStringKeyName__";
NSString* KeyInfoIntLengthLimit = @"KeyInfoIntLengthLimit__";
// -- image
NSString* KeyInfoImageSelected = @"KeyInfoImageSelected__";
NSString* KeyInfoImageName = @"KeyInfoImageName__";
// -- label
NSString* KeyInfoStringAreaCode = @"KeyInfoStringAreaCode__";
NSString* KeyInfoStringDetailArea = @"KeyInfoStringDetailArea__";
NSString* KeyInfoStringDetailKeyName = @"KeyInfoStringDetailKeyName__";
NSString* KeyInfoStringAreaCodeKeyName = @"KeyInfoStringAreaCodeKeyName__";

NSString* KeyInfoStringBankNum = @"KeyInfoStringBankNum__";
NSString* KeyInfoStringBankName = @"KeyInfoStringBankName__";
NSString* KeyInfoStringBankNameKeyName = @"KeyInfoStringBankNameKeyName__";
NSString* KeyInfoStringBankNumKeyName = @"KeyInfoStringBankNumKeyName__";



/*** cell标识名定义 ***/
NSString* IdentifierCellField = @"IdentifierCellField__"; // 基本信息
NSString* IdentifierCellLabel = @"IdentifierCellLabel__"; // 地区
NSString* IdentifierCellImageView = @"IdentifierCellImageView__"; // 图片

@implementation UserRegisterViewController
@synthesize registerButton = _registerButton;
@synthesize tableView = _tableView;
@synthesize httpRequestRegister = _httpRequestRegister;

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
        if (indexPath.row == self.arrayBasicInfo.count - 1) {
            return HEIGHT_LABEL_CELL;
        } else {
            return HEIGHT_FIELD_CELL;
        }
    }
    else {
        if (indexPath.row == 0) {
            return HEIGHT_LABEL_CELL;
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
    // 点击cell: 详细地址 | 联行号
    if ([reuseIdentifier isEqualToString:IdentifierCellLabel]) {
        if (indexPath.section == 0 && indexPath.row == self.arrayBasicInfo.count - 1) {
            UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DetailAreaViewController* viewController = [storyBoard instantiateViewControllerWithIdentifier:@"detailAreaVC"];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else if (indexPath.section == 1 && indexPath.row == 0) {
            UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            BankNumberViewController* bankVC = [storyBoard instantiateViewControllerWithIdentifier:@"bankNumVC"];
            [self.navigationController pushViewController:bankVC animated:YES];
        }
    }
    // 点击cell: 输入框
    else if ([reuseIdentifier isEqualToString:IdentifierCellField]) {
        TextFieldCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell startInput];
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
    NSIndexPath* indexPath = [self.tableView indexPathForCell:tableCell];
    if (indexPath.section == 0) {
        NSMutableDictionary* basicInfo = [self.arrayBasicInfo objectAtIndex:indexPath.row];
        [basicInfo setValue:text forKey:KeyInfoStringInputText];
        [basicInfo setValue:@(YES) forKey:KeyInfoBoolInputed];
    }
    else if (indexPath.section == 1) {
        NSMutableDictionary* accountInfo = [self.arrayAccountInfo objectAtIndex:indexPath.row];
        [accountInfo setValue:text forKey:KeyInfoStringInputText];
        [accountInfo setValue:@(YES) forKey:KeyInfoBoolInputed];
    }
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 将图片保存到数据源
        [self setImageInfoWithImage:imagePicked atIndex:rowCellImageNeedPicking];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 重载表格视图
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:rowCellImageNeedPicking inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    });
}

#pragma mask ------ ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    [request clearDelegatesAndCancel];
    [self stopActivitor];
    NSData* datas = [request responseData];
    self.httpRequestRegister = nil;
    NSError* error;
    NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingMutableLeaves error:&error];
    NSString* retCode = [dataDict valueForKey:@"code"];
    if ([retCode intValue] == 0) { // 成功
        [self alertShowWithMessage:@"商户注册成功!等待审核中..."];
    } else { // 失败
        NSString* retMsg = [NSString stringWithFormat:@"商户注册失败:%@", [dataDict valueForKey:@"message"]];
        [self alertShowWithMessage:retMsg];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request {
    [self stopActivitor];
    [self alertShowWithMessage:@"商户注册失败:网络异常!"];
    [request clearDelegatesAndCancel];
    self.httpRequestRegister = nil;
}


#pragma mask ------ http操作
/* 打包 */
- (void) requestPacking {
    // 基本信息
    [self packingBasicInfo];
    // 账户信息
    [self packingAccountInfo];
    // 图片信息
    [self packingImageInfo];
}
- (void) packingBasicInfo {
    for (int i = 0; i < self.arrayBasicInfo.count; i++) {
        NSDictionary* dict = [self.arrayBasicInfo objectAtIndex:i];
        if (i != self.arrayBasicInfo.count - 1) { // 基本信息
            if ([[dict valueForKey:KeyInfoStringKeyName] length] == 0) { // 过滤不用上送的字典
                continue;
            }
            if ([[dict objectForKey:KeyInfoBoolInputed] boolValue]) {
                [self.httpRequestRegister setPostValue:[dict valueForKey:KeyInfoStringInputText] forKey:[dict valueForKey:KeyInfoStringKeyName]];
            } else {
                [self.httpRequestRegister setPostValue:@"" forKey:[dict valueForKey:KeyInfoStringKeyName]];
            }
        }
        else { // 地区信息
            if ([[dict objectForKey:KeyInfoBoolInputed] boolValue]) {
                [self.httpRequestRegister setPostValue:[dict valueForKey:KeyInfoStringAreaCode] forKey:[dict valueForKey:KeyInfoStringAreaCodeKeyName]];
                [self.httpRequestRegister setPostValue:[dict valueForKey:KeyInfoStringDetailArea] forKey:[dict valueForKey:KeyInfoStringDetailKeyName]];
            }
        }
    }
}
- (void) packingAccountInfo {
    for (int i = 0; i < self.arrayAccountInfo.count; i++) {
        NSDictionary* dict = [self.arrayAccountInfo objectAtIndex:i];
        if (i == 0) { // 开户行信息
            if ([[dict objectForKey:KeyInfoBoolInputed] boolValue]) {
                [self.httpRequestRegister setPostValue:[dict valueForKey:KeyInfoStringBankName] forKey:[dict valueForKey:KeyInfoStringBankNameKeyName]];
                [self.httpRequestRegister setPostValue:[dict valueForKey:KeyInfoStringBankNum] forKey:[dict valueForKey:KeyInfoStringBankNumKeyName]];
            }
        } else { // 账户基本信息
            if ([[dict objectForKey:KeyInfoBoolInputed] boolValue]) {
                [self.httpRequestRegister setPostValue:[dict valueForKey:KeyInfoStringInputText] forKey:[dict valueForKey:KeyInfoStringKeyName]];
            } else {
                [self.httpRequestRegister setPostValue:@"" forKey:[dict valueForKey:KeyInfoStringKeyName]];
            }
        }
    }
}
- (void) packingImageInfo {
    for (int i = 0; i < self.arrayImageInfo.count; i++) {
        NSDictionary* dict = [self.arrayImageInfo objectAtIndex:i];
        NSData* imageData = UIImageJPEGRepresentation([dict objectForKey:KeyInfoImageSelected], 0.5);
        NSString* imageName = [dict valueForKey:KeyInfoImageName];
        [self.httpRequestRegister setData:imageData
                             withFileName:[NSString stringWithFormat:@"%@.png", imageName]
                           andContentType:@"image/png"
                                   forKey:imageName];
    }
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
    // 检查输入是否完整
    NSIndexPath* indexPath = [self indexPathNotInputedByChecking];
    if (indexPath) {
        NSString* msg = [NSString stringWithFormat:@"%@未输入,请先输入!",[self titleAtIndexPath:indexPath]];
        [self alertShowWithMessage:msg];
        return;
    }
    // 检查确认密码是否输入正确
    if (![self isEqualingWithPasswordSured]) {
        [self alertShowWithMessage:@"确认密码输入错误!"];
        return;
    }

    [self startActivitor];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 打包
        [self requestPacking];
        // 发起http请求
        [self.httpRequestRegister buildPostBody];
        
        [self.httpRequestRegister startAsynchronous];
    });
}

#pragma mask ------ UIAlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.message hasPrefix:@"商户注册成功"]) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        NSString* userName = [self textInputedAtIndexPath:indexPath];
        NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
        // 用户名保存
        [userDefault setValue:userName forKey:UserID];
        [userDefault synchronize];
        // 清空密码
        if ([userDefault objectIsForcedForKey:UserPW]) {
            [userDefault removeObjectForKey:UserPW];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}



#pragma mask ------ tabel cell 的初始化及属性设置
/* 初始化cell */
- (UITableViewCell*) cellForIdentifier:(NSString*)cellIdentifier {
    UITableViewCell* cell = nil;
    if ([cellIdentifier isEqualToString:IdentifierCellField])
    {
        TextFieldCell* fieldCell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [fieldCell setDelegate:self];
        cell = fieldCell;
    }
    else if ([cellIdentifier isEqualToString:IdentifierCellLabel]) {
        cell = [[TextLabelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else if ([cellIdentifier isEqualToString:IdentifierCellImageView]) {
        cell = [[ImageViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}

/* cell标示: 每个section不一样 */
- (NSString*) identifierCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* reuseIdentifierCell = nil;
    if (indexPath.section == 0) {
        if (indexPath.row == self.arrayBasicInfo.count - 1) {
            reuseIdentifierCell = IdentifierCellLabel;
        } else {
            reuseIdentifierCell = IdentifierCellField;
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            reuseIdentifierCell = IdentifierCellLabel;
        } else {
            reuseIdentifierCell = IdentifierCellField;
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
    if ([identifier isEqualToString:IdentifierCellField])
    {
        TextFieldCell* fieldCell = (TextFieldCell*)cell;
        [fieldCell setTitle:[self titleAtIndexPath:indexPath]];
        [fieldCell setPlaceHolder:[self placeHolderAtIndexPath:indexPath]];
        [fieldCell setMustInput:[self mustInputAtIndexPath:indexPath]];
        [fieldCell setSecureTextEntry:[self securityAtIndexPath:indexPath]];
        [fieldCell setTextInputed:[self textInputedAtIndexPath:indexPath]];
        [fieldCell setLengthLimit:[self lengthLimitAtIndexPath:indexPath]];
    }
    else if ([identifier isEqualToString:IdentifierCellLabel])
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage* image = [self imageAtIndexPath:indexPath];
            [imageCell setImageDisplay:image];
        });
    }
}



#pragma mask ------ 数据源
/* 标题 */
- (NSString*) titleAtIndexPath:(NSIndexPath*)indexPath {
    NSString* sTitle = nil;
    if (indexPath.section == 0) {
        sTitle = [[self.arrayBasicInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoStringTitle];
    }
    else if (indexPath.section == 1) {
        sTitle = [[self.arrayAccountInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoStringTitle];
    }
    else if (indexPath.section == 2) {
        sTitle = [[self.arrayImageInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoStringTitle];
    }
    return sTitle;
}
/* 提示文本 */
- (NSString*) placeHolderAtIndexPath:(NSIndexPath*)indexPath {
    NSString* sPlaceHolder = nil;
    if (indexPath.section == 0) {
        sPlaceHolder = [[self.arrayBasicInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoStringPlayceHolder];
    }
    else if (indexPath.section == 1) {
        sPlaceHolder = [[self.arrayAccountInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoStringPlayceHolder];
    }
    return sPlaceHolder;
}
/* 输入文本 */
- (NSString*) textInputedAtIndexPath:(NSIndexPath*)indexPath {
    NSString* textInputed = @"";
    if (indexPath.section == 0) {
        textInputed = [[self.arrayBasicInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoStringInputText];
    }
    else if (indexPath.section == 1) {
        textInputed = [[self.arrayAccountInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoStringInputText];
    }
    return textInputed;
}
/* 必输标记 */
- (BOOL) mustInputAtIndexPath:(NSIndexPath*)indexPath {
    BOOL mustInput = YES;
    if (indexPath.section == 0) {
        mustInput = [[[self.arrayBasicInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoBoolMustInput] boolValue];
    }
    else if (indexPath.section == 1) {
        mustInput = [[[self.arrayAccountInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoBoolMustInput] boolValue];
    }
    return mustInput;
}
/* 文本密文显示标志 */
- (BOOL) securityAtIndexPath:(NSIndexPath*)indexPath {
    BOOL security = YES;
    if (indexPath.section == 0) {
        security = [[[self.arrayBasicInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoBoolSecureEnable] boolValue];
    }
    else if (indexPath.section == 1) {
        security = [[[self.arrayAccountInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoBoolSecureEnable] boolValue];
    }
    return security;
}
/* 输入长度限制 */
- (NSInteger) lengthLimitAtIndexPath:(NSIndexPath*)indexPath {
    NSInteger lengthLimit = 0;
    if (indexPath.section == 0) {
        lengthLimit = [[[self.arrayBasicInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoIntLengthLimit] intValue];
    }
    else if (indexPath.section == 1) {
        lengthLimit = [[[self.arrayAccountInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoIntLengthLimit] intValue];
    }
    return lengthLimit;
}
/* 图片信息 */
- (UIImage*) imageAtIndexPath:(NSIndexPath*)indexPath {
    UIImage* image = nil;
    if (indexPath.section == 2) {
        NSDictionary* imageInfo = [self.arrayImageInfo objectAtIndex:indexPath.row];
        image = [imageInfo objectForKey:KeyInfoImageSelected];
        if (image.size.width > 1000) {
            image = [PublicInformation imageScaledBySourceImage:image withWidthScale:0.1 andHeightScale:0.1];
        }
    }
    return image;
}
/* 联行号 */
- (NSString*) bankNoAtIndexPath:(NSIndexPath*)indexPath {
    NSString* bankNo = nil;
    if (indexPath.section == 1 && indexPath.row == 0) {
        bankNo = [[self.arrayAccountInfo objectAtIndex:indexPath.row] valueForKey:KeyInfoStringBankNum];
    }
    return bankNo;
}
/* 设置图片: 指定row */
- (void) setImageInfoWithImage:(UIImage*)image atIndex:(NSInteger)index {
    NSMutableDictionary* imageNode = [self.arrayImageInfo objectAtIndex:index];
    [imageNode setObject:image forKey:KeyInfoImageSelected];
    [imageNode setObject:@(YES) forKey:KeyInfoBoolInputed];
}

/* 详细地址设置:省名+市名(+区县名)+详细地址+areaCode */
- (void) setDetailAddr:(NSString*)detailAddr
            inProvince:(NSString*)province
               andCity:(NSString*)city
               andArea:(NSString*)area
           andAreaCode:(NSString*)areaCode
{
    // 设置数据源
//    NSDictionary* addrInfo = [self infoDetailAddr];
    NSMutableDictionary* addrInfo = [self.arrayBasicInfo objectAtIndex:self.arrayBasicInfo.count - 1];
    [addrInfo setValue:detailAddr forKey:KeyInfoStringDetailArea];
    [addrInfo setValue:areaCode forKey:KeyInfoStringAreaCode];
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
    [addrInfo setValue:detailAddrs forKey:KeyInfoStringPlayceHolder];
    [addrInfo setObject:@(YES) forKey:KeyInfoBoolInputed];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.arrayBasicInfo.count - 1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (NSDictionary*) infoDetailAddr {
    NSDictionary* info = nil;
    for (NSDictionary* dict in self.arrayBasicInfo) {
        if ([[dict valueForKey:KeyInfoStringTitle] isEqualToString:@"详细地址"]) {
            info = dict;
            break;
        }
    }
    return info;
}

/* 设置开户行-联行号 */
- (void) setBankNum:(NSString*)bankNum forBankName:(NSString*)bankName {
    NSDictionary* bankInfo = [self.arrayAccountInfo objectAtIndex:0];
    [bankInfo setValue:bankNum forKey:KeyInfoStringBankNum];
    [bankInfo setValue:bankName forKey:KeyInfoStringBankName];
    [bankInfo setValue:bankName forKey:KeyInfoStringPlayceHolder];
    [bankInfo setValue:@(YES) forKey:KeyInfoBoolInputed];
    [self.tableView reloadData];
}

/* 检查输入是否都完全: 返回nil表示都输入了 */
- (NSIndexPath*) indexPathNotInputedByChecking {
    NSIndexPath* indexPath = nil;
    for (int i = 0; i < self.arrayBasicInfo.count; i++) {
        NSDictionary* dict = [self.arrayBasicInfo objectAtIndex:i];
        if ([[dict objectForKey:KeyInfoBoolMustInput] boolValue] && ![[dict objectForKey:KeyInfoBoolInputed] boolValue]) {
            indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            return indexPath;
        }
    }
    for (int i = 0; i < self.arrayAccountInfo.count; i++) {
        NSDictionary* dict = [self.arrayAccountInfo objectAtIndex:i];
        if ([[dict objectForKey:KeyInfoBoolMustInput] boolValue] && ![[dict objectForKey:KeyInfoBoolInputed] boolValue]) {
            indexPath = [NSIndexPath indexPathForRow:i inSection:1];
            return indexPath;
        }
    }
    for (int i = 0; i < self.arrayImageInfo.count; i++) {
        NSDictionary* dict = [self.arrayImageInfo objectAtIndex:i];
        if (![[dict objectForKey:KeyInfoBoolInputed] boolValue]) {
            indexPath = [NSIndexPath indexPathForRow:i inSection:2];
            return indexPath;
        }
    }
    return indexPath;
}
/* 检查确认密码是否一致 */
- (BOOL) isEqualingWithPasswordSured {
    NSString* passwordInfo = nil;
    NSString* passwordSuredInfo = nil;
    BOOL isEqualingPwd = NO;
    for (NSDictionary* dict in self.arrayBasicInfo) {
        if (passwordInfo && passwordSuredInfo) {
            break;
        }
        if ([[dict valueForKey:KeyInfoStringTitle] isEqualToString:@"登陆密码"]) {
            passwordInfo = [dict valueForKey:KeyInfoStringInputText];
        }
        if ([[dict valueForKey:KeyInfoStringTitle] isEqualToString:@"确认密码"]) {
            passwordSuredInfo = [dict valueForKey:KeyInfoStringInputText];
        }
    }
    if ([passwordInfo isEqualToString:passwordSuredInfo]) {
        isEqualingPwd = YES;
    }
    return isEqualingPwd;
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
    
    activitorFrame = CGRectMake(0, statesNaviHeight, self.view.frame.size.width, self.view.frame.size.height - (statesNaviHeight));
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
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.httpRequestRegister clearDelegatesAndCancel];
    self.httpRequestRegister = nil;
}

/* 简化alert代码 */
- (void) alertShowWithMessage:(NSString*)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}
- (void) startActivitor {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JLActivitor sharedInstance] startAnimatingInFrame:activitorFrame];
    });
}
- (void) stopActivitor {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JLActivitor sharedInstance] stopAnimating];
    });
}

/* 回退到上一个场景 */
- (void) backToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

/* 初始图片 */
- (UIImage*) initialImage {
    UIImage* image = [UIImage imageNamed:@"camera"];
    CGFloat viewHeight = HEIGHT_IMAGEVIEW_CELL;
    CGFloat viewWidth = self.view.frame.size.width ;
    CGFloat imageHeight = viewHeight/2.0;
    CGFloat imageWidth = imageHeight * image.size.width/image.size.height;
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake((viewWidth - imageWidth)/2.0,
                                                                           (viewHeight - imageHeight)/2.0,
                                                                           imageWidth,
                                                                           imageHeight)];
    [imageView setImage:image];
    [view addSubview:imageView];
    
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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
        NSArray* basicKeys = @[KeyInfoStringTitle,KeyInfoStringPlayceHolder,KeyInfoBoolMustInput,KeyInfoStringInputText,KeyInfoBoolSecureEnable,KeyInfoBoolInputed,KeyInfoStringKeyName,KeyInfoIntLengthLimit];
        NSArray* areaKeys = @[KeyInfoStringTitle,KeyInfoBoolMustInput,KeyInfoStringPlayceHolder,KeyInfoStringAreaCode,KeyInfoStringDetailArea,KeyInfoBoolInputed,KeyInfoStringDetailKeyName,KeyInfoStringAreaCodeKeyName];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"商户名称",@"不超过40位字符",@(YES),@"",@(NO),@(NO),@"mchntNm",@(40), nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"登陆用户名",@"不超过40位字母或数字字符",@(YES),@"",@(NO),@(NO),@"userName",@(40), nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"登陆密码",@"请输入8位字母或数字字符",@(YES),@"",@(YES),@(NO),@"passWord",@(8), nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"确认密码",@"请重新输入登陆密码",@(YES),@"",@(YES),@(NO),@"",@(8), nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"身份证号码",@"请输入15位或18位身份证号码",@(YES),@"",@(NO),@(NO),@"identifyNo",@(20), nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"手机号码",@"请输入手机号码",@(YES),@"",@(NO),@(NO),@"telNo",@(11), nil] forKeys:basicKeys]];
        [basicInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"邮箱",@"请输入有效的邮箱",@(YES),@"",@(NO),@(NO),@"mail",@(40), nil] forKeys:basicKeys]];
        [basicInfos addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"详细地址",@(YES),@"请选择并输入商铺详细地址",@"",@"",@(NO),@"addr",@"areaNo", nil] forKeys:areaKeys]];
        _arrayBasicInfo = [NSArray arrayWithArray:basicInfos];
    }
    return _arrayBasicInfo;
}
- (NSArray *)arrayAccountInfo {
    if (_arrayAccountInfo == nil) {
        NSMutableArray* accountInfos = [[NSMutableArray alloc] init];
        NSArray* keys = @[KeyInfoStringTitle,KeyInfoStringPlayceHolder,KeyInfoBoolMustInput,KeyInfoStringInputText,KeyInfoBoolSecureEnable,KeyInfoBoolInputed,KeyInfoStringKeyName,KeyInfoIntLengthLimit];
        NSArray* bankNoKeys = @[KeyInfoStringTitle,KeyInfoBoolMustInput,KeyInfoStringPlayceHolder,KeyInfoStringBankName,KeyInfoStringBankNum,KeyInfoBoolInputed,KeyInfoStringBankNameKeyName,KeyInfoStringBankNumKeyName];
        [accountInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"开户行联行号",@(YES),@"请输入开户行名并选择联行号",@"",@"",@(NO),@"speSettleDs",@"openStlno", nil] forKeys:bankNoKeys]];
        [accountInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"结算账户名",@"不超过40位字符",@(YES),@"",@(NO),@(NO),@"settleAcctNm",@(30), nil] forKeys:keys]];
        [accountInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"结算账号",@"不超过30位账号",@(YES),@"",@(NO),@(NO),@"settleAcct",@(40), nil] forKeys:keys]];
        [accountInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"代理商用户名",@"(可不填)不超过20位字符",@(NO),@"",@(NO),@(NO),@"ageUserName",@(20), nil] forKeys:keys]];
        _arrayAccountInfo = [NSArray arrayWithArray:accountInfos];
    }
    return _arrayAccountInfo;
}
- (NSArray *)arrayImageInfo {
    if (_arrayImageInfo == nil) {
        NSMutableArray* imageInfos = [[NSMutableArray alloc] init];
        NSArray* keys = @[KeyInfoStringTitle,KeyInfoImageName,KeyInfoBoolInputed,KeyInfoImageSelected];
        [imageInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"上传身份证照(正面)",@"03",@(NO),[self initialImage], nil] forKeys:keys]];
        [imageInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"上传身份证照(反面)",@"06",@(NO),[self initialImage], nil] forKeys:keys]];
        [imageInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"上传手持身份证照(正面)",@"09",@(NO),[self initialImage], nil] forKeys:keys]];
        [imageInfos addObject: [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"上传结算银行卡照(正面)",@"08",@(NO),[self initialImage], nil] forKeys:keys]];
        _arrayImageInfo = [NSArray arrayWithArray:imageInfos];
    }
    return _arrayImageInfo;
}
- (ASIFormDataRequest *)httpRequestRegister {
    if (_httpRequestRegister == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/MchntRegister",[PublicInformation getDataSourceIP],[PublicInformation getDataSourcePort]];
        _httpRequestRegister = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
        [_httpRequestRegister setPostFormat:ASIMultipartFormDataPostFormat];
        [_httpRequestRegister setRequestMethod:@"POST"];
        [_httpRequestRegister setStringEncoding:NSUTF8StringEncoding];
        [_httpRequestRegister setDelegate:self];
    }
    return _httpRequestRegister;
}

@end
