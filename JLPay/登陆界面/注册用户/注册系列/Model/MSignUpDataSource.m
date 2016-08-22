//
//  MSignUpDataSource.m
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MSignUpDataSource.h"
#import <ReactiveCocoa.h>


@implementation MSignUpDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addKVOs];
    }
    return self;
}

- (void) addKVOs {
    /* 绑定: 结算账户名、结算账号的输入item跟显示item */
    NSArray* stlInfoItems = [self.itemsGroup objectForKey:kSignUpItemsTitleStlInfo];
    NSArray* stlBankBranchItems = [self.itemsGroup objectForKey:kSignUpItemsTitleStlBankBranch];
    
    
    MSignUpItem* stlInfoCustNameItem = [[stlInfoItems objectAtIndex:0] objectAtIndex:0];
    MSignUpItem* stlInfoBankNameItem = [[stlInfoItems objectAtIndex:1] objectAtIndex:0];
    MSignUpItem* stlInfoCustNoItem = [[stlInfoItems objectAtIndex:1] objectAtIndex:1];
    
    MSignUpItem* stlBankBranchCustNameItem = [[stlBankBranchItems objectAtIndex:0] objectAtIndex:0];
    MSignUpItem* stlBankBranchBankNameItem = [[stlBankBranchItems objectAtIndex:0] objectAtIndex:1];
    MSignUpItem* stlBankBranchCustNoItem = [[stlBankBranchItems objectAtIndex:0] objectAtIndex:2];

    RAC(stlBankBranchCustNameItem, inputed) = RACObserve(stlInfoCustNameItem, inputed);
    RAC(stlBankBranchCustNameItem, textInputed) = RACObserve(stlInfoCustNameItem, textInputed);

    RAC(stlBankBranchCustNoItem, inputed) = RACObserve(stlInfoCustNoItem, inputed);
    RAC(stlBankBranchCustNoItem, textInputed) = RACObserve(stlInfoCustNoItem, textInputed);

    RAC(stlBankBranchBankNameItem, inputed) = RACObserve(stlInfoBankNameItem, inputed);
    RAC(stlBankBranchBankNameItem, textInputed) = RACObserve(stlInfoBankNameItem, textInputed);
}

- (NSArray *)itemsTitles {
    return @[kSignUpItemsTitleMobileCheck,
             kSignUpItemsTitlePassword,
             kSignUpItemsTitleBusinessInfo,
             kSignUpItemsTitleStlInfo,
             kSignUpItemsTitleStlBankBranch,
             kSignUpItemsTitleCerUpload];
}

- (NSMutableDictionary *)itemsGroup {
    if (!_itemsGroup) {
        _itemsGroup = [NSMutableDictionary dictionary];
        
        _itemsGroup[kSignUpItemsTitleMobileCheck]   = [self mobileCheckItems];
        _itemsGroup[kSignUpItemsTitlePassword]      = [self passwordCheckItems];
        _itemsGroup[kSignUpItemsTitleBusinessInfo]  = [self businessInfoItems];
        _itemsGroup[kSignUpItemsTitleStlInfo]       = [self settlementInfoItems];
        _itemsGroup[kSignUpItemsTitleStlBankBranch] = [self settlementCardBranchItems];
        _itemsGroup[kSignUpItemsTitleCerUpload]     = [self photoUploadItems];
        
    }
    return _itemsGroup;
}



/* 手机验证 */ /* 1级 */
- (NSMutableArray*) mobileCheckItems {
    NSMutableArray* items = [NSMutableArray array];
    
    NSMutableArray* subItems1 = [NSMutableArray array];

        MSignUpItem* mobilePhoneItem = [[MSignUpItem alloc] init];
        mobilePhoneItem.cellType = SU_CellTypeMobileNum;
        mobilePhoneItem.title = kSUCellTitleMobilePhone;
        mobilePhoneItem.placeHolder = @"请输入手机号";
        mobilePhoneItem.inputed = NO;
        mobilePhoneItem.mustInput = YES;
        [subItems1 addObject:mobilePhoneItem];
    
        MSignUpItem* mobileCheckItem = [[MSignUpItem alloc] init];
        mobileCheckItem.cellType = SU_CellTypeMobileCheck;
        mobileCheckItem.title = kSUCellTitleCheckNo;
        mobileCheckItem.placeHolder = @"请输入验证码";
        mobileCheckItem.inputed = NO;
        mobileCheckItem.mustInput = YES;
        [subItems1 addObject:mobileCheckItem];
    
    [items addObject:subItems1];
    
    return items;
}

