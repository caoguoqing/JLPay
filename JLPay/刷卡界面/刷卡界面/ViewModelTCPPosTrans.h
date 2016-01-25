//
//  ViewModelTCPPosTrans.h
//  JLPay
//
//  Created by jielian on 15/11/18.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

/*  ViewModel
 *  TCP POS 交易操作
 *  包括: 
 *  1.消费
 *  2.批上送
 *  3.余额查询
 *  4.撤销(暂不支持)
 */


#import <Foundation/Foundation.h>

@class ViewModelTCPPosTrans;



@protocol ViewModelTCPPosTransDelegate <NSObject>

/* 回调结果: 带回错误信息(如果错误);带回响应信息(如果成功,key为域索引串) */
- (void)viewModel:(ViewModelTCPPosTrans*)viewModel
      transResult:(BOOL)result
      withMessage:(NSString*)message
  andResponseInfo:(NSDictionary*)responseInfo;


@end


@interface ViewModelTCPPosTrans : NSObject

// -- 先组mac源串
- (NSString*) macSourceWithTranType:(NSString*)transType andCardInfo:(NSDictionary*)cardInfo;

/* 发起交易: 指定交易类型+卡数据信息(2,4,14,22,23,35,36,52,53,55) */
- (void) startTransWithTransType:(NSString*)transType
                     andCardInfo:(NSDictionary*)cardInfo
                          macPin:(NSString*)macPin
                     andDelegate:(id<ViewModelTCPPosTransDelegate>)delegate;


/* 终止交易 */
- (void) terminateTransWithTransType:(NSString*)transType;

@end
