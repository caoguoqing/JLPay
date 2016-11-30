//
//  NSString+IconFont.h
//  JLPay
//
//  Created by jielian on 16/6/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, IFType) {
    
    /* V1.0 */
    IFTypeBackSpace             = 0xe6e7,       /* 退格 */
    IFTypeExchange              = 0xe749,       /* 切换 */
    IFTypeRightLine             = 0xe667,       /* 右: 箭头 */
    IFTypeRightTri              = 0xe9c6,       /* 右: 三角 */
    IFTypeUnlock                = 0xe62f,       /* 解锁 */
    IFTypeCardBag               = 0xe611,       /* 卡包 */
    IFTypeChainBreak            = 0xe609,       /* 断开连接 */
    IFTypeShop                  = 0xe6b4        /* 商铺 */
};




@interface NSString (IconFont)

/* 生成字体库文字 */
+ (NSString*) stringWithIconType:(IFType)icontype;

/* 全字典 */
+ (NSDictionary*) iconfontDictionaryList;

@end
