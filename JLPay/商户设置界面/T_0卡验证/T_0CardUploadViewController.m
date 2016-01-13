//
//  T_0CardUploadViewController.m
//  JLPay
//
//  Created by jielian on 15/12/29.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "T_0CardUploadViewController.h"
#import "PublicInformation.h"
#import "FieldInputTableCell.h"
#import "ImageInputTableCell.h"
#import "HttpUploadT0Card.h"
#import "KVNProgress.h"

static NSString* const kActionSheetTitleCamera = @"拍摄";
static NSString* const kActionSheetTitlePicture = @"从相册选择";

@interface T_0CardUploadViewController()
<UITableViewDataSource, UITableViewDelegate,
UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
HttpUploadT0CardDelegate>
{
    UIImage* pickedImage;
}
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, assign) BOOL enableUpload;  // KVO key
@end

@implementation T_0CardUploadViewController

#pragma mask 0 初始化
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enableUpload = NO;
    self.title = @"卡信息";
    [self loadSubviews];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void) loadSubviews {
    CGFloat heightStates = [PublicInformation returnStatusHeight];
    CGFloat heightNavi = self.navigationController.navigationBar.frame.size.height;
    CGFloat heightTabbar = self.tabBarController.tabBar.frame.size.height;
    
    CGRect frame = CGRectMake(0,
                              heightStates + heightNavi,
                              self.view.frame.size.width,
                              self.view.frame.size.height - heightStates - heightNavi - heightTabbar);
    [self.tableView setFrame:frame];
    [self.view addSubview:self.tableView];
    
    [self.navigationItem setRightBarButtonItem:[self verifyCardButton]];
}
- (UIBarButtonItem*) verifyCardButton {
    return [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(checkAndUpload:)];
}

#pragma mask 1 HttpUploadT0Card && HttpUploadT0CardDelegate
- (IBAction) checkAndUpload:(id)sender  {
    if ([self allInputsIsPrepared]) {
        [[HttpUploadT0Card sharedInstance] uploadCardNo:[self cardNoFromCell]
                                         cardHolderName:[self cardNameFromCell]
                                              cardPhoto:[self cardImageFromCell]
                                             onDelegate:self];
        [KVNProgress showWithStatus:@"交易卡信息上传中..."];
    }
}

- (void)didUploadedSuccess {
    [KVNProgress showSuccessWithStatus:@"上传交易卡信息成功!" completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
- (void)didUploadedFail:(NSString *)failMessage {
    [KVNProgress showErrorWithStatus:[NSString stringWithFormat:@"上传交易卡信息失败:%@",failMessage]];
}

#pragma mask 2 UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    else {// if (section == 1) {
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[self cellIndentifierAtSection:indexPath.section]];
    if (!cell) {
        if (indexPath.section == 0) {
            cell = [[FieldInputTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self cellIndentifierAtSection:indexPath.section]];
        } else {
            cell = [[ImageInputTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self cellIndentifierAtSection:indexPath.section]];
        }
    }
    if (indexPath.section == 0) {
        FieldInputTableCell* fieldCell = (FieldInputTableCell*)cell;
        if (indexPath.row == 0) {
            [fieldCell setTitle:@"卡号"];
            [fieldCell setPlaceHolder:@"请输入交易卡号"];
        } else {
            [fieldCell setTitle:@"姓名"];
            [fieldCell setPlaceHolder:@"请输入持卡人姓名"];
        }
    }
    else if (indexPath.section == 1) {
        ImageInputTableCell* imageCell = (ImageInputTableCell*)cell;
        [imageCell setImageDisplay:pickedImage];
    }
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"请上传银行卡正面照(拍照清晰)";
    } else {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 200.f;
    } else {
        return [tableView rowHeight];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 20.f;
    } else {
        return 30.f;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [self chooseImagePickerType];
    }
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mask 2 照片采集器
- (void) chooseImagePickerType {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"上传交易卡正面照" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    [actionSheet addButtonWithTitle:kActionSheetTitleCamera];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:kActionSheetTitleCamera]) {
        [self presentImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
    }
    else if ([buttonTitle isEqualToString:kActionSheetTitlePicture]) {
        [self presentImagePickerWithType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
}

- (void) presentImagePickerWithType:(UIImagePickerControllerSourceType)sourceType {
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [PublicInformation makeCentreToast:@"摄像头设备异常,无法拍照"];
        return;
    }
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    [picker setSourceType:sourceType];
    [picker setDelegate:self];
    [self presentViewController:picker animated:YES completion:^{}];
}
// -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage* imagePicked = info[UIImagePickerControllerOriginalImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (imagePicked.size.width > 1000) {
            pickedImage = [PublicInformation imageScaledBySourceImage:imagePicked withWidthScale:0.1f andHeightScale:0.1f];
        } else {
            pickedImage = imagePicked;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mask 3 点击事件

#pragma mask 4 PRIVATE INTERFACE
//
- (NSString*) cellIndentifierAtSection:(NSInteger)section {
    if (section == 0) {
        return @"TextCellIdentifier";
    } else {
        return @"ImageCellIdentifier";
    }
}
// -- 检查输入是否都完成
- (BOOL) allInputsIsPrepared {
    BOOL prepared = YES;
    if (prepared && [self cardNoFromCell].length == 0) {
        prepared = NO;
        [PublicInformation makeCentreToast:@"卡号输入不能为空!"];
    }
    if (prepared && [self cardNameFromCell].length == 0) {
        prepared = NO;
        [PublicInformation makeCentreToast:@"持卡人姓名输入不能为空!"];
    }
    if (prepared && ![self cardImageFromCell]) {
        prepared = NO;
        [PublicInformation makeCentreToast:@"交易卡正面照未上传!"];
    }
    return prepared;
}
// -- 卡号
- (NSString*) cardNoFromCell {
    FieldInputTableCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cell.textInputed;
}
// -- 姓名
- (NSString*) cardNameFromCell {
    FieldInputTableCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    return cell.textInputed;
}
// -- 卡图片
- (UIImage*) cardImageFromCell {
    ImageInputTableCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    return cell.imageDisplay;
}


#pragma mask 5 getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tableView setCanCancelContentTouches:NO];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
    }
    return _tableView;
}

@end
