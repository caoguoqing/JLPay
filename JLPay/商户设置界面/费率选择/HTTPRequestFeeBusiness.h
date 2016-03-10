//
//  HTTPRequestFeeBusiness.h
//  JLPay
//
//  Created by jielian on 15/12/23.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>






@interface HTTPRequestFeeBusiness : NSObject


@property (nonatomic, assign) NSString* businessNameSelected;
@property (nonatomic, assign) NSString* businessCodeSelected;
@property (nonatomic, assign) NSString* terminalCodeSelected;


- (void) requestFeeBusinessOnFeeType:(NSString*)feeType
                            areaCode:(NSString*)areaCode
                          onSucBlock:(void (^) (void))sucBlock
                          onErrBlock:(void (^) (NSError* error))errBlock;

- (void) terminateRequest;

@end
