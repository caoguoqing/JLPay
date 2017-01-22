//
//  TDVC_mItem.h
//  JLPay
//
//  Created by jielian on 2017/1/19.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDVC_mItem : NSObject 

+ (instancetype) itemWithTitle:(NSString*)title context:(NSString*)context;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* context;


@end
