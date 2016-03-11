//
//  HttpRequestAreas.h
//  JLPay
//
//  Created by jielian on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//


#import <Foundation/Foundation.h>




@interface HttpRequestAreas : NSObject


- (void) requestAreasOnCode:(NSString*)areaCode
                 onSucBlock:(void (^) (void))sucBlock
                 onErrBlock:(void (^) (NSError* error))errBlock;

@property (nonatomic, strong) NSString* provinceNameSelected; // on KVO
@property (nonatomic, strong) NSString* provinceCodeSelected; // on KVO
@property (nonatomic, strong) NSString* cityNameSelected; // on KVO
@property (nonatomic, strong) NSString* cityCodeSelected; // on KVO


- (void) terminateRequesting;


@end
