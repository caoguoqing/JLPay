//
//  TDVC_mItem.m
//  JLPay
//
//  Created by jielian on 2017/1/19.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "TDVC_mItem.h"

@implementation TDVC_mItem

+ (instancetype)itemWithTitle:(NSString *)title context:(NSString *)context {
    TDVC_mItem* item = [TDVC_mItem new];
    item.title = title;
    item.context = context;
    return item;
}


@end
