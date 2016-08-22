//
//  MT0CardUploadItems.m
//  JLPay
//
//  Created by jielian on 16/7/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MT0CardUploadItems.h"
#import <UIKit/UIImage.h>

@implementation MT0CardUploadItems

- (instancetype)init {
    self = [super init];
    if (self) {
        self.T0CUpload_items; /* only for new a obj */
    }
    return self;
}


- (NSMutableArray *)T0CUpload_items {
    if (!_T0CUpload_items) {
        _T0CUpload_items = [NSMutableArray array];
        [_T0CUpload_items addObject:[self cardTypeInfos]];
        [_T0CUpload_items addObject:[self basicInfos]];
        [_T0CUpload_items addObject:[self imageInfos]];
    }
    return _T0CUpload_items;
}

- (NSArray*) cardTypeInfos {
    NSMutableArray* infos = [NSMutableArray array];
    
    MT0UploadItem* cardTypeItem = [MT0UploadItem new];
    cardTypeItem.itemType = MT0UploadItemTypeCardTypeChoose;
    cardTypeItem.itemTitle = @"卡类型";
    cardTypeItem.placeHolder = @"请选择银行卡类型";
    cardTypeItem.mustInput = YES;
    cardTypeItem.inputed = YES;
    cardTypeItem.cardType = MT0UploadCardTypeCredit;
    [infos addObject:cardTypeItem];

    return infos;
}

- (NSArray*) basicInfos {
    NSMutableArray* infos = [NSMutableArray array];
    
    MT0UploadItem* cardNoItem = [MT0UploadItem new];
    cardNoItem.itemType = MT0UploadItemTypeTextInput;
    cardNoItem.itemTitle = @"卡号";
    cardNoItem.placeHolder = @"请输入持卡人银行卡号";
    cardNoItem.mustInput = YES;
    cardNoItem.inputed = NO;
    [infos addObject:cardNoItem];
    
    MT0UploadItem* custNameItem = [MT0UploadItem new];
    custNameItem.itemType = MT0UploadItemTypeTextInput;
    custNameItem.itemTitle = @"持卡人";
    custNameItem.placeHolder = @"请输入持卡人姓名";
    custNameItem.mustInput = YES;
    custNameItem.inputed = NO;
    [infos addObject:custNameItem];

    MT0UploadItem* userIdItem = [MT0UploadItem new];
    userIdItem.itemType = MT0UploadItemTypeTextInput;
    userIdItem.itemTitle = @"身份证号";
    userIdItem.placeHolder = @"请输入持卡人身份证号";
    userIdItem.mustInput = YES;
    userIdItem.inputed = NO;
    [infos addObject:userIdItem];

    MT0UploadItem* mobilePhoneItem = [MT0UploadItem new];
    mobilePhoneItem.itemType = MT0UploadItemTypeTextInput;
    mobilePhoneItem.itemTitle = @"手机号";
    mobilePhoneItem.placeHolder = @"请输入持卡人手机号";
    mobilePhoneItem.mustInput = YES;
    mobilePhoneItem.inputed = NO;
    [infos addObject:mobilePhoneItem];

    return infos;
}

- (NSArray*)  imageInfos {
    NSMutableArray* infos = [NSMutableArray array];
    
    MT0UploadItem* imagePickedItem = [MT0UploadItem new];
    imagePickedItem.itemType = MT0UploadItemTypeImagePicker;
    imagePickedItem.itemTitle = @"卡照片";
    imagePickedItem.placeHolder = @"请上传银行卡正面照(拍照清晰)";
    imagePickedItem.mustInput = YES;
    imagePickedItem.inputed = NO;
    [infos addObject:imagePickedItem];

    return infos;
}


@end
