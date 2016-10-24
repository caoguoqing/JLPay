//
//  MTVC_modelTransTypeKeys.h
//  JLPay
//
//  Created by jielian on 16/10/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


# ifndef MTVC_MODELTRANSTYPEKEYS

# define  kTransTypeImgKey              @"imgName"
# define  kTransTypeTitleKey            @"title"
# define  kTransTypeBackColorKey        @"backColor"
# define  kTransTypeTitileColorKey      @"titleColor"

# define  kTransTypeImgNameJLPay        @"JLPayWhite"
# define  kTransTypeNameJLPay           @"刷卡交易"

# define  kTransTypeImgNameWechatPay    @"WechatPay_white"
# define  kTransTypeNameWechatPay       @"微信支付"

# define  kTransTypeImgNameAlipay       @"Alipay_white"
# define  kTransTypeNameAlipay          @"支付宝支付"

# endif





@interface MTVC_modelTransTypeKeys : NSObject



+ (instancetype) model;

/*
 NSDictionary<
                [key_name] : [value_type]
          kTransTypeImgKey : <NSString>    图片名
        kTransTypeTitleKey : <NSString>    标题
  kTransTypeTitileColorKey : <UIColor>     标题色
    kTransTypeBackColorKey : <UIColor>     背景色
 >
 */
@property (nonatomic, strong) NSArray<NSDictionary*>* transTypeList;


@end
