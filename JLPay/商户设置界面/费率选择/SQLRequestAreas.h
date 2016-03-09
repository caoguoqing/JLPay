//
//  SQLRequestAreas.h
//  JLPay
//
//  Created by jielian on 16/3/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString* const kSQLAreaCode = @"KEY";
static NSString* const kSQLAreaName = @"VALUE";

@interface SQLRequestAreas : NSObject

+ (void) requestAreasOnCode:(NSString*)areaCode
                 onSucBlock:(void (^) (NSArray* areas))sucBlock
                 onErrBlock:(void (^) (NSError* error))errBlock;


@end
