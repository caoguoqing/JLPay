//
//  HttpRequestAreas.h
//  JLPay
//
//  Created by jielian on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//


#import <Foundation/Foundation.h>


static NSString* const kHttpAreaCode = @"key";
static NSString* const kHttpAreaName = @"value";


@interface HttpRequestAreas : NSObject

- (void) requestAreasOnCode:(NSString*)areaCode
                 onSucBlock:(void (^) (NSArray* areas))sucBlock
                 onErrBlock:(void (^) (NSError* error))errBlock;

- (void) terminateRequesting;

@end
