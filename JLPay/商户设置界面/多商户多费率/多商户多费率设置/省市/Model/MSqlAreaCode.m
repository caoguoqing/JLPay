//
//  MSqlAreaCode.m
//  JLPay
//
//  Created by jielian on 16/8/30.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MSqlAreaCode.h"
#import "ModelAreaCodeSelector.h"

@implementation MSqlAreaCode

+ (NSArray*) allProvinces {
    NSMutableArray* provinces = [NSMutableArray array];
    for (NSDictionary* areaNode in [ModelAreaCodeSelector allProvincesSelected]) {
        NSMutableDictionary* node = [NSMutableDictionary dictionary];
        
        [node setObject:[[areaNode objectForKey:kFieldNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"name"] ;
        [node setObject:[[areaNode objectForKey:kFieldNameKey] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"code"];
        [provinces addObject:node];
    }
    return provinces;
}

+ (NSArray*) allCitiesOnProvinceCode:(NSString*)provinceCode {
    NSMutableArray* cities = [NSMutableArray array];
    for (NSDictionary* areaNode in [ModelAreaCodeSelector allCitiesSelectedAtProvinceCode:provinceCode]) {
        NSMutableDictionary* node = [NSMutableDictionary dictionary];
        [node setObject:[[areaNode objectForKey:kFieldNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"name"];
        [node setObject:[[areaNode objectForKey:kFieldNameKey] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"code"];
        [cities addObject:node];
    }
    return cities;
}

@end
