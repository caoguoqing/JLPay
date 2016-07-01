//
//  TerminalSelectorVModel.h
//  JLPay
//
//  Created by jielian on 16/4/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLoginSavedResource.h"
#import <UIKit/UIKit.h>

@interface TerminalSelectorVModel : NSObject
<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray* terminals;
@property (nonatomic, strong) NSString* selectedTerminal;


@end
