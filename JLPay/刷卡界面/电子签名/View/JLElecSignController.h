//
//  JLElecSignController.h
//  JLPay
//
//  Created by jielian on 2016/11/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ElecSignFrameView.h"


@interface JLElecSignController : NSObject

+ (instancetype) sharedElecSign;

/* 签名 */
- (void) signWithCompletion:(void (^) (void))completionBlock
                   orCancel:(void (^) (void))cancel;

- (void) hiddenAnimationOnFinished:(void (^) (void))finishedBlock;


/* 特征码 :(in) */
@property (nonatomic, copy) NSString* characteristicCode;


/* 签名视图 :(read_only) */
@property (nonatomic, strong) ElecSignFrameView* elecSignView;

@end
