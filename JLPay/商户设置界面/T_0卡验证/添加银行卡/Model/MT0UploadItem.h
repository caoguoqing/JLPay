//
//  MT0UploadItem.h
//  JLPay
//
//  Created by jielian on 16/7/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 节点类型 */
typedef enum {
    MT0UploadItemTypeTextInput,                         /* 文本输入 */
    MT0UploadItemTypeCardTypeChoose,                    /* 卡类型选择 */
    MT0UploadItemTypeImagePicker                        /* 图片拍照 */
}MT0UploadItemType;


/* 卡类型: MT0UploadItemTypeCardTypeChoose */
typedef enum {
    MT0UploadCardTypeCredit = 12,                       /* 贷记卡 */
    MT0UploadCardTypeDebit = 11                         /* 借记卡 */
}MT0UploadCardType;

@class UIImage;

@interface MT0UploadItem : NSObject

# pragma mask : 显示属性

@property (nonatomic, assign) MT0UploadItemType itemType;

@property (nonatomic, strong) NSString* itemTitle;

@property (nonatomic, strong) NSString* placeHolder;

@property (nonatomic, assign) BOOL mustInput;

# pragma mask : 输入属性

@property (nonatomic, assign) BOOL inputed;

/* if itemType == MT0UploadItemTypeTextInput */
@property (nonatomic, copy) NSString* textInputed;

/* if itemType == MT0UploadItemTypeImagePicker */
@property (nonatomic, copy) UIImage* imgPicked;

/* if itemType == MT0UploadItemTypeCardTypeChoose */
@property (nonatomic, assign) MT0UploadCardType cardType;

@end
