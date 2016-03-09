//
//  SQLRequestAreas.m
//  JLPay
//
//  Created by jielian on 16/3/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SQLRequestAreas.h"
#import "ModelAreaCodeSelector.h"

@implementation SQLRequestAreas

+ (void) requestAreasOnCode:(NSString*)areaCode
                 onSucBlock:(void (^) (NSArray* areas))sucBlock
                 onErrBlock:(void (^) (NSError* error))errBlock {
    if ([areaCode isEqualToString:@"156"]) {
        NSArray* provinces = [ModelAreaCodeSelector allProvincesSelected];
        sucBlock(provinces);
    } else {
        NSArray* cities = [ModelAreaCodeSelector allCitiesSelectedAtProvinceCode:areaCode];
        sucBlock(cities);
    }
}


@end
