//
//  VMSignUpManager.m
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMSignUpManager.h"
#import "Define_Header.h"
#import "SU_MobileNumberCell.h"
#import "SU_MobileCheckCell.h"
#import "SU_TextInputTBVCell.h"
#import "SU_PhotoPickedTBVCell.h"
#import <ReactiveCocoa.h>
#import "MBProgressHUD+CustomSate.h"
//
#import "SU_ChooseProvinceAndCityVC.h"
#import "VMSignUpPhotoPicker.h"
#import "VMSignUpPhotoBrowser.h"
#import "VMPhoneChecking.h"
#import "VMSignUpHttpRequest.h"
#import "JLSignUpViewController.h"
#import "AvilableBankListViewController.h"
#import "BankBranchListViewController.h"




@implementation VMSignUpManager

+ (instancetype)sharedInstance {
    static VMSignUpManager* sharedSignUpVM;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSignUpVM = [[VMSignUpManager alloc] init];
    });
    return sharedSignUpVM;
}


- (void) resetDataSource {
    self.seperatedIndex = 0;
    self.signUpInputs = nil;
}

/* 绑定到界面的'下一步'和'注册'按钮 */
- (RACCommand *)newCommandForInputsCheckingOnCurIndex {
    @weakify(self);
    return [[RACCommand alloc] initWithEnabled:[self sigOfEnableInputsChecking]
                                                 signalBlock:^RACSignal *(id input) {
                                                     NSString* curSeperatedTitle = [self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex];
                                                     @strongify(self);
                                                     
                                                     /* 为拍照:上传注册 */
                                                     if ([curSeperatedTitle isEqualToString:kSignUpItemsTitleCerUpload]) {
                                                         return [[self.signUpHttpRequest.sigHttpRequesting replayLast] materialize];
                                                     }
                                                     /* 验证手机号:  */
                                                     else if ([curSeperatedTitle isEqualToString:kSignUpItemsTitleMobileCheck]) {
                                                         return [[self.phoneChecking.sigNumberChecking replayLast] materialize];
                                                     }
                                                     else {
                                                         return [self signalForInputsCheckingBeforeStepToNext];
                                                     }
                                                 }];

}

- (RACSignal*) signalForInputsCheckingBeforeStepToNext {
    @weakify(self);
    return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSString* curSeperatedTitle = [self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex];
        /* 验证密码是否一致 */
        if ([curSeperatedTitle isEqualToString:kSignUpItemsTitlePassword]) {
            if ([self isOnPairOfPasswords]) {
                [subscriber sendCompleted];
            } else {
                [MBProgressHUD showWarnWithText:@"确认密码输入错误,请重输" andDetailText:nil onCompletion:^{
                    [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:@"确认密码输入错误,请重输"]];
                }];
            }
        }
        /* 结算账号必须为62开头，且长度为15\16\19 */
        /* 身份证号必须为15、18位 */
        else if ([curSeperatedTitle isEqualToString:kSignUpItemsTitleStlInfo]) {
            if ([self isValidUserID]) {
                if ([self isValidSettlementCardNo]) {
                    [subscriber sendCompleted];
                } else {
                    [MBProgressHUD showWarnWithText:nil andDetailText:@"结算账号必须为'62'开头的15、16或19位卡号" onCompletion:^{
                        [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:@"结算账号必须为'62'开头的15、16或19位卡号"]];
                    }];
                }
            } else {
                [MBProgressHUD showWarnWithText:nil andDetailText:@"身份证号必须为15或18位" onCompletion:^{
                    [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:@"身份证号必须为15或18位"]];
                }];
            }
        }
        /* 直接通过 */
        else {
            [subscriber sendCompleted];
        }
        
        return nil;
    }] materialize] replayLast];
}



