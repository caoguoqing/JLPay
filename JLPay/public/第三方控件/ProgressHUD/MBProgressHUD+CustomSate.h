//
//  MBProgressHUD+CustomSate.h
//  CustomViewMaker
//
//  Created by jielian on 16/3/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (CustomSate)


+ (instancetype) showNormalWithText:(NSString*)text
                      andDetailText:(NSString*)detailText;
+ (instancetype) showHorizontalProgressWithText:(NSString *)text
                                  andDetailText:(NSString *)detailText;

+ (void) showSuccessWithText:(NSString*)text
               andDetailText:(NSString*)detailText
                onCompletion:(void (^) (void))completion;
+ (void) showFailWithText:(NSString*)text
            andDetailText:(NSString*)detailText
             onCompletion:(void (^) (void))completion;
+ (void) showWarnWithText:(NSString*)text
            andDetailText:(NSString*)detailText
             onCompletion:(void (^) (void))completion;



- (void) showNormalWithText:(NSString*)text andDetailText:(NSString*)detailText;

- (void) showSuccessWithText:(NSString*)text andDetailText:(NSString*)detailText onCompletion:(void (^) (void))completion;
- (void) showFailWithText:(NSString*)text andDetailText:(NSString*)detailText onCompletion:(void (^) (void))completion;
- (void) showWarnWithText:(NSString*)text andDetailText:(NSString*)detailText onCompletion:(void (^) (void))completion;

- (void) showCircleProgressWithText:(NSString*)text andDetailText:(NSString*)detailText;

- (void) hideOnCompletion:(void (^) (void))completion;
- (void) hideDelay:(NSTimeInterval)delay onCompletion:(void (^) (void))completion;

@end
