//
//  MSignUpItem.h
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

typedef enum {
    SU_CellTypeTextInput,                               /* 文本输入 */
    SU_CellTypePhotoPicked,                             /* 拍照 */
    SU_CellTypeNormalChoose                             /* 选择 */
}SU_CellType;



@interface MSignUpItem : NSObject

@property (nonatomic, assign) SU_CellType cellType;     /* cell类型 */


# pragma mask : 下列属性为显示属性

@property (nonatomic, assign) BOOL mustInput;           /* 必输标志 */

@property (nonatomic, copy) NSString* title;            /* 标题 */

@property (nonatomic, copy) NSString* placeHolder;      /* 描述文本 */


# pragma mask : 下列属性为输入属性

@property (nonatomic, assign) BOOL inputed;             /* 输入标记 */

/*
 if 文本: 输入的文本
 if 地址: 详细地址
 if 开户行: 联行号
 */
@property (nonatomic, copy) NSString* textInputed;      /* 文本输入 */

@property (nonatomic, copy) UIImage* photoPicked;       /* 获取到的图片 */

/*
 if 地址:     市代码
 if 开户行:   分支行全称
 */
@property (nonatomic, copy) NSString* subText1;         /* 副输入值1 */

/*
 if 地址:     省代码
 */
@property (nonatomic, copy) NSString* subText2;         /* 副输入值2 */


@end
