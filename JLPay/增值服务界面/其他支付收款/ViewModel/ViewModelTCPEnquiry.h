//
//  ViewModelTCPEnquiry.h
//  JLPay
//
//  Created by jielian on 15/11/4.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ViewModelTCPEnquiry;


#pragma mask ---- 回调协议
@protocol ViewModelTCPEnquiryDelegate <NSObject>
@required

/* 交易结果查询回调 */
- (void) TCPEnquiryResult:(BOOL)result withMessage:(NSString*)message;

@end


@interface ViewModelTCPEnquiry : NSObject

/* 属性: 代理 */
@property (nonatomic, weak) id<ViewModelTCPEnquiryDelegate>delegate;

/* 方法: 启动查询 */
- (void) TCPStartTransEnquiryWithTransType:(NSString*)transType
                              andOrderCode:(NSString*)orderCode
                                  andMoney:(NSString*)money;

@end