# pragma mask 2 UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray* datas = [self.signUpInputs.itemsGroup objectForKey:[self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex]];
    return datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* datas = [self.signUpInputs.itemsGroup objectForKey:[self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex]];
    return [[datas objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = [self identifierForIndexPath:indexPath];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [self newCellForIdentifier:cellIdentifier];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString* itemGroupTitle = [[VMSignUpManager sharedInstance].signUpInputs.itemsTitles objectAtIndex:[VMSignUpManager sharedInstance].seperatedIndex];
    if ([itemGroupTitle isEqualToString:kSignUpItemsTitleCerUpload]) {
        NSArray* datas = [self.signUpInputs.itemsGroup objectForKey:[self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex]];
        MSignUpItem* item = [[datas objectAtIndex:section] objectAtIndex:0];
        return item.title;
    }
    else if ([itemGroupTitle isEqualToString:kSignUpItemsTitleStlInfo]  && section == 1) {
        return @"温馨提示:借记卡请从下列银行列表选择";
    }
    else {
        return nil;
    }
}

# pragma mask 2 UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = [self identifierForIndexPath:indexPath];
    if ([cellIdentifier isEqualToString:@"SU_CellTypePhotoPicked"]) {
        return 200;
    } else {
        return tableView.rowHeight;
    }
}

