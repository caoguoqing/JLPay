//
//  MTVC_vmLoginAtBack.h
//  JLPay
//
//  Created by jielian on 16/10/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTVC_vmLoginAtBack : NSObject

@property (nonatomic, readonly) BOOL canAutoLogin;

- (void) doLoginAtBackOnLoginSuccess:(void (^) (void))finishedBlock
                        onLoginError:(void (^) (NSError* error))errorBlock;





@end