/* 登陆密码 */ /* 1级 */
- (NSMutableArray*) passwordCheckItems {
    NSMutableArray* items = [NSMutableArray array];
    
    NSMutableArray* subItems1 = [NSMutableArray array];

        MSignUpItem* pwdSetting = [[MSignUpItem alloc] init];
        pwdSetting.cellType = SU_CellTypeTextInput;
        pwdSetting.title = kSUCellTitleUserPwd;
        pwdSetting.placeHolder = @"≤8位数字或字母";
        pwdSetting.inputed = NO;
        pwdSetting.mustInput = YES;
        [subItems1 addObject:pwdSetting];
    
        MSignUpItem* pwdChecking = [[MSignUpItem alloc] init];
        pwdChecking.cellType = SU_CellTypeTextInput;
        pwdChecking.title = kSUCellTitleConfirmPwd;
        pwdChecking.placeHolder = @"≤8位数字或字母";
        pwdChecking.inputed = NO;
        pwdChecking.mustInput = YES;
        [subItems1 addObject:pwdChecking];
    
    [items addObject:subItems1];
    
    return items;
}

/* 商户信息 */ /* 3级 */
- (NSMutableArray*) businessInfoItems {
    NSMutableArray* items = [NSMutableArray array];
    
    NSMutableArray* subItems1 = [NSMutableArray array];

        MSignUpItem* businessName = [[MSignUpItem alloc] init];
        businessName.cellType = SU_CellTypeTextInput;
        businessName.title = kSUCellTitleBusinessName;
        businessName.placeHolder = @"≤40位";
        businessName.inputed = NO;
        businessName.mustInput = YES;
        [subItems1 addObject:businessName];
  
    [items addObject:subItems1];
    
    NSMutableArray* subItems2 = [NSMutableArray array];
    
        MSignUpItem* provinceAndCity = [[MSignUpItem alloc] init];
        provinceAndCity.cellType = SU_CellTypeNormalChoose;
        provinceAndCity.title = kSUCellTitleProvinceAndCity;
        provinceAndCity.placeHolder = @"请选择";
        provinceAndCity.inputed = NO;
        provinceAndCity.mustInput = YES;
        [subItems2 addObject:provinceAndCity];
    
        MSignUpItem* detailAddr = [[MSignUpItem alloc] init];
        detailAddr.cellType = SU_CellTypeTextInput;
        detailAddr.title = kSUCellTitleDetailAddr;
        detailAddr.placeHolder = @"从区、街道开始";
        detailAddr.inputed = NO;
        detailAddr.mustInput = YES;
        [subItems2 addObject:detailAddr];
    
    [items addObject:subItems2];
    
    NSMutableArray* subItems3 = [NSMutableArray array];
    
        MSignUpItem* bindingSN = [[MSignUpItem alloc] init];
        bindingSN.cellType = SU_CellTypeTextInput;
        bindingSN.title = kSUCellTitleDeviceSN;
        bindingSN.placeHolder = @"(代理商客户选填)";
        bindingSN.inputed = NO;
        bindingSN.mustInput = NO;
        [subItems3 addObject:bindingSN];
    
    [items addObject:subItems3];
    
    return items;
}


/* 结算信息 */
- (NSMutableArray*) settlementInfoItems {
    NSMutableArray* items = [NSMutableArray array];

    NSMutableArray* sltItems = [NSMutableArray array];

        MSignUpItem* custNameItem = [[MSignUpItem alloc] init];
        custNameItem.cellType = SU_CellTypeTextInput;
        custNameItem.title = kSUCellTitleAccountName;
        custNameItem.placeHolder = @"开户名";
        custNameItem.inputed = NO;
        custNameItem.mustInput = YES;
        [sltItems addObject:custNameItem];

        MSignUpItem* userIDItem = [[MSignUpItem alloc] init];
        userIDItem.cellType = SU_CellTypeTextInput;
        userIDItem.title = kSUCellTitleUserID;
        userIDItem.placeHolder = @"一代或二代身份证";
        userIDItem.inputed = NO;
        userIDItem.mustInput = YES;
        [sltItems addObject:userIDItem];
    

    [items addObject:sltItems];
    
    NSMutableArray* sltItems1 = [NSMutableArray array];
    
        MSignUpItem* brankNameItem = [[MSignUpItem alloc] init];
        brankNameItem.cellType = SU_CellTypeNormalChoose;
        brankNameItem.title = kSUCellTitleBankName;
        brankNameItem.placeHolder = @"未选择";
        brankNameItem.inputed = NO;
        brankNameItem.mustInput = YES;
        [sltItems1 addObject:brankNameItem];
    
        MSignUpItem* cardNoItem = [[MSignUpItem alloc] init];
        cardNoItem.cellType = SU_CellTypeTextInput;
        cardNoItem.title = kSUCellTitleAccountNum;
        cardNoItem.placeHolder = @"限'62*'开头的借记卡";
        cardNoItem.inputed = NO;
        cardNoItem.mustInput = YES;
        [sltItems1 addObject:cardNoItem];

    [items addObject:sltItems1];

    return items;
}