/* 定制cell的显示 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    MSignUpItem* item = [self dataItemAtIndexPath:indexPath];
    NSString* curSeperatedTitle = [self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex];
    if ([cell.reuseIdentifier isEqualToString:@"SU_CellTypeMobileNum"]) {
        __weak SU_MobileNumberCell* mobileNumCell = (SU_MobileNumberCell*)cell;
        mobileNumCell.textField.placeholder = item.placeHolder;
        mobileNumCell.textField.delegate = self;
        mobileNumCell.textField.text = (item.inputed)?(item.textInputed):(nil);
        /* 绑定输入源 */
        if ([curSeperatedTitle isEqualToString:kSignUpItemsTitleMobileCheck]) {
            RACSignal* mobileNumSig = [mobileNumCell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal];
            RAC(item, textInputed) = mobileNumSig;
            RAC(item, inputed) = [[mobileNumCell.textField.rac_textSignal map:^id(NSString* text) {
                return (text && text.length > 0)?(@(YES)):(@(NO));
            }] takeUntil:cell.rac_prepareForReuseSignal];
            RAC(self.phoneChecking, phoneNumber) = mobileNumSig;
            RAC(self.signUpHttpRequest, userName) = mobileNumSig;
            RAC(self.signUpHttpRequest, telNo) = mobileNumSig;
        }
    }
    else if ([cell.reuseIdentifier isEqualToString:@"SU_CellTypeMobileCheck"]) {
        __weak SU_MobileCheckCell* mobileCheckCell = (SU_MobileCheckCell*)cell;
        mobileCheckCell.textField.placeholder = item.placeHolder;
        mobileCheckCell.textField.delegate = self;
        mobileCheckCell.textField.text = (item.inputed)?(item.textInputed):(nil);
        /* 绑定输入源 */
        if ([curSeperatedTitle isEqualToString:kSignUpItemsTitleMobileCheck]) {
            RAC(item, textInputed) = [mobileCheckCell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal];
            RAC(item, inputed) = [[mobileCheckCell.textField.rac_textSignal map:^id(NSString* text) {
                return (text && text.length > 0)?(@(YES)):(@(NO));
            }] takeUntil:cell.rac_prepareForReuseSignal];

            RAC(self.phoneChecking, checkNumber) = [mobileCheckCell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal];

            // 监控定时器;并按钮时间
            [[[[RACObserve(self.phoneChecking.checkWaitingTimer, timeCount) skip:1] takeUntil:cell.rac_prepareForReuseSignal] deliverOnMainThread] subscribeNext:^(NSNumber* timeCount) {
                if (timeCount.integerValue < 0) {
                    mobileCheckCell.reCheckBtn.enabled = YES;
                    [mobileCheckCell.reCheckBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                } else {
                    mobileCheckCell.reCheckBtn.enabled = NO;
                    [mobileCheckCell.reCheckBtn setTitle:[NSString stringWithFormat:@"%02ld秒", timeCount.integerValue] forState:UIControlStateNormal];
                }
                
            }] ;
            
            mobileCheckCell.reCheckBtn.rac_command = self.phoneChecking.cmdCheckNumberRequest;
        }
    }
    else if ([cell.reuseIdentifier isEqualToString:@"SU_CellTypeTextInput"]) {
        __weak SU_TextInputTBVCell* textFieldCell = (SU_TextInputTBVCell*)cell;
        textFieldCell.textLabel.text = item.title;
        textFieldCell.textField.placeholder = item.placeHolder;
        textFieldCell.textField.secureTextEntry = ([item.title isEqualToString:kSUCellTitleUserPwd] || [item.title isEqualToString:kSUCellTitleConfirmPwd])?(YES):(NO);
        textFieldCell.textField.delegate = self;
        textFieldCell.textField.text = (item.inputed)?(item.textInputed):(nil);
        /* 绑定输入源 */
        RACSignal* normalTextInputSig = [textFieldCell.textField.rac_textSignal takeUntil:cell.rac_prepareForReuseSignal];
        RAC(item, textInputed) = normalTextInputSig;
        RAC(item, inputed) = [[textFieldCell.textField.rac_textSignal map:^id(NSString* text) {
            return (text && text.length > 0)?(@(YES)):(@(NO));
        }] takeUntil:cell.rac_prepareForReuseSignal];
        [self signUpHttpBindingParametersOnSig:normalTextInputSig atIndexPath:indexPath];
    }
    else if ([cell.reuseIdentifier isEqualToString:@"SU_CellTypeValue1"]) {
        cell.textLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:cell.frame.size.height scale:0.38]];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:cell.frame.size.height scale:0.35]];
        cell.textLabel.text = item.title;
        cell.detailTextLabel.text = (item.inputed)?(item.textInputed):(item.placeHolder);
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ([cell.reuseIdentifier isEqualToString:@"SU_CellTypePhotoPicked"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (item.inputed) {
                UIImage* image = [PublicInformation imageScaledBySourceImage:item.photoPicked withWidthScale:0.1 andHeightScale:0.1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    __weak SU_PhotoPickedTBVCell* photoCell = (SU_PhotoPickedTBVCell*)cell;
                    photoCell.imgViewPicked.image = image;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __weak SU_PhotoPickedTBVCell* photoCell = (SU_PhotoPickedTBVCell*)cell;
                    photoCell.imgViewPicked.image = nil;
                });
            }
        });
    }
    else if ([cell.reuseIdentifier isEqualToString:@"SU_CellTypeNormalChoose"]) {
        cell.textLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:cell.frame.size.height scale:0.38]];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:cell.frame.size.height scale:0.35]];
        cell.detailTextLabel.numberOfLines = 0;
        cell.textLabel.text = item.title;
        cell.detailTextLabel.text = (item.inputed)?(item.textInputed):(item.placeHolder);
        cell.detailTextLabel.textColor = (item.inputed)?([UIColor colorWithHex:HexColorTypeBlackBlue alpha:1]):([UIColor colorWithHex:HexColorTypeBlackGray alpha:0.5]);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        
    }

}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    MSignUpItem* item = [self dataItemAtIndexPath:indexPath];
    if (item.cellType == SU_CellTypePhotoPicked || item.cellType == SU_CellTypeNormalChoose) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MSignUpItem* item = [self dataItemAtIndexPath:indexPath];
    /* 点击选择地区 */
    NameWeakSelf(wself);
    if ([item.title isEqualToString:kSUCellTitleProvinceAndCity]) {
        [self.sigChooseArea subscribeNext:^(NSDictionary* areaInfoChoosed) {
            item.inputed = YES;
            NSString* provinceName = [areaInfoChoosed objectForKey:@"provinceName"];
            NSString* cityName = [areaInfoChoosed objectForKey:@"cityName"];
            item.textInputed = [NSString stringWithFormat:@"%@-%@", provinceName, cityName];
            item.subText1 = [areaInfoChoosed objectForKey:@"cityCode"];
            item.subText2 = [areaInfoChoosed objectForKey:@"provinceCode"];
            [tableView reloadData];
            if ([[wself.signUpInputs.itemsTitles objectAtIndex:wself.seperatedIndex] isEqualToString:kSignUpItemsTitleBusinessInfo]) {
                wself.signUpHttpRequest.areaNo = item.subText1;
            }
        }];
    }
    /* 点击银行名 */
    else if ([item.title isEqualToString:kSUCellTitleBankName]) {
        [self.sigChooseBank subscribeNext:^(NSDictionary* bankNode) {
            item.inputed = YES;
            item.textInputed = [bankNode objectForKey:BankListNodeBankName];
            item.subText1 = [bankNode objectForKey:BankListNodeBankCode];
            [tableView reloadData];
        }];
    }
    /* 点击分支行 */
    else if ([item.title isEqualToString:kSUCellTitleBankBranch]) {
        NSIndexPath* bankBranchAreaIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        MSignUpItem* bankBranchAreaItem = [self dataItemAtIndexPath:bankBranchAreaIndexPath];
        if (bankBranchAreaItem.inputed) {
            [self.sigChooseBankBranch subscribeNext:^(NSDictionary* bankBranchNode) {
                item.inputed = YES;
                item.textInputed = [bankBranchNode objectForKey:BankBranchItemBankName];
                item.subText1 = [bankBranchNode objectForKey:BankBranchItemOpenstlNo];
                [tableView reloadData];
                if ([[wself.signUpInputs.itemsTitles objectAtIndex:wself.seperatedIndex] isEqualToString:kSignUpItemsTitleStlBankBranch]) {
                    wself.signUpHttpRequest.openStlno = item.subText1;
                    wself.signUpHttpRequest.speSettleDs = item.textInputed;
                }
            }];
        } else {
            [PublicInformation makeCentreToast:@"请先选择省市!"];
        }
    }
    /* 点击拍照 */
    else if (item.cellType == SU_CellTypePhotoPicked) {
        /* 区分拍照和显示 */
        if (item.inputed) {
            [UIAlertController showActSheetWithTitle:@"请选择" message:@"" target:self.superVC clickedHandle:^(UIAlertAction* action) {
                if ([action.title isEqualToString:@"查看大图"]) {
                    self.photoBrowser = [[VMSignUpPhotoBrowser alloc] initWithPhoto:item.photoPicked];
                    self.photoBrowser.superVC = self.superVC;
                    [self.photoBrowser showWithDone:^{
                        
                    } orDelete:^(NSInteger index) {
                        item.inputed = NO;
                        item.photoPicked = nil;
                        [tableView reloadData];
                    }];
                }
                else if ([action.title isEqualToString:@"重新拍照"]) {
                    self.photoPicker.superVC = self.superVC;
                    [self.sigTakePhoto subscribeNext:^(UIImage* imagePicked) {
                        if (imagePicked) {
                            item.inputed = YES;
                            item.photoPicked = imagePicked;
                            [tableView reloadData];
                            /* set images to signUpHttpVM */
                            if ([item.title isEqualToString:kSUCellTitleIDPhotoFore]) {
                                wself.signUpHttpRequest.img_03 = [imagePicked copy];
                            }
                            else if ([item.title isEqualToString:kSUCellTitleIDPhotoBack]) {
                                wself.signUpHttpRequest.img_06 = [imagePicked copy];
                            }
                            else if ([item.title isEqualToString:kSUCellTitleIDPhotoHandle]) {
                                wself.signUpHttpRequest.img_09 = [imagePicked copy];
                            }
                            else if ([item.title isEqualToString:kSUCellTitleDebitCardFore]) {
                                wself.signUpHttpRequest.img_08 = [imagePicked copy];
                            }
                        }
                    }];
                }
            } buttons:@{@(UIAlertActionStyleCancel):@"取消"}, @{@(UIAlertActionStyleDefault):@"查看大图"}, @{@(UIAlertActionStyleDestructive):@"重新拍照"}, nil];
        }
        /* 第一次点击拍照 */
        else {
            self.photoPicker.superVC = self.superVC;
            [self.sigTakePhoto subscribeNext:^(UIImage* imagePicked) {
                if (imagePicked) {
                    item.inputed = YES;
                    item.photoPicked = imagePicked;
                    [tableView reloadData];
                    if ([item.title isEqualToString:kSUCellTitleIDPhotoFore]) {
                        wself.signUpHttpRequest.img_03 = [imagePicked copy];
                    }
                    else if ([item.title isEqualToString:kSUCellTitleIDPhotoBack]) {
                        wself.signUpHttpRequest.img_06 = [imagePicked copy];
                    }
                    else if ([item.title isEqualToString:kSUCellTitleIDPhotoHandle]) {
                        wself.signUpHttpRequest.img_09 = [imagePicked copy];
                    }
                    else if ([item.title isEqualToString:kSUCellTitleDebitCardFore]) {
                        wself.signUpHttpRequest.img_08 = [imagePicked copy];
                    }
                }
            }];
        }
    }
}

