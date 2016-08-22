//
//  MBusinessItem.h
//  JLPay
//
//  Created by jielian on 16/7/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MBusinessItemType) {
    MBusinessItemTypeState,
    MBusinessItemTypeText,
    MBusinessItemTypeImage
};


@interface MBusinessItem : NSObject

@property (nonatomic, assign) MBusinessItemType itemType;       /* 节点类型 */

@property (nonatomic, assign) BOOL enableReInput;               /* 是否允许重输 */

@property (nonatomic, assign) BOOL reInputed;                   /* 重新输入: default is NO */

@property (nonatomic, strong) NSString* title;                  /* 标题 */

@property (nonatomic, strong) NSString* textValue;              /* 文本值: (显示或被修改) */

@property (nonatomic, strong) UIImage* imageValue;              /* 照片: itemType == MBusinessItemTypeImage 时 */

@property (nonatomic, strong) NSString* valueKey;               /* 文本值的key: (上传时对应的key) */



@end
