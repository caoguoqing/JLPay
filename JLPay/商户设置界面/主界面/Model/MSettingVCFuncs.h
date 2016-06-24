//
//  MSettingVCFuncs.h
//  JLPay
//
//  Created by jielian on 16/5/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define_Header.h"
#import "ModelUserLoginInformation.h"

@interface MSettingVCFuncs : NSObject

<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray* functionTitles;
@property (nonatomic, strong) NSMutableDictionary* functionTitleAndImageNames;



@end