# pragma mask 2 UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([[self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex] isEqualToString:kSignUpItemsTitlePassword]) {
        if (textField.text.length >= 8) {
            return (string.length > 0)?(NO):(YES);
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    ((JLSignUpViewController*)self.superVC).inputedCell = [textField superview];
    return YES;
}
    



# pragma mask 3 PRIVATE FUNCS (for dataSource)

/* get item at indexPath + self.seperatedIndex */
- (MSignUpItem*) dataItemAtIndexPath:(NSIndexPath*)indexPath {
    NSArray* datas = [self.signUpInputs.itemsGroup objectForKey:[self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex]];
    MSignUpItem* item = [[datas objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return item;
}

/* get 分支行-省市 节点 */
- (MSignUpItem*) bankBranchAreaItem {
    NSArray* datas = [self.signUpInputs.itemsGroup objectForKey:kSignUpItemsTitleStlBankBranch];
    MSignUpItem* item = nil;
    for (NSArray* group in datas) {
        for (MSignUpItem* node in group) {
            if ([node.title isEqualToString:kSUCellTitleProvinceAndCity]) {
                item = node;
                break;
            }
        }
    }
    return item;
}

- (MSignUpItem*) bankItem {
    NSArray* datas = [self.signUpInputs.itemsGroup objectForKey:kSignUpItemsTitleStlInfo];
    MSignUpItem* item = nil;
    for (NSArray* group in datas) {
        for (MSignUpItem* node in group) {
            if ([node.title isEqualToString:kSUCellTitleBankName]) {
                item = node;
                break;
            }
        }
    }
    return item;
}

/* get cell identifier at indexPath */
- (NSString*) identifierForIndexPath:(NSIndexPath*)indexPath {
    MSignUpItem* item = [self dataItemAtIndexPath:indexPath];
    switch (item.cellType) {
        case SU_CellTypeMobileNum:
            return @"SU_CellTypeMobileNum";
            break;
        case SU_CellTypeMobileCheck:
            return @"SU_CellTypeMobileCheck";
            break;
        case SU_CellTypeTextInput:
            return @"SU_CellTypeTextInput";
            break;
        case SU_CellTypeValue1:
            return @"SU_CellTypeValue1";
            break;
        case SU_CellTypePhotoPicked:
            return @"SU_CellTypePhotoPicked";
            break;
        case SU_CellTypeNormalChoose:
            return @"SU_CellTypeNormalChoose";
            break;

        default:
            break;
    }
}

/* new a cell */
- (UITableViewCell* ) newCellForIdentifier:(NSString*)identifier {
    UITableViewCell* cell;
    
    if ([identifier isEqualToString:@"SU_CellTypeMobileNum"]) {
        cell = [[SU_MobileNumberCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    else if ([identifier isEqualToString:@"SU_CellTypeMobileCheck"]) {
        cell = [[SU_MobileCheckCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    else if ([identifier isEqualToString:@"SU_CellTypeTextInput"]) {
        cell = [[SU_TextInputTBVCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    else if ([identifier isEqualToString:@"SU_CellTypePhotoPicked"]) {
        cell = [[SU_PhotoPickedTBVCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    return cell;
}

/* enable signal for inputsChecking's command */
- (RACSignal*) sigOfEnableInputsChecking {
    NSMutableArray* enableSigs = [NSMutableArray array];
        
    NSString* key = [self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex];
    NSArray* itemsAtSections = [self.signUpInputs.itemsGroup objectForKey:key];
    for (NSArray* items in itemsAtSections) {
        for (MSignUpItem* item in items) {
            if (item.mustInput) {
                [enableSigs addObject:RACObserve(item, inputed)];
            }
        }
    }
    if ([key isEqualToString:kSignUpItemsTitleStlBankBranch]) {
        return [RACSignal combineLatest:enableSigs reduce:^id(NSNumber* en1, NSNumber* en2, NSNumber* en3, NSNumber* en4, NSNumber* en5){
            return @(en1.boolValue && en2.boolValue && en3.boolValue && en4.boolValue && en5.boolValue);
        }];
    }
    else if ([key isEqualToString:kSignUpItemsTitleCerUpload] || [key isEqualToString:kSignUpItemsTitleStlInfo] || [key isEqualToString:kSignUpItemsTitleBusinessInfo]) {
        return [RACSignal combineLatest:enableSigs reduce:^id(NSNumber* en1, NSNumber* en2, NSNumber* en3, NSNumber* en4){
            return @(en1.boolValue && en2.boolValue && en3.boolValue && en4.boolValue);
        }];
    }
    else {
        return [RACSignal combineLatest:enableSigs reduce:^id(NSNumber* en1, NSNumber* en2){
            return @(en1.boolValue && en2.boolValue);
        }];
    }
    
}


/* checking passwords */
- (BOOL) isOnPairOfPasswords {
    NSString* key = [self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex];
    NSArray* passwordsItems = [[self.signUpInputs.itemsGroup objectForKey:key] objectAtIndex:0];
    NSString* password = [(MSignUpItem*)[passwordsItems objectAtIndex:0] textInputed];
    NSString* passwordConfirmed = [(MSignUpItem*)[passwordsItems objectAtIndex:1] textInputed];
    return [password isEqualToString:passwordConfirmed];
}

/* checking settlement card no */
- (BOOL) isValidSettlementCardNo {
    NSString* key = [self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex];
    NSArray* settleItems = [[self.signUpInputs.itemsGroup objectForKey:key] objectAtIndex:1];
    NSString* cardNo = [[settleItems objectAtIndex:1] textInputed];
    return ([cardNo hasPrefix:@"62"] && (cardNo.length == 15 || cardNo.length == 16 || cardNo.length == 19));
}

/* checking user ID */
- (BOOL) isValidUserID {
    NSString* key = [self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex];
    NSArray* settleItems = [[self.signUpInputs.itemsGroup objectForKey:key] objectAtIndex:0];
    NSString* userID = [[settleItems objectAtIndex:1] textInputed];
    return userID.length == 15 || userID.length == 18;
}

/* binding inputs to signUpHttp */
- (void) signUpHttpBindingParametersOnSig:(RACSignal*)sig atIndexPath:(NSIndexPath*)indexPath {
    MSignUpItem* item = [self dataItemAtIndexPath:indexPath];
    NSString* seperatedTitle = [self.signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex];
    if ([seperatedTitle isEqualToString:kSignUpItemsTitlePassword]) {
        if ([item.title isEqualToString:kSUCellTitleUserPwd]) {
            RAC(self.signUpHttpRequest, passWord) = sig;
        }
    }
    else if ([seperatedTitle isEqualToString:kSignUpItemsTitleBusinessInfo]) {
        if ([item.title isEqualToString:kSUCellTitleBusinessName]) {
            RAC(self.signUpHttpRequest, mchntNm) = sig;
        }
        else if ([item.title isEqualToString:kSUCellTitleDetailAddr]) {
            RAC(self.signUpHttpRequest, addr) = sig;
        }
        else if ([item.title isEqualToString:kSUCellTitleDeviceSN]) {
            RAC(self.signUpHttpRequest, ageUserName) = sig;
        }
    }
    else if ([seperatedTitle isEqualToString:kSignUpItemsTitleStlInfo]) {
        if ([item.title isEqualToString:kSUCellTitleAccountName]) {
            RAC(self.signUpHttpRequest, settleAcctNm) = sig;
        }
        else if ([item.title isEqualToString:kSUCellTitleAccountNum]) {
            RAC(self.signUpHttpRequest, settleAcct) = sig;
        }
        else if ([item.title isEqualToString:kSUCellTitleUserID]) {
            RAC(self.signUpHttpRequest, identifyNo) = sig;
        }
    }
}

# pragma mask 4 getter

- (RACSignal *)sigChooseArea {
    if (!_sigChooseArea) {
        @weakify(self);
        _sigChooseArea = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            
            SU_ChooseProvinceAndCityVC* areaVC = [[SU_ChooseProvinceAndCityVC alloc] initWithNibName:nil bundle:nil];
            areaVC.doneSelected = ^ (NSString* provinceName, NSString* provinceCode, NSString* cityName, NSString* cityCode){
                NSDictionary* areaPicked = @{@"provinceName":provinceName,
                                             @"provinceCode":provinceCode,
                                             @"cityName":cityName,
                                             @"cityCode":cityCode};
                [subscriber sendNext:areaPicked];
                [subscriber sendCompleted];
            };
            
            UINavigationController* navigationVC = [[UINavigationController alloc] initWithRootViewController:areaVC];
            [self.superVC presentViewController:navigationVC animated:YES completion:^{
            }];
            return nil;
        }];
    }
    return _sigChooseArea;
}

- (RACSignal *)sigChooseBank {
    if (!_sigChooseBank) {
        @weakify(self);

        _sigChooseBank = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            @strongify(self);
            AvilableBankListViewController* bankListVC = [[AvilableBankListViewController alloc] initWithNibName:nil bundle:nil];
            bankListVC.selectedBlock = ^ (NSDictionary* node) {
                [subscriber sendNext:node];
                [subscriber sendCompleted];
            };
            
            UINavigationController* navigationVC = [[UINavigationController alloc] initWithRootViewController:bankListVC];
            [self.superVC presentViewController:navigationVC animated:YES completion:^{
            }];

            return nil;
        }];
    }
    return _sigChooseBank;
}

- (RACSignal *)sigChooseBankBranch {
    if (!_sigChooseBankBranch) {
        @weakify(self);
        _sigChooseBankBranch = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);

            BankBranchListViewController* bankBranchListVC = [[BankBranchListViewController alloc] initWithNibName:nil bundle:nil];
            
            MSignUpItem* areaItem = [self bankBranchAreaItem];
            MSignUpItem* bankItem = [self bankItem];
            bankBranchListVC.bankBranchListRequester.bankCode = bankItem.subText1;
            bankBranchListVC.bankBranchListRequester.province = [areaItem.textInputed substringToIndex:[areaItem.textInputed rangeOfString:@"-"].location];
            bankBranchListVC.bankBranchListRequester.city = [areaItem.textInputed substringFromIndex:[areaItem.textInputed rangeOfString:@"-"].location + 1];
            
            bankBranchListVC.selectedBlock= ^ (NSDictionary* node) {
                [subscriber sendNext:node];
                [subscriber sendCompleted];
            };
            
            UINavigationController* navigationVC = [[UINavigationController alloc] initWithRootViewController:bankBranchListVC];
            [self.superVC presentViewController:navigationVC animated:YES completion:^{
            }];

            return nil;
        }];
    }
    return _sigChooseBankBranch;
}

- (RACSignal *)sigTakePhoto {
    if (!_sigTakePhoto) {
        @weakify(self);
        _sigTakePhoto = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self.photoPicker.sigPhotoPicking subscribeNext:^(UIImage* imagePicked) {
                [subscriber sendNext:imagePicked];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }
    return _sigTakePhoto;
}


- (MSignUpDataSource *)signUpInputs {
    if (!_signUpInputs) {
        _signUpInputs = [[MSignUpDataSource alloc] init];
    }
    return _signUpInputs;
}

- (VMSignUpPhotoPicker *)photoPicker {
    if (!_photoPicker) {
        _photoPicker = [[VMSignUpPhotoPicker alloc] initWithViewController:self.superVC];
    }
    return _photoPicker;
}

- (VMPhoneChecking *)phoneChecking {
    if (!_phoneChecking) {
        _phoneChecking = [[VMPhoneChecking alloc] init];
    }
    return _phoneChecking;
}

- (VMSignUpHttpRequest *)signUpHttpRequest {
    if (!_signUpHttpRequest) {
        _signUpHttpRequest = [[VMSignUpHttpRequest alloc] init];
    }
    return _signUpHttpRequest;
}

@end
