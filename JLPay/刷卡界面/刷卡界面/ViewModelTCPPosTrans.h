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

- (void) didTransSuccessWithResponseInfo:(NSDictionary *)responseInfo onTransType:(NSString*)transType;
- (void) didTransFailWithErrMsg:(NSString *)errMsg onTransType:(NSString*)transType;

@end



@interface ViewModelTCPPosTrans : NSObject

// -- new
- (void) startTransWithTransType:(NSString*)transType
                andPackingString:(NSString*)packingString
                      onDelegate:(id<ViewModelTCPPosTransDelegate>)delegate;




/* 终止交易 */
- (void) terminateTransWithTransType:(NSString*)transType;

@end