/* 结算卡分支行 */
- (NSMutableArray*) settlementCardBranchItems {
    NSMutableArray* items = [NSMutableArray array];

    NSMutableArray* privateInfos = [NSMutableArray array];
    
        MSignUpItem* custNameItem = [[MSignUpItem alloc] init];
        custNameItem.cellType = SU_CellTypeValue1;
        custNameItem.title = kSUCellTitleAccountName;
        custNameItem.inputed = NO;
        custNameItem.mustInput = YES;
        [privateInfos addObject:custNameItem];
    
        MSignUpItem* bankNameItem = [[MSignUpItem alloc] init];
        bankNameItem.cellType = SU_CellTypeValue1;
        bankNameItem.title = kSUCellTitleBankName;
        bankNameItem.inputed = NO;
        bankNameItem.mustInput = YES;
        [privateInfos addObject:bankNameItem];

    
        MSignUpItem* cardNoItem = [[MSignUpItem alloc] init];
        cardNoItem.cellType = SU_CellTypeValue1;
        cardNoItem.title = kSUCellTitleAccountNum;
        cardNoItem.inputed = NO;
        cardNoItem.mustInput = YES;
        [privateInfos addObject:cardNoItem];

    [items addObject:privateInfos];
    
    NSMutableArray* bankBranchItem = [NSMutableArray array];

        MSignUpItem* provinceAndCity = [[MSignUpItem alloc] init];
        provinceAndCity.cellType = SU_CellTypeNormalChoose;
        provinceAndCity.title = kSUCellTitleProvinceAndCity;
        provinceAndCity.placeHolder = @"未选择";
        provinceAndCity.inputed = NO;
        provinceAndCity.mustInput = YES;
        [bankBranchItem addObject:provinceAndCity];

        MSignUpItem* branchItem = [[MSignUpItem alloc] init];
        branchItem.cellType = SU_CellTypeNormalChoose;
        branchItem.placeHolder = @"未选择";
        branchItem.title = kSUCellTitleBankBranch;
        branchItem.inputed = NO;
        branchItem.mustInput = YES;
        [bankBranchItem addObject:branchItem];
    
    [items addObject:bankBranchItem];

    return items;
}

/* 证件上传 */
- (NSMutableArray*) photoUploadItems {
    NSMutableArray* items = [NSMutableArray array];

    NSMutableArray* idForePhotoItems = [NSMutableArray array];
        MSignUpItem* idForePhoto = [[MSignUpItem alloc] init];
        idForePhoto.cellType = SU_CellTypePhotoPicked;
        idForePhoto.title = kSUCellTitleIDPhotoFore;
        idForePhoto.inputed = NO;
        idForePhoto.mustInput = YES;
    [idForePhotoItems addObject:idForePhoto];
    [items addObject:idForePhotoItems];
    
    NSMutableArray* idBackPhotoItems = [NSMutableArray array];
        MSignUpItem* idBackPhoto = [[MSignUpItem alloc] init];
        idBackPhoto.cellType = SU_CellTypePhotoPicked;
        idBackPhoto.title = kSUCellTitleIDPhotoBack;
        idBackPhoto.inputed = NO;
        idBackPhoto.mustInput = YES;
    [idBackPhotoItems addObject:idBackPhoto];
    [items addObject:idBackPhotoItems];
    
    NSMutableArray* idHoldPhotoItems = [NSMutableArray array];
        MSignUpItem* idHoldPhoto = [[MSignUpItem alloc] init];
        idHoldPhoto.cellType = SU_CellTypePhotoPicked;
        idHoldPhoto.title = kSUCellTitleIDPhotoHandle;
        idHoldPhoto.inputed = NO;
        idHoldPhoto.mustInput = YES;
    [idHoldPhotoItems addObject:idHoldPhoto];
    [items addObject:idHoldPhotoItems];
    
    NSMutableArray* cardHoldPhotoItems = [NSMutableArray array];
        MSignUpItem* cardHoldPhoto = [[MSignUpItem alloc] init];
        cardHoldPhoto.cellType = SU_CellTypePhotoPicked;
        cardHoldPhoto.title = kSUCellTitleDebitCardFore;
        cardHoldPhoto.inputed = NO;
        cardHoldPhoto.mustInput = YES;
    [cardHoldPhotoItems addObject:cardHoldPhoto];
    [items addObject:cardHoldPhotoItems];
    
    return items;
}

@end
