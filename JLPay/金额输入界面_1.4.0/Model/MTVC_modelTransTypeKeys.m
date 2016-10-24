//
//  MTVC_modelTransTypeKeys.m
//  JLPay
//
//  Created by jielian on 16/10/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MTVC_modelTransTypeKeys.h"
#import "UIColor+HexColor.h"



@implementation MTVC_modelTransTypeKeys

+ (instancetype)model {
    static MTVC_modelTransTypeKeys* modelTransTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modelTransTypes = [[MTVC_modelTransTypeKeys alloc] init];
    });
    return modelTransTypes;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        /* 1 刷卡交易 */
        NSMutableDictionary* node1 = [NSMutableDictionary dictionary];
        [node1 setObject:kTransTypeImgNameJLPay forKey:kTransTypeImgKey];
        [node1 setObject:kTransTypeNameJLPay forKey:kTransTypeTitleKey];
        [node1 setObject:[UIColor colorWithHex:0xef454b alpha:1] forKey:kTransTypeBackColorKey];
        [node1 setObject:[UIColor whiteColor] forKey:kTransTypeTitileColorKey];
        
        /* 2 支付宝支付 */
        NSMutableDictionary* node2 = [NSMutableDictionary dictionary];
        [node2 setObject:kTransTypeImgNameAlipay forKey:kTransTypeImgKey];
        [node2 setObject:kTransTypeNameAlipay forKey:kTransTypeTitleKey];
        [node2 setObject:[UIColor colorWithHex:0x01abf0 alpha:1] forKey:kTransTypeBackColorKey];
        [node2 setObject:[UIColor whiteColor] forKey:kTransTypeTitileColorKey];

        /* 3 微信支付 */
        NSMutableDictionary* node3 = [NSMutableDictionary dictionary];
        [node3 setObject:kTransTypeImgNameWechatPay forKey:kTransTypeImgKey];
        [node3 setObject:kTransTypeNameWechatPay forKey:kTransTypeTitleKey];
        [node3 setObject:[UIColor colorWithHex:0x2da43a alpha:1] forKey:kTransTypeBackColorKey];
        [node3 setObject:[UIColor whiteColor] forKey:kTransTypeTitileColorKey];

        _transTypeList = [NSArray arrayWithObjects:node1,node2,node3, nil];
    }
    return self;
}




@end
