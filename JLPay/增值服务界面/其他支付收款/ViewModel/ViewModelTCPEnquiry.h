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


#define KEYPATH_PAYISDONE_CHANGED @"payIsDone"              // payIsDone 的观察者键
@property (nonatomic, assign) NSNumber* payIsDone;          // 查询结果标记


/* 方法: 启动查询 */
- (void) TCPStartTransEnquiryWithTransType:(NSString*)transType
                              andOrderCode:(NSString*)orderCode
                                  andMoney:(NSString*)money;

/* 方法: 查询成功后的清理工作及回调；在 KEYPATH_PAYISDONE_CHANGED 观察者激活后调用 */
- (void) cleanForEnquiryDone;

/* 方法: 终止并清理定时器；在调用者销毁前调用 */
- (void) terminateTCPEnquiry;



@end
