//
//  SQLRequestAreas.h
//  JLPay
//
//  Created by jielian on 16/3/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLRequestAreas : NSObject

@property (nonatomic, assign) NSString* provinceNameSelected; // on KVO
@property (nonatomic, assign) NSString* provinceCodeSelected; // on KVO
@property (nonatomic, assign) NSString* cityNameSelected; // on KVO
@property (nonatomic, assign) NSString* cityCodeSelected; // on KVO


- (void) requestAreasOnCode:(NSString*)areaCode
                 onSucBlock:(void (^) (void))sucBlock
                 onErrBlock:(void (^) (NSError* error))errBlock;


@end
