//
//  MDispatchOrderDetail.h
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDispatchOrderDetail : NSObject

+ (instancetype) orderDetailWithNode:(NSDictionary*)node;

# pragma mask properties: public (formated)

@property (nonatomic, copy) NSString* businessName;
@property (nonatomic, copy) NSString* businessNo;
@property (nonatomic, copy) NSString* cardNo;
@property (nonatomic, copy) NSString* terminalNo;
@property (nonatomic, copy) NSString* transType;
@property (nonatomic, copy) NSString* transMoney;
@property (nonatomic, copy) NSString* transDate;
@property (nonatomic, copy) NSString* transTime;
@property (nonatomic, copy) NSString* originDateAndTime;
@property (nonatomic, copy) NSString* circBankNo;
@property (nonatomic, copy) NSString* seqNo;
@property (nonatomic, copy) NSString* batchNo;
@property (nonatomic, copy) NSString* authNo;
@property (nonatomic, copy) NSString* referenceNo;
@property (nonatomic, copy) NSString* effecDate;

@property (nonatomic, copy) NSString* refuseReason;
@property (nonatomic, copy) NSString* dispatchReason;
@property (nonatomic, copy) NSString* dispatchExplain;

@property (nonatomic, assign) BOOL uploadted;
@property (nonatomic, assign) NSInteger checkedFlag;




/* -- 上传图片资料 -- */
@property (nonatomic, strong) NSMutableArray* photoArray;
/* -- 重新签名图片 -- */
//@property (nonatomic, strong) UIImage* notePicture;

# pragma mask properties: private

@property (nonatomic, copy) NSDictionary* detailNode;

@end
